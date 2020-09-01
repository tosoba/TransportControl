import 'dart:async';
import 'dart:developer';

import 'package:async/async.dart' show RestartableTimer;
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_animarker/lat_lng_interpolation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:rxdart/rxdart.dart';
import 'package:transport_control/di/module/controllers_module.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/model/location.dart';
import 'package:transport_control/model/place_suggestion.dart';
import 'package:transport_control/model/result.dart';
import 'package:transport_control/model/vehicle.dart';
import 'package:transport_control/pages/map/map_constants.dart';
import 'package:transport_control/pages/map/map_event.dart';
import 'package:transport_control/pages/map/map_markers.dart';
import 'package:transport_control/pages/map/map_selected_vehicle_update.dart';
import 'package:transport_control/pages/map/map_signal.dart';
import 'package:transport_control/pages/map/map_state.dart';
import 'package:transport_control/pages/map/map_vehicle.dart';
import 'package:transport_control/pages/map/map_vehicle_source.dart';
import 'package:transport_control/repo/vehicles_repo.dart';
import 'package:transport_control/util/asset_util.dart';
import 'package:transport_control/util/lat_lng_util.dart';
import 'package:transport_control/util/marker_util.dart';
import 'package:transport_control/util/model_util.dart';
import 'package:transport_control/util/preferences_util.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final RxSharedPreferences _preferences;
  final VehiclesRepo _vehiclesRepo;
  final Sink<Set<Line>> _untrackLinesSink;
  final Sink<Object> _untrackAllLinesSink;

  final _subscriptions = <StreamSubscription>[];

  final _signals = StreamController<MapSignal>.broadcast();
  Stream<MapSignal> get signals => _signals.stream;

  void Function(List<LatLng>) clusteredMarkerTapped;
  void Function(String) nonClusteredMarkerTapped;

  MapBloc(
    this._vehiclesRepo,
    this._preferences,
    this._untrackLinesSink,
    this._untrackAllLinesSink,
    Stream<Location> loadVehiclesInLocationStream,
    Stream<LatLng> loadVehiclesNearbyUserLocationStream,
    Stream<PlaceSuggestion> loadVehiclesNearbyPlaceStream,
    Stream<TrackedLinesAddedEvent> trackedLinesAddedStream,
    Stream<Set<Line>> trackedLinesRemovedStream,
  ) {
    _subscriptions
      ..add(
        Stream.periodic(const Duration(seconds: 15))
            .where((_) => state.trackedVehicles.isNotEmpty)
            .asyncMap(
              (_) => _vehiclesRepo.loadUpdatedVehicles(
                state.trackedVehicles.values.map((tracked) => tracked.vehicle),
              ),
            )
            .listen(
              (result) => result.when(
                success: (success) => add(
                  MapEvent.updateVehicles(vehicles: success.data),
                ),
                failure: (failure) => failure.logError(),
              ),
            ),
      )
      ..add(loadVehiclesInLocationStream.listen(_loadVehiclesInLocation))
      ..add(
        loadVehiclesNearbyUserLocationStream.listen(
          (position) async => _loadVehiclesNearbyUserLocation(
            position,
            radiusInMeters: await _preferences.getInt(
              Preferences.nearbySearchRadius.key,
            ),
          ),
        ),
      )
      ..add(
        loadVehiclesNearbyPlaceStream.listen(
          (place) async => _loadVehiclesNearbyPlace(
            LatLng(place.position.lat, place.position.lng),
            title: place.title,
            radiusInMeters: await _preferences.getInt(
              Preferences.nearbySearchRadius.key,
            ),
          ),
        ),
      )
      ..add(trackedLinesAddedStream.listen(_loadVehiclesOfLines))
      ..add(
        trackedLinesRemovedStream
            .listen((lines) => add(MapEvent.trackedLinesRemoved(lines: lines))),
      );
  }

  @override
  MapState get initialState => MapState.initial();

  @override
  Stream<MapState> mapEventToState(MapEvent event) async* {
    if (event is UpdateVehicles) {
      yield* _updateVehiclesStates(
        vehiclesToProcess: Map<String, Vehicle>.fromIterable(
          event.vehicles,
          key: (vehicle) => vehicle.number,
          value: (vehicle) => vehicle,
        ),
        animatePositions: true,
      );
    } else if (event is AddVehiclesOfLines) {
      final lineSymbols = Map.fromIterables(
        event.lines.map((line) => line.symbol),
        event.lines,
      );
      final loadedAt = DateTime.now();
      yield* _newVehiclesStates(
        event.vehicles,
        sourceForVehicle: (vehicle) => MapVehicleSource.ofLine(
          line: lineSymbols[vehicle.symbol],
          loadedAt: loadedAt,
        ),
      );
    } else if (event is AddVehiclesInLocation) {
      final loadedAt = DateTime.now();
      yield* _newVehiclesStates(
        event.vehicles,
        sourceForVehicle: (_) => MapVehicleSource.nearbyLocation(
          location: event.location,
          loadedAt: loadedAt,
        ),
      );
    } else if (event is AddVehiclesNearbyUserLocation) {
      final loadedAt = DateTime.now();
      yield* _newVehiclesStates(
        event.vehicles,
        sourceForVehicle: (_) => MapVehicleSource.nearbyUserLocation(
          position: event.position,
          radius: event.radius,
          loadedAt: loadedAt,
        ),
      );
    } else if (event is AddVehiclesNearbyPlace) {
      final loadedAt = DateTime.now();
      yield* _newVehiclesStates(
        event.vehicles,
        sourceForVehicle: (_) => MapVehicleSource.nearbyPlace(
          position: event.position,
          radius: event.radius,
          title: event.title,
          loadedAt: loadedAt,
        ),
      );
    } else if (event is CameraMoved) {
      yield* _updateVehiclesStates(
        updatedBounds: event.bounds,
        updatedZoom: event.zoom,
        selectedVehicleUpdate: Deselect(),
      );
    } else if (event is DeselectVehicle) {
      yield* _updateVehiclesStates(selectedVehicleUpdate: Deselect());
    } else if (event is SelectVehicle) {
      if (event.number == state.selectedVehicleNumber) {
        yield state;
      } else {
        yield* _updateVehiclesStates(
          selectedVehicleUpdate: Select(number: event.number),
        );
      }
    } else {
      yield event.whenOrElse(
        clearMap: (_) => state.copyWith(trackedVehicles: {}),
        trackedLinesRemoved: (evt) => state.withRemovedSource(
          (source) => source is OfLine && evt.lines.contains(source.line),
        ),
        removeSource: (evt) => state.withRemovedSource(
          (source) => source == evt.source,
        ),
        orElse: (_) => state,
      );
    }
  }

  @override
  void onTransition(Transition<MapEvent, MapState> transition) {
    super.onTransition(transition);
    log(transition.toString());
  }

  @override
  Future<void> close() async {
    await Future.wait([
      ..._subscriptions.map((subscription) => subscription.cancel()),
      _signals.close(),
    ]);
    return super.close();
  }

  Stream<MapState> _updateVehiclesStates({
    Map<String, Vehicle> vehiclesToProcess,
    MapSelectedVehicleUpdate selectedVehicleUpdate,
    bool animatePositions = false,
    LatLngBounds updatedBounds,
    double updatedZoom,
    MapVehicleSource Function(Vehicle) sourceForVehicle,
  }) async* {
    final toProcess = vehiclesToProcess ?? state.allVehicles;
    final bounds = updatedBounds ?? state.bounds;
    final zoom = updatedZoom ?? state.zoom;

    final selectedUpdate = selectedVehicleUpdate ?? NoChange();
    final selectedVehicleNumber = selectedUpdate.when(
      noChange: (_) => state.selectedVehicleNumber,
      deselect: (_) => null,
      select: (update) => update.number,
    );
    Vehicle updatedSelectedVehicle;

    final currentTrackedVehicles = state.trackedVehicles;
    final processed = Map.of(currentTrackedVehicles);
    final clusterables = <String, ClusterableMarker>{};

    toProcess.forEach((number, vehicle) {
      if (number == selectedVehicleNumber) {
        updatedSelectedVehicle = vehicle;
        return;
      }

      final current = currentTrackedVehicles[number];
      if (!bounds.containsLatLng(vehicle.lat, vehicle.lon)) {
        final sources = sourceForVehicle != null
            ? {sourceForVehicle(vehicle), ...?current?.sources}
            : current?.sources;
        if (current?.marker == null) {
          processed[number] = MapVehicle.withoutMarker(
            vehicle,
            sources: sources,
          );
        } else {
          final currentPosition = current.marker.position;
          if (!bounds.containsLatLng(
            currentPosition.latitude,
            currentPosition.longitude,
          )) {
            processed[number] = MapVehicle.withoutMarker(
              vehicle,
              sources: sources,
            );
          } else {
            clusterables[number] = ClusterableMarker.fromVehicle(
              vehicle,
              initialPosition: currentPosition,
            );
          }
        }
      } else {
        clusterables[number] = ClusterableMarker.fromVehicle(
          vehicle,
          initialPosition: current?.marker?.position,
        );
      }
    });

    final fluster = await clusterables.fluster(
      minZoom: MapConstants.minClusterZoom,
      maxZoom: MapConstants.maxClusterZoom,
    );

    final iconifiedMarkers = await fluster.iconifiedMarkers(
      currentZoom: state.zoom,
      clusterColor: Colors.blue,
      clusterTextColor: Colors.white,
    );

    iconifiedMarkers.clustered.forEach((clustered) {
      final marker = clustered.googleMapMarker(
        onTap: () => clusteredMarkerTapped(
          clustered.children.map(
            (child) => LatLng(child.latitude, child.longitude),
          ),
        ),
      );
      clustered.children.forEach((clusterable) {
        final vehicle = toProcess[clusterable.number];
        final sources = sourceForVehicle != null
            ? {
                sourceForVehicle(vehicle),
                ...?currentTrackedVehicles[clusterable.number]?.sources
              }
            : currentTrackedVehicles[clusterable.number]?.sources;
        processed[clusterable.number] = MapVehicle.withMarker(
          vehicle,
          marker: marker,
          sources: sources,
        );
      });
    });

    if (animatePositions && zoom > MapConstants.minAnimationZoom) {
      final animationStatesController = StreamController<MapState>();
      final animationStatesTimer = RestartableTimer(
        const Duration(milliseconds: 100),
        () {
          animationStatesController.close();
        },
      );
      iconifiedMarkers
          .animatedMarkersStream(
            markerTapped: nonClusteredMarkerTapped,
            selectedMarker: await state.selectedMarker(
              selectedVehicleUpdate: selectedUpdate,
              updatedSelectedVehicle: updatedSelectedVehicle,
            ),
          )
          .map((animated) {
            animated.forEach((vehicleMarker) {
              final vehicle = toProcess[vehicleMarker.number];
              final sources = sourceForVehicle != null
                  ? {
                      sourceForVehicle(vehicle),
                      ...?currentTrackedVehicles[vehicleMarker.number]?.sources
                    }
                  : currentTrackedVehicles[vehicleMarker.number]?.sources;
              processed[vehicleMarker.number] = MapVehicle.withMarker(
                vehicle,
                marker: vehicleMarker.marker,
                sources: sources,
              );
            });
            return state.copyWith(
              trackedVehicles: processed,
              bounds: bounds,
              zoom: zoom,
              selectedVehicleUpdate: selectedUpdate,
            );
          })
          .doOnData((_) => animationStatesTimer.reset())
          .takeWhile((_) => !animationStatesController.isClosed)
          .listen(animationStatesController.add);
      yield* animationStatesController.stream;
    } else {
      iconifiedMarkers.nonClustered.forEach((nonClustered) {
        final marker = nonClustered.googleMapMarker(
          onTap: () => nonClusteredMarkerTapped(nonClustered.number),
        );
        final vehicle = toProcess[nonClustered.number];
        final sources = sourceForVehicle != null
            ? {
                sourceForVehicle(vehicle),
                ...?currentTrackedVehicles[nonClustered.number]?.sources
              }
            : currentTrackedVehicles[nonClustered.number]?.sources;
        processed[nonClustered.number] = MapVehicle.withMarker(
          vehicle,
          marker: marker,
          sources: sources,
        );
      });

      if (selectedVehicleNumber != null) {
        final selectedMarker = await state.selectedMarker(
          selectedVehicleUpdate: selectedUpdate,
          updatedSelectedVehicle: updatedSelectedVehicle,
        );
        final vehicle = toProcess[selectedVehicleNumber];
        final sources = sourceForVehicle != null
            ? {
                sourceForVehicle(vehicle),
                ...?currentTrackedVehicles[selectedVehicleNumber]?.sources
              }
            : currentTrackedVehicles[selectedVehicleNumber]?.sources;
        processed[selectedVehicleNumber] = MapVehicle.withMarker(
          vehicle,
          marker: selectedMarker.googleMapMarker(
            onTap: () => nonClusteredMarkerTapped(selectedVehicleNumber),
          ),
          sources: sources,
        );
      }

      yield state.copyWith(
        trackedVehicles: processed,
        bounds: bounds,
        zoom: zoom,
        selectedVehicleUpdate: selectedUpdate,
      );
    }
  }

  Stream<MapState> _newVehiclesStates(
    Iterable<Vehicle> vehicles, {
    @required MapVehicleSource Function(Vehicle) sourceForVehicle,
  }) async* {
    final toProcess = state.allVehicles;
    vehicles.forEach((vehicle) => toProcess[vehicle.number] = vehicle);
    yield* _updateVehiclesStates(
      vehiclesToProcess: toProcess,
      sourceForVehicle: sourceForVehicle,
    );
  }

  void _loadVehiclesOfLines(TrackedLinesAddedEvent event) {
    final lines = event.lines;
    _loadVehicles(
      loadingMsg:
          'Loading vehicles of ${lines.length} ${lines.length > 1 ? 'lines' : 'line'}...',
      emptyResultErrorMsg: 'No vehicles of requested lines were found.',
      loadVehicles: () => _vehiclesRepo.loadVehiclesOfLines(lines),
      successEvent: (vehicles) => MapEvent.addVehiclesOfLines(
        vehicles: vehicles,
        lines: lines,
      ),
      onFailure: (_) => _untrackLinesSink.add(lines),
      beforeRetry: event.beforeRetry,
    );
  }

  void _loadVehiclesInLocation(Location location) {
    _loadVehicles(
      loadingMsg: 'Loading vehicles nearby ${location.name}',
      emptyResultErrorMsg: 'No vehicles were found nearby ${location.name}.',
      loadVehicles: () => _vehiclesRepo.loadVehiclesInBounds(location.bounds),
      successEvent: (vehicles) => MapEvent.addVehiclesInLocation(
        vehicles: vehicles,
        location: location,
      ),
    );
  }

  void _loadVehiclesNearbyUserLocation(
    LatLng position, {
    @required int radiusInMeters,
  }) {
    _loadVehicles(
      loadingMsg: 'Loading nearby vehicles...',
      emptyResultErrorMsg: 'No vehicles were found nearby your location.',
      loadVehicles: () => _vehiclesRepo.loadVehiclesNearby(
        position,
        radiusInMeters: radiusInMeters,
      ),
      successEvent: (vehicles) => MapEvent.addVehiclesNearbyUserLocation(
        vehicles: vehicles,
        position: position,
        radius: radiusInMeters,
      ),
    );
  }

  void _loadVehiclesNearbyPlace(
    LatLng position, {
    @required String title,
    @required int radiusInMeters,
  }) {
    _loadVehicles(
      loadingMsg: 'Loading vehicles nearby $title...',
      emptyResultErrorMsg: 'No vehicles were found nearby $title.',
      loadVehicles: () => _vehiclesRepo.loadVehiclesNearby(
        position,
        radiusInMeters: radiusInMeters,
      ),
      successEvent: (vehicles) => MapEvent.addVehiclesNearbyPlace(
        vehicles: vehicles,
        position: position,
        title: title,
        radius: radiusInMeters,
      ),
    );
  }

  void _loadVehicles({
    @required String loadingMsg,
    @required String emptyResultErrorMsg,
    @required Future<Result<List<Vehicle>>> Function() loadVehicles,
    @required MapEvent Function(List<Vehicle>) successEvent,
    void Function(Failure<List<Vehicle>>) onFailure,
    void Function() beforeRetry,
  }) async {
    if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
      _signals.add(
        MapSignal.loadingError(message: 'No internet connection.', retry: null),
      );
      onFailure?.call(Failure(error: Exception('No internet connection.')));
      return;
    }

    _signals.add(MapSignal.loading(message: loadingMsg));

    final result = await loadVehicles();
    result.asyncWhen(
      success: (success) async {
        final vehicles = success.data;
        if (vehicles.isEmpty) {
          onFailure?.call(Failure(error: Exception('No vehicles found.')));
          _signals.add(
            MapSignal.loadingError(
              message: emptyResultErrorMsg,
              retry: () {
                beforeRetry?.call();
                _loadVehicles(
                  loadingMsg: loadingMsg,
                  emptyResultErrorMsg: emptyResultErrorMsg,
                  loadVehicles: loadVehicles,
                  successEvent: successEvent,
                  onFailure: onFailure,
                  beforeRetry: beforeRetry,
                );
              },
            ),
          );
        } else {
          add(successEvent(vehicles));
          final zoomToLoadedMarkersBounds = await _preferences
              .getBool(Preferences.zoomToLoadedMarkersBounds.key);
          _signals.add(
            zoomToLoadedMarkersBounds
                ? MapSignal.zoomToBoundsAfterLoadedSuccessfully(
                    bounds: vehicles.map((vehicle) => vehicle.position).bounds,
                  )
                : MapSignal.loadedSuccessfully(),
          );
        }
      },
      failure: (failure) {
        failure.logError();
        onFailure?.call(failure);
        _signals.add(
          MapSignal.loadingError(
            message: 'Loading error occurred.',
            retry: () {
              beforeRetry?.call();
              _loadVehicles(
                loadingMsg: loadingMsg,
                emptyResultErrorMsg: emptyResultErrorMsg,
                loadVehicles: loadVehicles,
                successEvent: successEvent,
                onFailure: onFailure,
                beforeRetry: beforeRetry,
              );
            },
          ),
        );
      },
    );
  }

  void cameraMoved({
    @required LatLngBounds bounds,
    @required double zoom,
    @required bool byUser,
  }) {
    add(MapEvent.cameraMoved(bounds: bounds, zoom: zoom, byUser: byUser));
  }

  void selectVehicle(String number) {
    add(MapEvent.selectVehicle(number: number));
  }

  void deselectVehicle() {
    if (state.selectedVehicleNumber != null) add(MapEvent.deselectVehicle());
  }

  void clearMap() {
    _untrackAllLinesSink.add(Object());
    add(MapEvent.clearMap());
  }

  void removeSource(MapVehicleSource source) {
    if (source is OfLine) {
      _untrackLinesSink.add({source.line});
    }
    add(MapEvent.removeSource(source: source));
  }

  Stream<Set<MapVehicleSource>> get mapVehicleSourcesStream {
    return map((state) {
      final sources = <MapVehicleSource>{};
      state.trackedVehicles.values.forEach((tracked) {
        sources.addAll(tracked.sources);
      });
      return sources;
    });
  }

  Stream<Set<Marker>> get markers {
    return map(
      (state) => state.trackedVehicles.values
          .map((vehicle) => vehicle.marker)
          .where((marker) => marker != null)
          .toSet(),
    );
  }
}

extension _IconifiedMarkersExt on IconifiedMarkers {
  Stream<List<MapVehicleMarker>> animatedMarkersStream({
    @required void Function(String) markerTapped,
    IconifiedMarker selectedMarker,
  }) {
    return CombineLatestStream.list(
      markersToAnimate(selectedMarker: selectedMarker).map(
        (marker) {
          if (marker.initialPosition != null &&
              marker.initialPosition != marker.position) {
            final interpolationStream = LatLngInterpolationStream()
              ..addLatLng(marker.initialPosition)
              ..addLatLng(marker.position);
            return interpolationStream.getLatLngInterpolation().map(
                  (delta) => MapVehicleMarker(
                    marker: marker.googleMapMarker(
                      position: delta.from,
                      onTap: () => markerTapped(marker.number),
                    ),
                    number: marker.number,
                  ),
                );
          } else {
            return Stream.value(
              MapVehicleMarker(
                marker: marker.googleMapMarker(
                  onTap: () => markerTapped(marker.number),
                ),
                number: marker.number,
              ),
            );
          }
        },
      ),
    );
  }

  List<IconifiedMarker> markersToAnimate({IconifiedMarker selectedMarker}) {
    if (selectedMarker != null) {
      return nonClustered..add(selectedMarker);
    } else {
      return nonClustered;
    }
  }
}

extension _MapStateExt on MapState {
  Map<String, Vehicle> get allVehicles => trackedVehicles
      .map((number, tracked) => MapEntry(number, tracked.vehicle));

  Future<IconifiedMarker> selectedMarker({
    @required MapSelectedVehicleUpdate selectedVehicleUpdate,
    @required Vehicle updatedSelectedVehicle,
  }) async {
    final number = selectedVehicleUpdate.when(
      noChange: (_) => selectedVehicleNumber,
      deselect: (_) => null,
      select: (update) => update.number,
    );
    if (number == null) return null;

    final current = trackedVehicles[number];
    if (current == null) return null;

    return IconifiedMarker(
      ClusterableMarker.fromVehicle(
        updatedSelectedVehicle,
        initialPosition: current.marker?.position,
      ),
      icon: await markerBitmap(
        symbol: updatedSelectedVehicle.symbol,
        width: MapConstants.markerWidth,
        height: MapConstants.markerHeight,
        imageAsset: await rootBundle.loadUiImage(
          ImageAssets.selectedMarker,
        ),
      ),
    );
  }

  MapState withRemovedSource(bool Function(MapVehicleSource) sourceMatcher) {
    final updatedVehicles = <String, MapVehicle>{};
    bool deselectVehicle = false;
    trackedVehicles.forEach((number, tracked) {
      final sources = tracked.sources;
      final sourceToRemove = sources.firstWhere(
        sourceMatcher,
        orElse: () => null,
      );
      if (sourceToRemove == null) {
        updatedVehicles[number] = tracked;
      } else if (sources.length == 1) {
        if (number == selectedVehicleNumber) deselectVehicle = true;
        return;
      } else {
        updatedVehicles[number] = tracked.withRemovedSource(sourceToRemove);
      }
    });
    return copyWith(
      trackedVehicles: updatedVehicles,
      selectedVehicleUpdate: deselectVehicle ? Deselect() : NoChange(),
    );
  }
}

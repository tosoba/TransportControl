import 'dart:async';
import 'dart:developer';

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
import 'package:transport_control/pages/map/map_signal.dart';
import 'package:transport_control/pages/map/map_state.dart';
import 'package:transport_control/pages/map/map_vehicle.dart';
import 'package:transport_control/pages/map/map_vehicle_source.dart';
import 'package:transport_control/repo/vehicles_repo.dart';
import 'package:transport_control/util/asset_util.dart';
import 'package:transport_control/util/lat_lng_util.dart';
import 'package:transport_control/util/marker_util.dart';
import 'package:transport_control/util/preferences_util.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final RxSharedPreferences _preferences;
  final VehiclesRepo _vehiclesRepo;
  final Sink<Set<Line>> _untrackLinesSink;
  final Sink<Object> _untrackAllLinesSink;

  final _subscriptions = <StreamSubscription>[];

  final _signals = StreamController<MapSignal>.broadcast();
  Stream<MapSignal> get signals => _signals.stream;

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

  static final double _minAnimationZoom = 12;

  Stream<MapState> _updateVehiclesStates({
    @required Map<String, Vehicle> vehiclesToProcess,
    bool animatePositions = false,
    LatLngBounds updatedBounds,
    double updatedZoom,
    MapVehicleSource Function(Vehicle) sourceForVehicle,
  }) async* {
    final bounds = updatedBounds ?? state.bounds;
    final zoom = updatedZoom ?? state.zoom;
    final trackedVehicles = state.trackedVehicles;
    final processed = Map.of(trackedVehicles);
    final clusterables = <String, ClusterableMarker>{};
    vehiclesToProcess.forEach((number, vehicle) {
      final current = trackedVehicles[number];
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
      final marker = clustered.googleMapMarker();
      clustered.children.forEach((clusterable) {
        final vehicle = vehiclesToProcess[clusterable.number];
        final sources = sourceForVehicle != null
            ? {
                sourceForVehicle(vehicle),
                ...?trackedVehicles[clusterable.number]?.sources
              }
            : trackedVehicles[clusterable.number]?.sources;
        processed[clusterable.number] = MapVehicle.withMarker(
          vehicle,
          marker: marker,
          sources: sources,
        );
      });
    });

    if (animatePositions && zoom > _minAnimationZoom) {
      final animationStatesController = StreamController<MapState>();
      Future.delayed(
        Duration(milliseconds: 1100),
        () => animationStatesController.close(),
      );
      iconifiedMarkers
          .animatedMarkersStream(selectedMarker: await state._selectedMarker)
          .map((animated) {
        animated.forEach((mapVehicleMarker) {
          final vehicle = vehiclesToProcess[mapVehicleMarker.number];
          final sources = sourceForVehicle != null
              ? {
                  sourceForVehicle(vehicle),
                  ...?trackedVehicles[mapVehicleMarker.number]?.sources
                }
              : trackedVehicles[mapVehicleMarker.number]?.sources;
          processed[mapVehicleMarker.number] = MapVehicle.withMarker(
            vehicle,
            marker: mapVehicleMarker.marker,
            sources: sources,
          );
        });
        return state.copyWith(
          trackedVehicles: processed,
          bounds: bounds,
          zoom: zoom,
        );
      }).listen(animationStatesController.add);
      yield* animationStatesController.stream;
    } else {
      iconifiedMarkers.nonClustered.forEach((nonClustered) {
        final marker = nonClustered.googleMapMarker();
        final vehicle = vehiclesToProcess[nonClustered.number];
        final sources = sourceForVehicle != null
            ? {
                sourceForVehicle(vehicle),
                ...?trackedVehicles[nonClustered.number]?.sources
              }
            : trackedVehicles[nonClustered.number]?.sources;
        processed[nonClustered.number] = MapVehicle.withMarker(
          vehicle,
          marker: marker,
          sources: sources,
        );
      });
      yield state.copyWith(
        trackedVehicles: processed,
        bounds: bounds,
        zoom: zoom,
      );
    }
  }

  Stream<MapState> _newVehiclesStates(
    Iterable<Vehicle> vehicles, {
    @required MapVehicleSource Function(Vehicle) sourceForVehicle,
  }) async* {
    final toProcess = state.trackedVehicles
        .map((number, tracked) => MapEntry(number, tracked.vehicle));
    vehicles.forEach((vehicle) => toProcess[vehicle.number] = vehicle);
    yield* _updateVehiclesStates(
      vehiclesToProcess: toProcess,
      sourceForVehicle: sourceForVehicle,
    );
  }

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
      //withNoSelectedVehicleBoundsAndZoom
      yield* _updateVehiclesStates(
        vehiclesToProcess: state.trackedVehicles
            .map((number, tracked) => MapEntry(number, tracked.vehicle)),
        updatedBounds: event.bounds,
        updatedZoom: event.zoom,
      );
    } else {
      yield event.whenOrElse(
        orElse: (_) => state,
        clearMap: (_) => state.copyWith(trackedVehicles: {}),
        trackedLinesRemoved: (evt) => state.withRemovedSource(
          (source) => source is OfLine && evt.lines.contains(source.line),
        ),
        removeSource: (evt) => state.withRemovedSource(
          (source) => source == evt.source,
        ),
        // selectVehicle: (evt) => evt.number == state.selectedVehicleNumber
        //     ? state
        //     : state.copyWith(selectedVehicleNumber: evt.number),
        // deselectVehicle: (_) => state.withNoSelectedVehicle,
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

  Stream<Set<Marker>> get markers {
    return map(
      (state) => state.trackedVehicles.values
          .map((vehicle) => vehicle.marker)
          .where((marker) => marker != null)
          .toSet(),
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
                    bounds: vehicles
                        .map((vehicle) => LatLng(vehicle.lat, vehicle.lon))
                        .bounds,
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
}

extension _IconifiedMarkersExt on IconifiedMarkers {
  List<IconifiedMarker> _markersToAnimate({IconifiedMarker selectedMarker}) {
    if (selectedMarker != null) {
      return nonClustered..add(selectedMarker);
    } else {
      return nonClustered;
    }
  }

  Stream<List<MapVehicleMarker>> animatedMarkersStream({
    IconifiedMarker selectedMarker,
  }) {
    return CombineLatestStream.list(
      _markersToAnimate(selectedMarker: selectedMarker).map(
        (marker) {
          if (marker.initialPosition != null &&
              marker.initialPosition != marker.position) {
            final interpolationStream = LatLngInterpolationStream()
              ..addLatLng(marker.initialPosition)
              ..addLatLng(marker.position);
            return interpolationStream
                .getLatLngInterpolation()
                .map((delta) => MapVehicleMarker(
                      marker: marker.googleMapMarker(position: delta.from),
                      number: marker.number,
                    ));
          } else {
            return Stream.value(
              MapVehicleMarker(
                marker: marker.googleMapMarker(),
                number: marker.number,
              ),
            );
          }
        },
      ),
    );
  }
}

extension _MapStateExt on MapState {
  Future<IconifiedMarker> get _selectedMarker async {
    if (selectedVehicleNumber == null) return null;
    final selected = trackedVehicles[selectedVehicleNumber];
    if (selected == null) return null;
    return IconifiedMarker(
      ClusterableMarker(
        symbol: selected.vehicle.symbol,
        id: selectedVehicleNumber,
        lat: selected.vehicle.lat,
        lng: selected.vehicle.lon,
      ),
      icon: await markerBitmap(
        symbol: selected.vehicle.symbol,
        width: MapConstants.markerWidth,
        height: MapConstants.markerHeight,
        imageAsset: await rootBundle.loadUiImage(
          ImageAssets.selectedMarker,
        ),
      ),
    );
  }

  MapState withRemovedSource(bool Function(MapVehicleSource) sourceMatcher) {
    final updatedVehicles = Map<String, MapVehicle>();
    trackedVehicles.forEach((number, tracked) {
      final sources = tracked.sources;
      final sourceToRemove = sources.firstWhere(
        sourceMatcher,
        orElse: () => null,
      );

      if (sourceToRemove == null) {
        updatedVehicles[number] = tracked;
      } else if (sources.length == 1) {
        return;
      } else {
        updatedVehicles[number] = tracked.withRemovedSource(sourceToRemove);
      }
    });
    return copyWith(trackedVehicles: updatedVehicles);
  }
}

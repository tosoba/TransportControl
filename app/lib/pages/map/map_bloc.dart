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
import 'package:transport_control/di/module/controllers_module.dart'
    as Controllers;
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
import 'package:transport_control/util/bloc_util.dart';
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

  void Function(Iterable<LatLng>) clusteredMarkerTapped;
  void Function(String) nonClusteredMarkerTapped;

  MapBloc(
    this._vehiclesRepo,
    this._preferences,
    this._untrackLinesSink,
    this._untrackAllLinesSink,
    Stream<Location> loadVehiclesInLocationStream,
    Stream<LatLng> loadVehiclesNearbyUserLocationStream,
    Stream<PlaceSuggestion> loadVehiclesNearbyPlaceStream,
    Stream<Controllers.TrackedLinesAddedEvent> trackedLinesAddedStream,
    Stream<Set<Line>> trackedLinesRemovedStream,
  ) : super(MapState.initial()) {
    emitAllOn<UpdateVehicles>(
      nextStates: (event) => _mapVehiclesStates(
        vehiclesToProcess: Map<String, Vehicle>.fromIterable(
          event.vehicles,
          key: (vehicle) => vehicle.number,
          value: (vehicle) => vehicle,
        ),
        animatePositions: true,
      ),
    );

    emitAllOn<AddVehiclesOfLines>(nextStates: (event) {
      final lineSymbols = Map.fromIterables(
        event.lines.map((line) => line.symbol),
        event.lines,
      );
      final loadedAt = DateTime.now();
      return _newVehiclesStates(
        event.vehicles,
        sourceForVehicle: (vehicle) => MapVehicleSource.ofLine(
          line: lineSymbols[vehicle.symbol],
          loadedAt: loadedAt,
        ),
      );
    });

    emitAllOn<AddVehiclesInLocation>(nextStates: (event) {
      final loadedAt = DateTime.now();
      return _newVehiclesStates(
        event.vehicles,
        sourceForVehicle: (_) => MapVehicleSource.nearbyLocation(
          location: event.location,
          loadedAt: loadedAt,
        ),
      );
    });

    emitAllOn<AddVehiclesNearbyUserLocation>(nextStates: (event) {
      final loadedAt = DateTime.now();
      return _newVehiclesStates(
        event.vehicles,
        sourceForVehicle: (_) => MapVehicleSource.nearbyUserLocation(
          position: event.position,
          radius: event.radius,
          loadedAt: loadedAt,
        ),
      );
    });

    emitAllOn<AddVehiclesNearbyPlace>(nextStates: (event) {
      final loadedAt = DateTime.now();
      return _newVehiclesStates(
        event.vehicles,
        sourceForVehicle: (_) => MapVehicleSource.nearbyPlace(
          position: event.position,
          radius: event.radius,
          title: event.title,
          loadedAt: loadedAt,
        ),
      );
    });

    emitAllOn<CameraMoved>(
      nextStates: (event) => _mapVehiclesStates(
        updatedBounds: event.bounds,
        updatedZoom: event.zoom,
        selectedVehicleUpdate: event.byUser ? Deselect() : NoChange(),
      ),
    );

    emitAllOn<DeselectVehicle>(
      nextStates: (event) => _mapVehiclesStates(
        selectedVehicleUpdate: Deselect(),
      ),
    );

    emitAllOn<SelectVehicle>(
      nextStates: (event) => event.number == state.selectedVehicleNumber
          ? Stream.value(state)
          : _mapVehiclesStates(
              selectedVehicleUpdate: Select(number: event.number),
            ),
    );

    on<ClearMap>((event, emit) => emit(state.copyWith(trackedVehicles: {})));

    on<TrackedLinesRemoved>(
      (event, emit) => emit(state.withRemovedSource(
        (source) => source is OfLine && event.lines.contains(source.line),
      )),
    );

    on<RemoveSource>(
      (event, emit) => emit(state.withRemovedSource(
        (source) => source == event.source,
      )),
    );

    _subscriptions
      ..add(
        Stream.periodic(const Duration(seconds: 15))
            .where((_) => state.mapVehicles.isNotEmpty)
            .asyncMap(
              (_) => _vehiclesRepo.loadUpdatedVehicles(
                state.mapVehicles.values.map((tracked) => tracked.vehicle),
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

  Stream<MapState> _newVehiclesStates(
    Iterable<Vehicle> vehicles, {
    @required MapVehicleSource Function(Vehicle) sourceForVehicle,
  }) async* {
    final toProcess = state.allVehicles;
    final newVehiclesNumbers = <String>{};
    vehicles.forEach((vehicle) {
      toProcess[vehicle.number] = vehicle;
      newVehiclesNumbers.add(vehicle.number);
    });
    yield* _mapVehiclesStates(
      vehiclesToProcess: toProcess,
      newVehiclesData: _NewVehiclesData(newVehiclesNumbers, sourceForVehicle),
    );
  }

  Stream<MapState> _mapVehiclesStates({
    Map<String, Vehicle> vehiclesToProcess,
    MapSelectedVehicleUpdate selectedVehicleUpdate,
    bool animatePositions = false,
    LatLngBounds updatedBounds,
    double updatedZoom,
    _NewVehiclesData newVehiclesData,
  }) async* {
    vehiclesToProcess = vehiclesToProcess ?? state.allVehicles;
    updatedBounds = updatedBounds ?? state.bounds;
    updatedZoom = updatedZoom ?? state.zoom;

    selectedVehicleUpdate = selectedVehicleUpdate ?? NoChange();
    final selectedVehicleNumber = selectedVehicleUpdate.when(
      noChange: (_) => state.selectedVehicleNumber,
      deselect: (_) => null,
      select: (update) => update.number,
    );
    Vehicle updatedSelectedVehicle;

    final currentMapVehicles = state.mapVehicles;
    final processedMapVehicles = Map.of(currentMapVehicles);
    final clusterableMarkers = <String, ClusterableMarker>{};

    vehiclesToProcess.forEach((number, vehicle) {
      if (number == selectedVehicleNumber) {
        updatedSelectedVehicle = vehicle;
        return;
      }

      final currentMapVehicle = currentMapVehicles[number];
      if (!updatedBounds.containsLatLng(vehicle.lat, vehicle.lon)) {
        final sources = _updatedSources(
          currentSources: currentMapVehicle?.sources,
          newVehiclesData: newVehiclesData,
          vehicle: vehicle,
        );
        if (currentMapVehicle?.marker == null) {
          processedMapVehicles[number] = MapVehicle.withoutMarker(
            vehicle,
            sources: sources,
          );
        } else {
          final currentPosition = currentMapVehicle.marker.position;
          if (!updatedBounds.containsLatLng(
            currentPosition.latitude,
            currentPosition.longitude,
          )) {
            processedMapVehicles[number] = MapVehicle.withoutMarker(
              vehicle,
              sources: sources,
            );
          } else {
            clusterableMarkers[number] = ClusterableMarker.fromVehicle(
              vehicle,
              initialPosition: currentPosition,
            );
          }
        }
      } else {
        clusterableMarkers[number] = ClusterableMarker.fromVehicle(
          vehicle,
          initialPosition: currentMapVehicle?.marker?.position,
        );
      }
    });

    final fluster = await clusterableMarkers.fluster(
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
        final vehicle = vehiclesToProcess[clusterable.number];
        processedMapVehicles[clusterable.number] = MapVehicle.withMarker(
          vehicle,
          marker: marker,
          sources: _updatedSources(
            currentSources: currentMapVehicles[clusterable.number]?.sources,
            newVehiclesData: newVehiclesData,
            vehicle: vehicle,
          ),
        );
      });
    });

    if (animatePositions && updatedZoom > MapConstants.minAnimationZoom) {
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
              selectedVehicleUpdate: selectedVehicleUpdate,
              updatedSelectedVehicle: updatedSelectedVehicle,
            ),
          )
          .map((animated) {
            animated.forEach((vehicleMarker) {
              final vehicle = vehiclesToProcess[vehicleMarker.number];
              processedMapVehicles[vehicleMarker.number] =
                  MapVehicle.withMarker(
                vehicle,
                marker: vehicleMarker.marker,
                sources: _updatedSources(
                  currentSources:
                      currentMapVehicles[vehicleMarker.number]?.sources,
                  newVehiclesData: newVehiclesData,
                  vehicle: vehicle,
                ),
              );
            });
            return state.copyWith(
              trackedVehicles: processedMapVehicles,
              bounds: updatedBounds,
              zoom: updatedZoom,
              selectedVehicleUpdate: selectedVehicleUpdate,
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
        final vehicle = vehiclesToProcess[nonClustered.number];
        processedMapVehicles[nonClustered.number] = MapVehicle.withMarker(
          vehicle,
          marker: marker,
          sources: _updatedSources(
            currentSources: currentMapVehicles[nonClustered.number]?.sources,
            newVehiclesData: newVehiclesData,
            vehicle: vehicle,
          ),
        );
      });

      if (selectedVehicleNumber != null) {
        final selectedMarker = await state.selectedMarker(
          selectedVehicleUpdate: selectedVehicleUpdate,
          updatedSelectedVehicle: updatedSelectedVehicle,
        );
        final vehicle = vehiclesToProcess[selectedVehicleNumber];
        processedMapVehicles[selectedVehicleNumber] = MapVehicle.withMarker(
          vehicle,
          marker: selectedMarker.googleMapMarker(
            onTap: () => nonClusteredMarkerTapped(selectedVehicleNumber),
          ),
          sources: _updatedSources(
            currentSources: currentMapVehicles[selectedVehicleNumber]?.sources,
            newVehiclesData: newVehiclesData,
            vehicle: vehicle,
          ),
        );
      }

      yield state.copyWith(
        trackedVehicles: processedMapVehicles,
        bounds: updatedBounds,
        zoom: updatedZoom,
        selectedVehicleUpdate: selectedVehicleUpdate,
      );
    }
  }

  Set<MapVehicleSource> _updatedSources({
    @required _NewVehiclesData newVehiclesData,
    @required Vehicle vehicle,
    @required Set<MapVehicleSource> currentSources,
  }) {
    return newVehiclesData != null &&
            newVehiclesData.sourceForVehicle != null &&
            newVehiclesData.vehicleNumbers.contains(vehicle.number)
        ? {newVehiclesData.sourceForVehicle(vehicle), ...?currentSources}
        : currentSources;
  }

  void _loadVehiclesOfLines(Controllers.TrackedLinesAddedEvent event) {
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
    if (source is OfLine) _untrackLinesSink.add({source.line});
    add(MapEvent.removeSource(source: source));
  }

  Stream<Set<MapVehicleSource>> get mapVehicleSourcesStream {
    return stream
        .map((state) => state.mapVehicles)
        .startWith(state.mapVehicles)
        .distinct()
        .map((mapVehicles) {
      final sources = <MapVehicleSource>{};
      mapVehicles.values.forEach((tracked) {
        sources.addAll(tracked.sources);
      });
      return sources;
    });
  }

  Stream<Set<Marker>> get markers {
    return stream.map(
      (state) => state.mapVehicles.values
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
  Map<String, Vehicle> get allVehicles =>
      mapVehicles.map((number, tracked) => MapEntry(number, tracked.vehicle));

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

    final current = mapVehicles[number];
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
    mapVehicles.forEach((number, tracked) {
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

class _NewVehiclesData {
  final Set<String> vehicleNumbers;
  final MapVehicleSource Function(Vehicle) sourceForVehicle;

  _NewVehiclesData(this.vehicleNumbers, this.sourceForVehicle);
}

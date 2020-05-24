import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/model/location.dart';
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
  final Sink<Set<Line>> _loadingVehiclesOfLinesFailedSink;
  final Sink<Object> _untrackAllLinesSink;

  final List<StreamSubscription> _subscriptions = [];

  final StreamController<MapSignal> _signals = StreamController.broadcast();
  Stream<MapSignal> get signals => _signals.stream;

  MapBloc(
    this._vehiclesRepo,
    this._preferences,
    this._loadingVehiclesOfLinesFailedSink,
    this._untrackAllLinesSink,
    Stream<Location> loadVehiclesInLocationStream,
    Stream<LatLng> loadVehiclesNearbyStream,
    Stream<Set<Line>> trackedLinesAddedStream,
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
      ..add(
        Stream.periodic(const Duration(milliseconds: 16))
            .where(
              (_) => state.trackedVehicles.values
                  .any((tracked) => tracked.animation.stage.isAnimating),
            )
            .listen((_) => add(MapEvent.animateVehicles())),
      )
      ..add(loadVehiclesInLocationStream.listen(loadVehiclesInLocation))
      ..add(
        loadVehiclesNearbyStream.listen(
          (position) => loadVehiclesNearby(position, radiusInMeters: 1000),
        ),
      )
      ..add(trackedLinesAddedStream.listen(trackedLinesAdded))
      ..add(
        trackedLinesRemovedStream
            .listen((lines) => add(MapEvent.trackedLinesRemoved(lines: lines))),
      );
  }

  @override
  MapState get initialState => MapState.initial();

  @override
  Stream<MapState> mapEventToState(MapEvent event) async* {
    yield event.when(
      clearMap: (_) => state.copyWith(trackedVehicles: {}),
      updateVehicles: (evt) {
        final updatedVehicles = Map.of(state.trackedVehicles);
        evt.vehicles.forEach((vehicle) {
          final tracked = updatedVehicles[vehicle.number];
          if (tracked != null) {
            updatedVehicles[vehicle.number] = tracked.withUpdatedVehicle(
              vehicle,
              bounds: state.bounds,
              zoom: state.zoom,
            );
          }
        });
        return state.copyWith(trackedVehicles: updatedVehicles);
      },
      addVehiclesOfLines: (evt) {
        final lineSymbols = Map.fromIterables(
          evt.lines.map((line) => line.symbol),
          evt.lines,
        );
        final loadedAt = DateTime.now();
        return state.withNewVehicles(
          evt.vehicles,
          sourceForVehicle: (vehicle) => MapVehicleSource.ofLine(
            line: lineSymbols[vehicle.symbol],
            loadedAt: loadedAt,
          ),
        );
      },
      addVehiclesInLocation: (evt) {
        final loadedAt = DateTime.now();
        return state.withNewVehicles(
          evt.vehicles,
          sourceForVehicle: (_) => MapVehicleSource.nearbyLocation(
            location: evt.location,
            loadedAt: loadedAt,
          ),
        );
      },
      addVehiclesNearbyPosition: (evt) {
        final loadedAt = DateTime.now();
        return state.withNewVehicles(
          evt.vehicles,
          sourceForVehicle: (_) => MapVehicleSource.nearbyPosition(
            position: evt.position,
            radius: evt.radius,
            loadedAt: loadedAt,
          ),
        );
      },
      animateVehicles: (_) => state.copyWith(
        trackedVehicles: state.trackedVehicles.map(
          (number, tracked) => tracked.animation.stage.isAnimating
              ? MapEntry(
                  number,
                  tracked.toNextStage(bounds: state.bounds, zoom: state.zoom),
                )
              : MapEntry(number, tracked),
        ),
      ),
      cameraMoved: (evt) => state.copyWith(zoom: evt.zoom, bounds: evt.bounds),
      trackedLinesRemoved: (evt) => state.withRemovedSource(
        (source) => source is OfLine && evt.lines.contains(source.line),
      ),
      removeSource: (evt) => state.withRemovedSource(
        (source) => source == evt.source,
      ),
      selectVehicle: (evt) => evt.number == state.selectedVehicleNumber
          ? state
          : state.copyWith(selectedVehicleNumber: evt.number),
      deselectVehicle: (_) => state.withNoSelectedVehicle,
    );
  }

  @override
  Future<void> close() async {
    await Future.wait([
      ..._subscriptions.map((subscription) => subscription.cancel()),
      _signals.close(),
    ]);
    return super.close();
  }

  Stream<List<IconifiedMarker>> get markers {
    return asyncMap((state) => state.markers);
  }

  void trackedLinesAdded(Set<Line> lines) {
    _loadVehicles(
      loadingMsg:
          'Loading vehicles of ${lines.length} ${lines.length > 1 ? 'lines' : 'line'}...',
      emptyResultErrorMsg: 'No vehicles of requested lines were found.',
      loadVehicles: () => _vehiclesRepo.loadVehiclesOfLines(lines),
      successEvent: (vehicles) => MapEvent.addVehiclesOfLines(
        vehicles: vehicles,
        lines: lines,
      ),
      onFailure: (_) => _loadingVehiclesOfLinesFailedSink.add(lines),
    );
  }

  void loadVehiclesInLocation(Location location) {
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

  void loadVehiclesNearby(LatLng position, {@required double radiusInMeters}) {
    _loadVehicles(
      loadingMsg: 'Loading nearby vehicles...',
      emptyResultErrorMsg: 'No vehicles were found nearby given location.',
      loadVehicles: () => _vehiclesRepo.loadVehiclesNearby(
        position,
        radiusInMeters: radiusInMeters,
      ),
      successEvent: (vehicles) => MapEvent.addVehiclesNearbyPosition(
        vehicles: vehicles,
        position: position,
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
  }) async {
    _signals.add(MapSignal.loading(message: loadingMsg));
    final result = await loadVehicles();
    result.asyncWhen(
      success: (success) async {
        final vehicles = success.data;
        if (vehicles.isEmpty) {
          _signals.add(MapSignal.loadingError(message: emptyResultErrorMsg));
        } else {
          add(successEvent(vehicles));
          final zoomToLoadedMarkersBounds = await _preferences.getBool(
            Preferences.zoomToLoadedMarkersBounds.key,
          );
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
        _signals.add(
          MapSignal.loadingError(message: 'Loading error occurred.'),
        );
        failure.logError();
        onFailure?.call(failure);
      },
    );
  }

  void cameraMoved({
    @required LatLngBounds bounds,
    @required double zoom,
  }) {
    add(MapEvent.cameraMoved(bounds: bounds, zoom: zoom));
  }

  void selectVehicle(String number) {
    add(MapEvent.selectVehicle(number: number));
  }

  void mapTapped() => add(MapEvent.deselectVehicle());

  void clearMap() {
    _untrackAllLinesSink.add(Object());
    add(MapEvent.clearMap());
  }

  void removeSource(MapVehicleSource source) {
    add(MapEvent.removeSource(source: source));
  }
}

extension _MapStateExt on MapState {
  Future<List<IconifiedMarker>> get markers async {
    if (trackedVehicles.isEmpty) return null;
    final fluster = await _markersToCluster.fluster(
      minZoom: MapConstants.minClusterZoom,
      maxZoom: MapConstants.maxClusterZoom,
    );
    final markers = await fluster.getMarkers(
      currentZoom: zoom,
      clusterColor: Colors.blue,
      clusterTextColor: Colors.white,
    );
    if (selectedVehicleNumber == null ||
        !trackedVehicles.containsKey(selectedVehicleNumber)) {
      return markers;
    } else {
      final selected = trackedVehicles[selectedVehicleNumber];
      final position = selected.animation.stage.current;
      return List.of(markers)
        ..add(
          IconifiedMarker(
            ClusterableMarker(
              symbol: selected.vehicle.symbol,
              id: selectedVehicleNumber,
              lat: position.latitude,
              lng: position.longitude,
            ),
            icon: await markerBitmap(
              symbol: selected.vehicle.symbol,
              width: MapConstants.markerWidth,
              height: MapConstants.markerHeight,
              imageAsset: await rootBundle.loadUiImage(
                ImageAssets.selectedMarker,
              ),
            ),
          ),
        );
    }
  }

  Map<String, ClusterableMarker> get _markersToCluster {
    final markers = Map.fromEntries(
      trackedVehicles.entries.where(
        (entry) => bounds.containsLatLng(entry.value.animation.stage.current),
      ),
    ).map(
      (number, tracked) {
        final position = tracked.animation.stage.current;
        return MapEntry(
          number,
          ClusterableMarker(
            id: number,
            lat: position.latitude,
            lng: position.longitude,
            number: number,
            symbol: tracked.vehicle.symbol,
          ),
        );
      },
    );
    if (selectedVehicleNumber != null) markers.remove(selectedVehicleNumber);
    return markers;
  }

  MapState withNewVehicles(
    Iterable<Vehicle> vehicles, {
    @required MapVehicleSource Function(Vehicle) sourceForVehicle,
  }) {
    final updatedVehicles = Map.of(trackedVehicles);
    vehicles.forEach((vehicle) {
      final tracked = updatedVehicles[vehicle.number];
      if (tracked != null) {
        updatedVehicles[vehicle.number] = tracked.withUpdatedVehicle(
          vehicle,
          bounds: bounds,
          zoom: zoom,
          sources: tracked.sources..add(sourceForVehicle(vehicle)),
        );
      } else {
        updatedVehicles[vehicle.number] = MapVehicle.fromNewlyLoadedVehicle(
          vehicle,
          source: sourceForVehicle(vehicle),
        );
      }
    });
    return copyWith(trackedVehicles: updatedVehicles);
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

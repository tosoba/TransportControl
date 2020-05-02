import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:super_enum/super_enum.dart';
import 'package:transport_control/model/line.dart';
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
  final void Function(Set<Line>) _loadingVehiclesOfLinesFailed;

  StreamSubscription<Result<List<Vehicle>>> _vehicleUpdatesSubscription;
  StreamSubscription<dynamic> _vehiclesAnimationSubscription;

  StreamController<MapSignal> _signals = StreamController();
  Stream<MapSignal> get signals {
    return _signals.stream.distinct((prev, next) => prev == next);
  }

  MapBloc(
    this._vehiclesRepo,
    this._loadingVehiclesOfLinesFailed,
    this._preferences,
  ) {
    _vehicleUpdatesSubscription = Stream.periodic(const Duration(seconds: 15))
        .where((_) => state.trackedVehicles.isNotEmpty)
        .asyncMap(
          (_) => _vehiclesRepo.loadVehicles(
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
        );

    _vehiclesAnimationSubscription =
        Stream.periodic(const Duration(milliseconds: 16))
            .where(
              (_) => state.trackedVehicles.values
                  .any((tracked) => tracked.animation.stage.isAnimating),
            )
            .listen((_) => add(MapEvent.animateVehicles()));
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
        final updatedVehicles = Map.of(state.trackedVehicles);
        final lineSymbols = Map.fromIterables(
          evt.lines.map((line) => line.symbol),
          evt.lines,
        );
        evt.vehicles.forEach((vehicle) {
          final tracked = updatedVehicles[vehicle.number];
          if (tracked != null) {
            updatedVehicles[vehicle.number] =
                tracked.withUpdatedVehicle(vehicle,
                    bounds: state.bounds,
                    zoom: state.zoom,
                    sources: tracked.sources
                      ..add(
                        MapVehicleSource.allOfLine(
                            line: lineSymbols[vehicle.symbol]),
                      ));
          } else {
            updatedVehicles[vehicle.number] = MapVehicle.fromNewlyLoadedVehicle(
              vehicle,
              source:
                  MapVehicleSource.allOfLine(line: lineSymbols[vehicle.symbol]),
            );
          }
        });
        return state.copyWith(trackedVehicles: updatedVehicles);
      },
      addVehiclesInBounds: (evt) {
        final updatedVehicles = Map.of(state.trackedVehicles);
        evt.vehicles.forEach((vehicle) {
          final tracked = updatedVehicles[vehicle.number];
          if (tracked != null) {
            updatedVehicles[vehicle.number] = tracked.withUpdatedVehicle(
              vehicle,
              bounds: state.bounds,
              zoom: state.zoom,
              sources: tracked.sources
                ..add(MapVehicleSource.allInBounds(bounds: evt.bounds)),
            );
          } else {
            updatedVehicles[vehicle.number] = MapVehicle.fromNewlyLoadedVehicle(
              vehicle,
              source: MapVehicleSource.allInBounds(bounds: evt.bounds),
            );
          }
        });
        return state.copyWith(trackedVehicles: updatedVehicles);
      },
      animateVehicles: (_) => state.copyWith(
        trackedVehicles: state.trackedVehicles.map(
          (number, tracked) => tracked.animation.stage.isAnimating
              ? MapEntry(
                  number,
                  tracked.toNextStage(
                    bounds: state.bounds,
                    zoom: state.zoom,
                  ),
                )
              : MapEntry(number, tracked),
        ),
      ),
      cameraMoved: (evt) => state.copyWith(zoom: evt.zoom, bounds: evt.bounds),
      trackedLinesRemoved: (evt) {
        final updatedVehicles = Map<String, MapVehicle>();
        state.trackedVehicles.forEach((number, tracked) {
          final sources = tracked.sources;
          final loadedByTrackingAllOfLine = sources.any(
            (source) => source is AllOfLine && evt.lines.contains(source.line),
          );
          if (!loadedByTrackingAllOfLine) {
            updatedVehicles[number] = tracked;
          } else if (sources.length == 1) {
            return;
          } else {
            updatedVehicles[number] = tracked.withRemovedSource(sources.first);
          }
        });
        return state.copyWith(trackedVehicles: updatedVehicles);
      },
      selectVehicle: (evt) => evt.number == state.selectedVehicleNumber
          ? state.withNoSelectedVehicle
          : state.copyWith(selectedVehicleNumber: evt.number),
      deselectVehicle: (_) => state.withNoSelectedVehicle,
    );
  }

  @override
  Future<void> close() async {
    await Future.wait([
      _vehicleUpdatesSubscription.cancel(),
      _vehiclesAnimationSubscription.cancel(),
      _signals.close(),
    ]);
    return super.close();
  }

  Stream<List<IconifiedMarker>> get markers {
    return asyncMap((state) => state.markers);
  }

  void trackedLinesAdded(Set<Line> lines) async {
    _loadVehicles(
      loadingMsg:
          'Loading vehicles of ${lines.length} ${lines.length > 1 ? 'lines' : 'line'}...',
      emptyResultErrorMsg: 'No vehicles of requested lines were found.',
      loadVehicles: () => _vehiclesRepo.loadVehiclesOfLines(lines),
      successEvent: (vehicles) => MapEvent.addVehiclesOfLines(
        vehicles: vehicles,
        lines: lines,
      ),
      onFailure: (_) => _loadingVehiclesOfLinesFailed(lines),
    );
  }

  void loadVehiclesInBounds(LatLngBounds bounds) async {
    _loadVehicles(
      loadingMsg: 'Loading vehicles in bounds...',
      emptyResultErrorMsg: 'No vehicles were found in bounds.',
      loadVehicles: () => _vehiclesRepo.loadVehiclesInBounds(bounds),
      successEvent: (vehicles) => MapEvent.addVehiclesInBounds(
        vehicles: vehicles,
        bounds: bounds,
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

  void trackedLinesRemoved(Set<Line> lines) {
    add(MapEvent.trackedLinesRemoved(lines: lines));
  }

  void cameraMoved({
    @required LatLngBounds bounds,
    @required double zoom,
  }) {
    add(MapEvent.cameraMoved(bounds: bounds, zoom: zoom));
  }

  void markerTapped(String number) {
    add(MapEvent.selectVehicle(number: number));
  }

  void mapTapped() {
    add(MapEvent.deselectVehicle());
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
}

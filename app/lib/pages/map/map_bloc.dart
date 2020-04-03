import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:super_enum/super_enum.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/model/result.dart';
import 'package:transport_control/model/vehicle.dart';
import 'package:transport_control/pages/map/map_constants.dart';
import 'package:transport_control/pages/map/map_event.dart';
import 'package:transport_control/pages/map/map_marker.dart';
import 'package:transport_control/pages/map/map_state.dart';
import 'package:transport_control/pages/map/animated_vehicle.dart';
import 'package:transport_control/pages/map/vehicle_source.dart';
import 'package:transport_control/repo/vehicles_repo.dart';
import 'package:transport_control/util/fluster_ext.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final VehiclesRepo _vehiclesRepo;

  StreamSubscription<Result<List<Vehicle>>> _vehicleUpdatesSubscription;
  StreamSubscription<dynamic> _vehiclesAnimationSubscription;

  MapBloc(this._vehiclesRepo) {
    _vehicleUpdatesSubscription = Stream.periodic(const Duration(seconds: 15))
        .where((_) => state.trackedVehiclesMap.isNotEmpty)
        .asyncExpand(
          (_) => Stream.fromFuture(
            _vehiclesRepo.loadVehicles(
              state.trackedVehiclesMap.values
                  .map((animated) => animated.vehicle),
            ),
          ),
        )
        .listen(_handleVehiclesUpdateResult);

    _vehiclesAnimationSubscription =
        Stream.periodic(const Duration(milliseconds: 16))
            .where(
              (_) => state.trackedVehiclesMap.values
                  .any((animated) => animated.stage.isAnimating),
            )
            .listen((_) => add(MapEvent.animateVehicles()));
  }

  @override
  MapState get initialState => MapState.empty();

  @override
  Stream<MapState> mapEventToState(MapEvent event) async* {
    yield event.when(
      clearMap: (_) => MapState.empty(),
      addTrackedLines: (addTrackedLinesEvent) {
        _vehiclesRepo
            .loadVehiclesOfLines(
              addTrackedLinesEvent.lines,
            )
            .then(
              (result) => _handleVehiclesOfLinesResult(
                result,
                lines: addTrackedLinesEvent.lines,
              ),
            );
        return state.copyWith(
          trackedLines: state.trackedLines.union(addTrackedLinesEvent.lines),
        );
      },
      updateVehicles: (updateVehiclesEvent) {
        final updatedVehiclesMap = Map.of(state.trackedVehiclesMap);
        updateVehiclesEvent.vehicles.forEach((vehicle) {
          final animated = updatedVehiclesMap[vehicle.number];
          if (animated != null) {
            updatedVehiclesMap[vehicle.number] = animated.withUpdatedVehicle(
              vehicle,
              currentBounds: state.bounds,
              currentZoom: state.zoom,
            );
          }
        });
        return state.copyWith(trackedVehiclesMap: updatedVehiclesMap);
      },
      addVehiclesOfLines: (vehiclesOfLinesAddedEvent) {
        final updatedVehiclesMap = Map.of(state.trackedVehiclesMap);
        final lineSymbols = Map.fromIterables(
          vehiclesOfLinesAddedEvent.lines.map((line) => line.symbol),
          vehiclesOfLinesAddedEvent.lines,
        );
        vehiclesOfLinesAddedEvent.vehicles.forEach((vehicle) {
          final animated = updatedVehiclesMap[vehicle.number];
          if (animated != null) {
            updatedVehiclesMap[vehicle.number] = animated.withUpdatedVehicle(
              vehicle,
              currentBounds: state.bounds,
              currentZoom: state.zoom,
              sources: animated.sources
                ..add(
                  VehicleSource.allOfLine(line: lineSymbols[vehicle.symbol]),
                ),
            );
          } else {
            updatedVehiclesMap[vehicle.number] =
                AnimatedVehicle.fromNewlyLoadedVehicle(
              vehicle,
              source: VehicleSource.allOfLine(
                line: lineSymbols[vehicle.symbol],
              ),
            );
          }
        });
        return state.copyWith(trackedVehiclesMap: updatedVehiclesMap);
      },
      animateVehicles: (_) {
        final updatedVehiclesMap = state.trackedVehiclesMap.map(
          (number, animated) => animated.stage.isAnimating
              ? MapEntry(
                  number,
                  animated.toNextStage(
                    currentBounds: state.bounds,
                    currentZoom: state.zoom,
                  ),
                )
              : MapEntry(number, animated),
        );
        return state.copyWith(trackedVehiclesMap: updatedVehiclesMap);
      },
      cameraMoved: (cameraMovedEvent) => state.copyWith(
        zoom: cameraMovedEvent.zoom,
        bounds: cameraMovedEvent.bounds,
      ),
      removeTrackedLines: (removeTrackedLinesEvent) {
        final updatedVehiclesMap = Map();
        state.trackedVehiclesMap.forEach((number, animated) {
          final sources = animated.sources;
          final loadedByTrackingAllOfLine = sources.any(
            (source) =>
                source is AllOfLine &&
                removeTrackedLinesEvent.lines.contains(source.line),
          );
          if (!loadedByTrackingAllOfLine) {
            updatedVehiclesMap[number] = animated;
          } else if (sources.length == 1) {
            return;
          } else {
            updatedVehiclesMap[number] = animated.withRemovedSource(
              sources.first,
            );
          }
        });
        final updatedTrackedLines = Set.of(state.trackedLines)
          ..removeAll(removeTrackedLinesEvent.lines);
        return state.copyWith(
          trackedVehiclesMap: updatedVehiclesMap,
          trackedLines: updatedTrackedLines,
        );
      },
    );
  }

  void _handleVehiclesUpdateResult(Result<List<Vehicle>> result) {
    result.when(
      success: (success) => add(
        MapEvent.updateVehicles(vehicles: success.data),
      ),
      failure: (failure) => failure.logError(),
    );
  }

  void _handleVehiclesOfLinesResult(
    Result<List<Vehicle>> result, {
    @required Set<Line> lines,
  }) {
    result.when(
      success: (success) => add(
        MapEvent.addVehiclesOfLines(vehicles: success.data, lines: lines),
      ),
      failure: (failure) => failure.logError(),
    );
  }

  @override
  Future<void> close() async {
    await Future.wait([
      _vehicleUpdatesSubscription.cancel(),
      _vehiclesAnimationSubscription.cancel()
    ]);
    return super.close();
  }

  Stream<Set<Line>> get trackedLines => map((state) => state.trackedLines);

  Stream<Set<Marker>> get markers {
    return asyncExpand(
      (state) => Stream.fromFuture(
        state.trackedVehiclesMap.isEmpty
            ? null
            : flusterFromMarkers(
                    state.trackedVehiclesMap
                        .map(
                          (number, animated) => MapEntry(
                            number,
                            MapMarker(
                              id: '${number}_${animated.vehicle.symbol}',
                              position: LatLng(
                                animated.stage.current.latitude,
                                animated.stage.current.longitude,
                              ),
                            ),
                          ),
                        )
                        .values
                        .toList(),
                    minZoom: MapConstants.minClusterZoom,
                    maxZoom: MapConstants.maxClusterZoom)
                .then(
                  (fluster) => fluster == null
                      ? Future.value(<Marker>[])
                      : fluster.getClusterMarkers(
                          currentZoom: state.zoom,
                          clusterColor: Colors.blue,
                          clusterTextColor: Colors.white,
                        ),
                )
                .then((markers) => markers.toSet()),
      ),
    );
  }

  void addTrackedLines(Set<Line> lines) {
    add(MapEvent.addTrackedLines(lines: lines));
  }

  void removeTrackedLines(Set<Line> lines) {
    add(MapEvent.removeTrackedLines(lines: lines));
  }

  void cameraMoved({
    LatLngBounds bounds,
    double zoom,
  }) {
    add(MapEvent.cameraMoved(bounds: bounds, zoom: zoom));
  }
}

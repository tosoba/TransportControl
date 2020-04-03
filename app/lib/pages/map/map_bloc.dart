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
import 'package:transport_control/pages/map/map_vehicle.dart';
import 'package:transport_control/pages/map/map_vehicle_source.dart';
import 'package:transport_control/repo/vehicles_repo.dart';
import 'package:transport_control/util/fluster_ext.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final VehiclesRepo _vehiclesRepo;

  StreamSubscription<Result<List<Vehicle>>> _vehicleUpdatesSubscription;
  StreamSubscription<dynamic> _vehiclesAnimationSubscription;

  MapBloc(this._vehiclesRepo) {
    _vehicleUpdatesSubscription = Stream.periodic(const Duration(seconds: 15))
        .where((_) => state.trackedVehicles.isNotEmpty)
        .asyncExpand(
          (_) => Stream.fromFuture(
            _vehiclesRepo.loadVehicles(
              state.trackedVehicles.values.map((tracked) => tracked.vehicle),
            ),
          ),
        )
        .listen(_handleVehiclesUpdateResult);

    _vehiclesAnimationSubscription =
        Stream.periodic(const Duration(milliseconds: 16))
            .where(
              (_) => state.trackedVehicles.values
                  .any((tracked) => tracked.animation.stage.isAnimating),
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
        final updatedVehicles = Map.of(state.trackedVehicles);
        updateVehiclesEvent.vehicles.forEach((vehicle) {
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
      addVehiclesOfLines: (vehiclesOfLinesAddedEvent) {
        final updatedVehicles = Map.of(state.trackedVehicles);
        final lineSymbols = Map.fromIterables(
          vehiclesOfLinesAddedEvent.lines.map((line) => line.symbol),
          vehiclesOfLinesAddedEvent.lines,
        );
        vehiclesOfLinesAddedEvent.vehicles.forEach((vehicle) {
          final tracked = updatedVehicles[vehicle.number];
          if (tracked != null) {
            updatedVehicles[vehicle.number] = tracked.withUpdatedVehicle(
              vehicle,
              bounds: state.bounds,
              zoom: state.zoom,
              sources: tracked.sources
                ..add(
                  MapVehicleSource.allOfLine(line: lineSymbols[vehicle.symbol]),
                ),
            );
          } else {
            updatedVehicles[vehicle.number] =
                MapVehicle.fromNewlyLoadedVehicle(
              vehicle,
              source: MapVehicleSource.allOfLine(
                line: lineSymbols[vehicle.symbol],
              ),
            );
          }
        });
        return state.copyWith(trackedVehicles: updatedVehicles);
      },
      animateVehicles: (_) {
        final updatedVehicles = state.trackedVehicles.map(
          (number, tracked) => tracked.animation.stage.isAnimating
              ? MapEntry(
                  number,
                  tracked.toNextStage(
                    bounds: state.bounds,
                    zoom: state.zoom,
                  ),
                )
              : MapEntry(number, tracked),
        );
        return state.copyWith(trackedVehicles: updatedVehicles);
      },
      cameraMoved: (cameraMovedEvent) => state.copyWith(
        zoom: cameraMovedEvent.zoom,
        bounds: cameraMovedEvent.bounds,
      ),
      removeTrackedLines: (removeTrackedLinesEvent) {
        final updatedVehicles = Map();
        state.trackedVehicles.forEach((number, tracked) {
          final sources = tracked.sources;
          final loadedByTrackingAllOfLine = sources.any(
            (source) =>
                source is AllOfLine &&
                removeTrackedLinesEvent.lines.contains(source.line),
          );
          if (!loadedByTrackingAllOfLine) {
            updatedVehicles[number] = tracked;
          } else if (sources.length == 1) {
            return;
          } else {
            updatedVehicles[number] = tracked.withRemovedSource(
              sources.first,
            );
          }
        });
        final updatedTrackedLines = Set.of(state.trackedLines)
          ..removeAll(removeTrackedLinesEvent.lines);
        return state.copyWith(
          trackedVehicles: updatedVehicles,
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
        state.trackedVehicles.isEmpty
            ? null
            : flusterFromMarkers(
                    state.trackedVehicles
                        .map(
                          (number, tracked) => MapEntry(
                            number,
                            MapMarker(
                              id: '${number}_${tracked.vehicle.symbol}',
                              position: LatLng(
                                tracked.animation.stage.current.latitude,
                                tracked.animation.stage.current.longitude,
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

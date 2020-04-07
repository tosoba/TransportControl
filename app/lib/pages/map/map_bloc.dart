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
  final void Function(Set<Line>) _loadingVehiclesOfLinesFailed;

  StreamSubscription<Result<List<Vehicle>>> _vehicleUpdatesSubscription;
  StreamSubscription<dynamic> _vehiclesAnimationSubscription;

  MapBloc(this._vehiclesRepo, this._loadingVehiclesOfLinesFailed) {
    _vehicleUpdatesSubscription = Stream.periodic(const Duration(seconds: 15))
        .where((_) => state.trackedVehicles.isNotEmpty)
        .asyncExpand(
          (_) => Stream.fromFuture(
            _vehiclesRepo.loadVehicles(
              state.trackedVehicles.values.map((tracked) => tracked.vehicle),
            ),
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
  MapState get initialState => MapState.empty();

  @override
  Stream<MapState> mapEventToState(MapEvent event) async* {
    yield event.when(
      clearMap: (_) => MapState.empty(),
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
            updatedVehicles[vehicle.number] = MapVehicle.fromNewlyLoadedVehicle(
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
      trackedLinesRemoved: (removeTrackedLinesEvent) {
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
        return state.copyWith(trackedVehicles: updatedVehicles);
      },
      selectVehicle: (selectVehicleEvent) =>
          selectVehicleEvent.number == state.selectedVehicleNumber
              ? state.withNoSelectedVehicle
              : state.copyWith(
                  selectedVehicleNumber: selectVehicleEvent.number,
                ),
      deselectVehicle: (deselectVehicleEvent) => state.withNoSelectedVehicle,
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

  Stream<List<MapMarker>> get markers {
    return asyncExpand((state) => Stream.fromFuture(state.markers));
  }

  void trackedLinesAdded(Set<Line> lines) {
    _vehiclesRepo
        .loadVehiclesOfLines(
          lines,
        )
        .then(
          (result) => result.when(
            success: (success) => add(
              MapEvent.addVehiclesOfLines(vehicles: success.data, lines: lines),
            ),
            failure: (failure) {
              failure.logError();
              _loadingVehiclesOfLinesFailed(lines);
            },
          ),
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

  void markerTapped(String id) {
    add(MapEvent.selectVehicle(number: id.substring(0, id.indexOf('_'))));
  }

  void mapTapped() {
    add(MapEvent.deselectVehicle());
  }
}

extension _MapStateExt on MapState {
  Future<List<MapMarker>> get markers {
    return trackedVehicles.isEmpty
        ? null
        : flusterFromMarkers(
            _markersToCluster,
            minZoom: MapConstants.minClusterZoom,
            maxZoom: MapConstants.maxClusterZoom,
          ).then(
            (fluster) {
              return fluster == null
                  ? Future.value(<MapMarker>[])
                  : fluster.getMarkers(
                      currentZoom: zoom,
                      clusterColor: Colors.blue,
                      clusterTextColor: Colors.white,
                    );
            },
          ).then(
            (markers) async {
              if (selectedVehicleNumber == null ||
                  !trackedVehicles.containsKey(selectedVehicleNumber)) {
                return markers;
              } else {
                final selected = trackedVehicles[selectedVehicleNumber];
                final position = selected.animation.stage.current;
                return List.of(markers)
                  ..add(
                    MapMarker(
                      id: '${selectedVehicleNumber}_${selected.vehicle.symbol}',
                      position: LatLng(position.latitude, position.longitude),
                      icon: await markerBitmap(
                        symbol: selected.vehicle.symbol,
                        width: MapConstants.markerWidth,
                        height: MapConstants.markerHeight,
                        imageAsset: await loadUiImageFromAsset(
                          'assets/img/selected_marker.png',
                        ),
                      ),
                    ),
                  );
              }
            },
          );
  }

  List<MapMarker> get _markersToCluster {
    final markers = trackedVehicles.map(
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
    );
    if (selectedVehicleNumber != null) markers.remove(selectedVehicleNumber);
    return markers.values.toList();
  }
}

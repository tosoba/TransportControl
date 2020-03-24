import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:super_enum/super_enum.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/model/result.dart';
import 'package:transport_control/model/vehicle.dart';
import 'package:transport_control/pages/map/map_event.dart';
import 'package:transport_control/pages/map/map_state.dart';
import 'package:transport_control/pages/map/animated_vehicle.dart';
import 'package:transport_control/repo/vehicles_repo.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final VehiclesRepo _vehiclesRepo;

  final Duration _vehiclesUpdateInterval = const Duration(seconds: 15);
  StreamSubscription<Result<List<Vehicle>>> _vehicleUpdatesSubscription;

  final Duration _vehiclesAnimationInterval = const Duration(milliseconds: 16);
  StreamSubscription<dynamic> _vehiclesAnimationSubscription;

  MapBloc(this._vehiclesRepo) {
    _vehicleUpdatesSubscription = Stream.periodic(_vehiclesUpdateInterval)
        .where((_) => state.trackedVehiclesMap.isNotEmpty)
        .asyncExpand(
          (_) => Stream.fromFuture(
            _vehiclesRepo.loadVehicles(
              state.trackedVehiclesMap.values
                  .map((animated) => animated.vehicle),
            ),
          ),
        )
        .listen(_handleVehiclesResult);

    _vehiclesAnimationSubscription = Stream.periodic(_vehiclesAnimationInterval)
        .where(
          (_) => state.trackedVehiclesMap.values
              .any((animated) => animated.stage.isAnimating),
        )
        .listen((_) => add(MapEvent.vehiclesAnimated()));
  }

  @override
  MapState get initialState => MapState.empty();

  @override
  Stream<MapState> mapEventToState(MapEvent event) async* {
    yield event.when(
      clearMap: (_) => MapState.empty(),
      trackedLinesAdded: (linesAddedEvent) {
        _vehiclesRepo
            .loadVehiclesOfLines(linesAddedEvent.lines)
            .then(_handleVehiclesResult);
        return state.copyWith(
          trackedLines: state.trackedLines.union(linesAddedEvent.lines),
        );
      },
      vehiclesAdded: (vehiclesAddedEvent) {
        final updatedVehiclesMap = Map.of(state.trackedVehiclesMap);
        vehiclesAddedEvent.vehicles.forEach((vehicle) {
          final animatedVehicle = updatedVehiclesMap[vehicle.number];
          if (animatedVehicle != null) {
            updatedVehiclesMap[vehicle.number] = AnimatedVehicle.fromUpdated(
              vehicle,
              previous: animatedVehicle.stage,
              currentBounds: state.bounds,
              currentZoom: state.zoom,
            );
          } else {
            updatedVehiclesMap[vehicle.number] =
                AnimatedVehicle.fromNewlyLoaded(vehicle);
          }
        });
        return state.copyWith(trackedVehiclesMap: updatedVehiclesMap);
      },
      vehiclesAnimated: (_) {
        final updatedVehiclesMap = state.trackedVehiclesMap.map(
          (number, animated) => animated.stage.isAnimating
              ? MapEntry(
                  number,
                  AnimatedVehicle.nextStageOf(
                    animated,
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
    );
  }

  _handleVehiclesResult(Result<List<Vehicle>> result) {
    result.when(
      success: (success) => add(MapEvent.vehiclesAdded(vehicles: success.data)),
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

  trackedLinesAdded(Set<Line> lines) =>
      add(MapEvent.trackedLinesAdded(lines: lines));

  cameraMoved({
    LatLngBounds bounds,
    double zoom,
  }) {
    add(MapEvent.cameraMoved(bounds: bounds, zoom: zoom));
  }
}

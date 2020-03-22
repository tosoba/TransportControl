import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sealed_unions/sealed_unions.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/model/result.dart';
import 'package:transport_control/model/vehicle.dart';
import 'package:transport_control/pages/map/vehicle_animation_stage.dart';
import 'package:transport_control/repo/vehicles_repo.dart';

part 'package:transport_control/pages/map/map_state.dart';
part 'package:transport_control/pages/map/map_event.dart';

class MapBloc extends Bloc<_MapEvent, MapState> {
  final VehiclesRepo _vehiclesRepo;

  final Duration _updateInterval = const Duration(seconds: 15);
  StreamSubscription<Result<List<Vehicle>>> _vehicleUpdatesSubscription;

  MapBloc(this._vehiclesRepo) {
    _vehicleUpdatesSubscription = Stream.periodic(_updateInterval)
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
  }

  @override
  MapState get initialState => MapState.empty();

  @override
  Stream<MapState> mapEventToState(_MapEvent event) async* {
    yield event.join(
      (_) => MapState.empty(),
      (linesAddedEvent) {
        _vehiclesRepo
            .loadVehiclesOfLines(linesAddedEvent.lines)
            .then(_handleVehiclesResult);
        return MapState(
          state.trackedVehiclesMap,
          state.trackedLines.union(linesAddedEvent.lines),
        );
      },
      (vehiclesAddedEvent) {
        final updatedVehiclesMap = Map.of(state.trackedVehiclesMap);
        vehiclesAddedEvent.vehicles.forEach((vehicle) {
          final current = updatedVehiclesMap[vehicle.number];
          if (current != null) {
            updatedVehiclesMap[vehicle.number] =
                AnimatedVehicle.fromUpdatedVehicle(vehicle, current);
          } else {
            updatedVehiclesMap[vehicle.number] =
                AnimatedVehicle.fromNewlyLoadedVehicle(vehicle);
          }
        });
        return MapState(updatedVehiclesMap, state.trackedLines);
      },
    );
  }

  _handleVehiclesResult(Result<List<Vehicle>> result) {
    result.when(
      success: (success) => _vehiclesAdded(success.data.toSet()),
      failure: (failure) => failure.logError(),
    );
  }

  @override
  Future<void> close() async {
    await _vehicleUpdatesSubscription.cancel();
    return super.close();
  }

  Stream<Set<Line>> get trackedLines => map((state) => state.trackedLines);

  trackedLinesAdded(Set<Line> lines) => add(_MapEvent.trackedLinesAdded(lines));

  _vehiclesAdded(Set<Vehicle> vehicles) =>
      add(_MapEvent.vehiclesAdded(vehicles));
}

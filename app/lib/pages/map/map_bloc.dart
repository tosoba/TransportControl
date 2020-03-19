import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sealed_unions/sealed_unions.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/model/vehicle.dart';
import 'package:transport_control/repo/vehicles_repo.dart';

part 'package:transport_control/pages/map/map_state.dart';
part 'package:transport_control/pages/map/map_event.dart';

class MapBloc extends Bloc<_MapEvent, MapState> {
  final VehiclesRepo _vehiclesRepo;

  MapBloc(this._vehiclesRepo);

  @override
  MapState get initialState => MapState.empty();

  @override
  Stream<MapState> mapEventToState(_MapEvent event) async* {
    yield event.join(
      (_) => MapState.empty(),
      (linesAddedEvent) {
        _vehiclesRepo.loadVehiclesOfLines(linesAddedEvent.lines).then(
              (result) => result.when(
                success: (success) => _vehiclesAdded(success.data.toSet()),
                failure: (failure) =>
                    log(failure.error?.toString() ?? 'Unknown error'),
              ),
            );
        return MapState(
          state.trackedVehicles,
          state.trackedLines.union(linesAddedEvent.lines),
        );
      },
      (vehiclesAddedEvent) => MapState(
        state.trackedVehicles.union(vehiclesAddedEvent.vehicles),
        state.trackedLines,
      ),
    );
  }

  Stream<Set<Line>> get trackedLines => map((state) => state.trackedLines);

  trackedLinesAdded(Set<Line> lines) => add(_MapEvent.trackedLinesAdded(lines));

  _vehiclesAdded(Set<Vehicle> vehicles) =>
      add(_MapEvent.vehiclesAdded(vehicles));
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sealed_unions/implementations/union_3_impl.dart';
import 'package:sealed_unions/factories/triplet_factory.dart';
import 'package:sealed_unions/union_3.dart';
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
      (loadLinesEvent) => state,
      (loadInAreaEvent) => state,
    );
  }
}

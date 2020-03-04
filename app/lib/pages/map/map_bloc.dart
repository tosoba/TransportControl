import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transport_control/repo/vehicles_repo.dart';

class MapEvent {}

class MapState {}

class MapBloc extends Bloc<MapEvent, MapState> {
  final VehiclesRepo _vehiclesRepo;

  MapBloc(this._vehiclesRepo);

  @override
  MapState get initialState => MapState();

  @override
  Stream<MapState> mapEventToState(MapEvent event) {
    return null;
  }
}

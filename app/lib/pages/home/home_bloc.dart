import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/model/location.dart';
import 'package:transport_control/pages/lines/lines_bloc.dart';
import 'package:transport_control/pages/locations/locations_bloc.dart';
import 'package:transport_control/pages/map/map_bloc.dart';
import 'package:transport_control/repo/lines_repo.dart';
import 'package:transport_control/repo/locations_repo.dart';
import 'package:transport_control/repo/vehicles_repo.dart';

class _HomeEvent {}

class _HomeState {}

class HomeBloc extends Bloc<_HomeEvent, _HomeState> {
  final LocationsRepo _locationsRepo;
  LinesBloc _linesBloc;
  MapBloc _mapBloc;

  LinesBloc get linesBloc => _linesBloc;
  MapBloc get mapBloc => _mapBloc;

  LocationsBloc get locationsBloc {
    return LocationsBloc(
      GetIt.instance<LocationsRepo>(),
      saveLocation: _saveLocation,
      updateLocation: _updateLocation,
      deleteLocation: _deleteLocation,
    );
  }

  HomeBloc(
    VehiclesRepo vehiclesRepo,
    LinesRepo linesRepo,
    LocationsRepo locationsRepo,
  ) : _locationsRepo = locationsRepo {
    _linesBloc = LinesBloc(_trackedLinesAdded, _trackedLinesRemoved, linesRepo);
    _mapBloc = MapBloc(vehiclesRepo, _loadingVehiclesOfLinesFailed);
  }

  @override
  _HomeState get initialState => _HomeState();

  @override
  Stream<_HomeState> mapEventToState(_HomeEvent event) async* {
    yield state;
  }

  void _trackedLinesAdded(Set<Line> lines) {
    _mapBloc.trackedLinesAdded(lines);
  }

  void _trackedLinesRemoved(Set<Line> lines) {
    _mapBloc.trackedLinesRemoved(lines);
  }

  void _loadingVehiclesOfLinesFailed(Set<Line> lines) {
    _linesBloc.loadingVehiclesOfLinesFailed(lines);
  }

  void _saveLocation(Location location) {
    _locationsRepo.insertLocation(location);
  }

  void _updateLocation(Location location) {
    _locationsRepo.updateLocation(location);
  }

  void _deleteLocation(Location location) {
    _locationsRepo.deleteLocation(location);
  }
}

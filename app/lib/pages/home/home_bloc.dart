import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/pages/lines/lines_bloc.dart';
import 'package:transport_control/pages/map/map_bloc.dart';
import 'package:transport_control/repo/lines_repo.dart';
import 'package:transport_control/repo/vehicles_repo.dart';

class _HomeEvent {}

class _HomeState {}

class HomeBloc extends Bloc<_HomeEvent, _HomeState> {
  LinesBloc _linesBloc;
  LinesBloc get linesBloc => _linesBloc;

  MapBloc _mapBloc;
  MapBloc get mapBloc => _mapBloc;

  HomeBloc(VehiclesRepo vehiclesRepo, LinesRepo linesRepo) {
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
}

part of 'package:transport_control/pages/map/map_bloc.dart';

class _MapEvent
    extends Union3Impl<_ClearMap, _LoadVehiclesOfLines, _LoadVehiclesInArea> {
  static final Triplet<_ClearMap, _LoadVehiclesOfLines, _LoadVehiclesInArea>
      _factory =
      const Triplet<_ClearMap, _LoadVehiclesOfLines, _LoadVehiclesInArea>();

  _MapEvent._(
      Union3<_ClearMap, _LoadVehiclesOfLines, _LoadVehiclesInArea> union)
      : super(union);

  factory _MapEvent.clearMap() => _MapEvent._(_factory.first(_ClearMap()));
  factory _MapEvent.loadVehiclesOfLines(List<Line> lines) =>
      _MapEvent._(_factory.second(_LoadVehiclesOfLines(lines)));
  factory _MapEvent.loadVehiclesInArea(
          {double southWestLat,
          double southWestLon,
          double northEastLat,
          double northEastLon}) =>
      _MapEvent._(_factory.third(_LoadVehiclesInArea(
          southWestLat, southWestLon, northEastLat, northEastLon)));
}

class _ClearMap {}

class _LoadVehiclesOfLines {
  final List<Line> lines;

  _LoadVehiclesOfLines(this.lines);
}

class _LoadVehiclesInArea {
  final double southWestLat;
  final double southWestLon;
  final double northEastLat;
  final double northEastLon;

  _LoadVehiclesInArea(
    this.southWestLat,
    this.southWestLon,
    this.northEastLat,
    this.northEastLon,
  );
}

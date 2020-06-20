import 'package:transport_control/model/line.dart';

abstract class LinesRepo {
  Future insertLine(Line line);

  Future<void> insertLines(Iterable<Line> lines);

  Stream<Iterable<Line>> get linesStream;

  Future<int> updateLastSearched(Iterable<String> symbols);

  Future<void> updateIsFavourite(Iterable<Line> lines);
}

import 'package:transport_control/model/line.dart';

abstract class LinesRepo {
  Future insertLine(Line line);

  Future<void> insertLines(Iterable<Line> lines);

  Future<int> deleteLines(Iterable<String> symbols);

  Stream<Iterable<Line>> get favouriteLinesStream;
}

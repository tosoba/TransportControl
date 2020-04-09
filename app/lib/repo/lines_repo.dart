import 'package:transport_control/db/database.dart';

abstract class LinesRepo {
  Future insertLine(FavouriteLine line);

  Future<void> insertLines(Iterable<FavouriteLine> lines);

  Stream<List<FavouriteLine>> get favouriteLinesStream;
}

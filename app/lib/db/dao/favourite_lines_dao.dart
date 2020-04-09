import 'package:moor_flutter/moor_flutter.dart';
import 'package:transport_control/db/database.dart';
import 'package:transport_control/model/favourite_lines.dart';

part 'favourite_lines_dao.g.dart';

@UseDao(tables: [FavouriteLines])
class FavouriteLinesDao extends DatabaseAccessor<Database>
    with _$FavouriteLinesDaoMixin {
  FavouriteLinesDao(Database db) : super(db);

  Future insertLine(FavouriteLine line) {
    return into(favouriteLines).insert(line);
  }

  Future<void> insertLines(Iterable<FavouriteLine> lines) {
    return db.batch(
      (batch) => batch.insertAll(
        favouriteLines,
        lines
            .map((line) => FavouriteLinesCompanion.insert(symbol: line.symbol))
            .toList(),
      ),
    );
  }

  Stream<List<FavouriteLine>> favouriteLinesStream() {
    return select(favouriteLines).watch();
  }
}

import 'package:injectable/injectable.dart';
import 'package:moor_flutter/moor_flutter.dart';
import 'package:transport_control/db/database.dart';
import 'package:transport_control/model/favourite_lines.dart';

part 'favourite_lines_dao.g.dart';

@UseDao(tables: [FavouriteLines])
@injectable
class FavouriteLinesDao extends DatabaseAccessor<Database>
    with _$FavouriteLinesDaoMixin {
  FavouriteLinesDao(Database db) : super(db);

  @factoryMethod
  static FavouriteLinesDao of(Database db) => db.favouriteLinesDao;

  Future insertLine(FavouriteLine line) {
    return into(favouriteLines).insert(line);
  }

  Future<void> insertLines(Iterable<FavouriteLine> lines) {
    return db.batch(
      (batch) => batch.insertAll(
        favouriteLines,
        lines
            .map(
              (line) => FavouriteLinesCompanion.insert(
                symbol: line.symbol,
                dest1: line.dest1,
                dest2: line.dest2,
                type: line.type,
              ),
            )
            .toList(),
      ),
    );
  }

  Future<int> deleteLines(Iterable<String> symbols) {
    return (delete(favouriteLines)..where((line) => line.symbol.isIn(symbols)))
        .go();
  }

  Stream<List<FavouriteLine>> get selectFavouriteLinesStream {
    return select(favouriteLines).watch();
  }
}

import 'package:injectable/injectable.dart';
import 'package:moor_flutter/moor_flutter.dart';
import 'package:transport_control/db/database.dart';
import 'package:transport_control/db/entity/lines.dart';

part 'lines_dao.g.dart';

@UseDao(tables: [Lines])
@injectable
class LinesDao extends DatabaseAccessor<Database> with _$LinesDaoMixin {
  LinesDao(Database db) : super(db);

  @factoryMethod
  static LinesDao of(Database db) => db.linesDao;

  Future insertLine(Line line) => into(lines).insert(line);

  Future<void> insertLines(Iterable<Line> entities) {
    return db.batch(
      (batch) => batch.insertAll(
        lines,
        entities
            .map(
              (line) => LinesCompanion.insert(
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
    return (delete(lines)..where((line) => line.symbol.isIn(symbols))).go();
  }

  Stream<List<Line>> get selectFavouriteLinesStream => select(lines).watch();

  Future<int> updateLastSearched(Iterable<String> symbols) {
    return (update(lines)..where((line) => line.symbol.isIn(symbols)))
        .write(LinesCompanion(lastSearched: Value(DateTime.now())));
  }
}

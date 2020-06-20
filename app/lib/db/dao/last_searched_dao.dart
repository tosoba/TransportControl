import 'package:injectable/injectable.dart';
import 'package:moor_flutter/moor_flutter.dart';
import 'package:transport_control/db/database.dart';
import 'package:transport_control/db/entity/lines.dart';
import 'package:transport_control/db/entity/locations.dart';
import 'package:transport_control/model/searched_entity.dart';

part 'last_searched_dao.g.dart';

@UseDao(tables: [Lines, Locations])
@injectable
class LastSearchedDao extends DatabaseAccessor<Database>
    with _$LastSearchedDaoMixin {
  LastSearchedDao(Database db) : super(db);

  @factoryMethod
  static LastSearchedDao of(Database db) => db.lastSearchedDao;

  Stream<List<SearchedEntity>> selectLatestSearchedItems({
    @required int limit,
  }) {
    return customSelectQuery(
      '''SELECT CAST(id AS TEXT) AS id, last_searched, 'location' as type FROM locations 
        WHERE last_searched IS NOT NULL 
        UNION ALL 
        SELECT symbol AS id, last_searched, 'line' as type FROM lines 
        WHERE last_searched IS NOT NULL 
        ORDER BY last_searched DESC 
        ${limit != null ? 'LIMIT $limit' : ''}''',
      readsFrom: {lines, locations},
    ).watch().asyncMap(
      (rows) {
        final lineSymbols = <String>[];
        final locationIds = <int>[];
        rows.forEach((row) {
          final type = row.readString('type');
          if (type == 'line') {
            lineSymbols.add(row.readString('id'));
          } else {
            locationIds.add(int.parse(row.readString('id')));
          }
        });

        return transaction(() async {
          final lastSearchedLines = await (select(lines)
                ..where((line) => line.symbol.isIn(lineSymbols)))
              .get();
          final lastSearchedLocations = await (select(locations)
                ..where((location) => location.id.isIn(locationIds)))
              .get();
          final lastSearched = <SearchedEntity>[];
          for (int linesIndex = 0, locationsIndex = 0;
              linesIndex < lastSearchedLines.length ||
                  locationsIndex < lastSearchedLocations.length;) {
            if (linesIndex < lastSearchedLines.length &&
                locationsIndex >= lastSearchedLocations.length) {
              lastSearched.add(
                SearchedEntity.lineEntity(
                  line: lastSearchedLines.elementAt(linesIndex++),
                ),
              );
            } else if (locationsIndex < lastSearchedLocations.length &&
                linesIndex >= lastSearchedLines.length) {
              lastSearched.add(
                SearchedEntity.locationEntity(
                  location: lastSearchedLocations.elementAt(locationsIndex++),
                ),
              );
            } else {
              final line = lastSearchedLines.elementAt(linesIndex);
              final location = lastSearchedLocations.elementAt(locationsIndex);
              if (location.lastSearched.millisecondsSinceEpoch >
                  line.lastSearched.millisecondsSinceEpoch) {
                lastSearched
                    .add(SearchedEntity.locationEntity(location: location));
                ++locationsIndex;
              } else {
                lastSearched.add(SearchedEntity.lineEntity(line: line));
                ++linesIndex;
              }
            }
          }
          return lastSearched;
        });
      },
    );
  }
}

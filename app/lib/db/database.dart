import 'package:injectable/injectable.dart';
import 'package:moor_flutter/moor_flutter.dart';
import 'package:transport_control/db/dao/lines_dao.dart';
import 'package:transport_control/db/dao/locations_dao.dart';
import 'package:transport_control/db/entity/lines.dart';
import 'package:transport_control/db/entity/locations.dart';

part 'database.g.dart';

@UseMoor(
  tables: [Lines, Locations],
  daos: [LinesDao, LocationsDao],
)
@singleton
class Database extends _$Database {
  Database()
      : super(
          FlutterQueryExecutor.inDatabaseFolder(
            path: 'db.sqlite',
            logStatements: true,
          ),
        );

  @override
  int get schemaVersion => 1;
}

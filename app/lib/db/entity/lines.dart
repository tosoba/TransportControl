import 'package:moor_flutter/moor_flutter.dart';
import 'package:transport_control/db/tables.dart';

@DataClassName(Tables.lines)
class Lines extends Table {
  TextColumn get symbol => text()();

  TextColumn get dest1 => text()();

  TextColumn get dest2 => text()();

  IntColumn get type => integer()();

  DateTimeColumn get lastSearched => dateTime().nullable()();

  BoolColumn get isFavourite => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {symbol};
}

import 'package:moor_flutter/moor_flutter.dart';
import 'package:transport_control/db/tables.dart';

@DataClassName(Tables.favouriteLine)
class FavouriteLines extends Table {
  TextColumn get symbol => text()();
}

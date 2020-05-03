import 'package:super_enum/super_enum.dart';

part "locations_list_order.g.dart";

class BySavedTimestamp {
  const BySavedTimestamp();

  @override
  String toString() => 'Saved timestamp';
}

class ByLastSearched {
  const ByLastSearched();

  @override
  String toString() => 'Last searched';
}

class ByTimesSearched {
  const ByTimesSearched();

  @override
  String toString() => 'Times searched';
}

@superEnum
enum _LocationsListOrder {
  @UseClass(BySavedTimestamp)
  SavedTimestamp,

  @UseClass(ByLastSearched)
  LastSearched,

  @UseClass(ByTimesSearched)
  TimesSearched,
}

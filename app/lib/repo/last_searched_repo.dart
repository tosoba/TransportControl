import 'package:transport_control/model/searched_item.dart';

abstract class LastSearchedRepo {
  Stream<List<SearchedItem>> getLastSearchedItemsStream({int limit});
}
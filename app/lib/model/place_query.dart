import 'package:flutter/foundation.dart';

class PlaceQuery {
  final String text;
  final DateTime lastSearched;

  PlaceQuery({@required this.text, @required this.lastSearched});
}

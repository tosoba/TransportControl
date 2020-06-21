import 'package:json_annotation/json_annotation.dart';
import 'package:quiver/core.dart';
import 'package:transport_control/db/database.dart' as Db;

part 'line.g.dart';

@JsonSerializable()
class Line {
  final String symbol;
  final String dest1;
  final String dest2;
  final int type;
  final DateTime lastSearched;
  final bool isFavourite;

  Line(
    this.symbol,
    this.dest1,
    this.dest2,
    this.type,
    this.lastSearched,
    this.isFavourite,
  );

  factory Line.fromJson(Map<String, dynamic> json) => _$LineFromJson(json);

  Map<String, dynamic> toJson() => _$LineToJson(this);

  bool operator ==(other) {
    return other is Line &&
        symbol == other.symbol &&
        dest1 == other.dest1 &&
        dest2 == other.dest2 &&
        type == other.type;
  }

  int get hashCode {
    return hash4(
      symbol.hashCode,
      dest1.hashCode,
      dest2.hashCode,
      type.hashCode,
    );
  }

  Db.Line get db {
    return Db.Line(
      symbol: symbol,
      dest1: dest1,
      dest2: dest2,
      type: type,
      lastSearched: lastSearched,
      isFavourite: isFavourite,
    );
  }

  Line.fromDb(Db.Line line)
      : symbol = line.symbol,
        dest1 = line.dest1,
        dest2 = line.dest2,
        type = line.type,
        lastSearched = line.lastSearched,
        isFavourite = line.isFavourite;
}

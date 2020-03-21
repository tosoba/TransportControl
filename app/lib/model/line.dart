import 'package:json_annotation/json_annotation.dart';
import 'package:quiver/core.dart';

part 'line.g.dart';

@JsonSerializable()
class Line {
  final String symbol;
  final String dest1;
  final String dest2;
  final int type;

  Line(this.symbol, this.dest1, this.dest2, this.type);

  factory Line.fromJson(Map<String, dynamic> json) => _$LineFromJson(json);
  Map<String, dynamic> toJson() => _$LineToJson(this);

  bool operator ==(o) {
    return o is Line &&
        symbol == o.symbol &&
        dest1 == o.dest1 &&
        dest2 == o.dest2 &&
        type == o.type;
  }

  int get hashCode {
    return hash4(
        symbol.hashCode, dest1.hashCode, dest2.hashCode, type.hashCode);
  }
}

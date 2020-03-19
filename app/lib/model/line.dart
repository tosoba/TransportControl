import 'package:quiver/core.dart';

class Line {
  final String symbol;
  final String dest1;
  final String dest2;
  final int type;

  Line(this.symbol, this.dest1, this.dest2, this.type);

  factory Line.fromJson(Map<String, dynamic> json) {
    return Line(
      json['Symbol'] as String,
      json['Dest1'] as String,
      json['Dest2'] as String,
      json['Type'] as int,
    );
  }

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

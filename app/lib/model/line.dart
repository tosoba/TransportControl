import 'package:quiver/core.dart';

class Line {
  final String symbol;
  final String dest1;
  final String dest2;

  Line(this.symbol, this.dest1, this.dest2);

  factory Line.fromJson(Map<String, dynamic> json) {
    return Line(
      json['Symbol'] as String,
      json['Dest1'] as String,
      json['Dest2'] as String,
    );
  }

  bool operator ==(o) =>
      o is Line && symbol == o.symbol && dest1 == o.dest1 && dest2 == o.dest2;
  int get hashCode => hash3(symbol.hashCode, dest1.hashCode, dest2.hashCode);
}

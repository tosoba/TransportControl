import 'package:latlong/latlong.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/model/vehicle.dart';
import 'package:transport_control/util/string_util.dart';

extension VehicleExt on Vehicle {
  bool get isValid =>
      lat != null &&
      lon != null &&
      symbol != null &&
      brigade != null &&
      lastUpdate != null;

  int get type => _typeFrom(symbol);

  LatLng get position => LatLng(lat, lon);
}

extension LineExt on Line {
  int get type => _typeFrom(symbol);

  String get group {
    if (type == VehicleType.TRAM) {
      return "1";
    } else {
      if (symbol.firstCharIsLetter) return symbol[0];
      int parsedSymbol = int.tryParse(symbol);
      if (parsedSymbol == null) {
        return "OTHER";
      } else {
        return ((parsedSymbol / 100).floor() * 100).toString();
      }
    }
  }
}

int _typeFrom(String symbol) {
  if (symbol == null)
    return null;
  else {
    int parsedSymbol = int.tryParse(symbol);
    if (symbol.firstCharIsLetter ||
        (parsedSymbol != null && parsedSymbol >= 100))
      return VehicleType.BUS;
    else
      return VehicleType.TRAM;
  }
}

class VehicleType {
  static const int BUS = 1;
  static const int TRAM = 2;

  VehicleType._();
}

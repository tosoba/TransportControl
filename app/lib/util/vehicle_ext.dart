import 'package:transport_control/model/vehicle.dart';
import 'package:transport_control/util/string_ext.dart';

extension VehicleExt on Vehicle {
  bool get isValid =>
      lat != null &&
      lon != null &&
      symbol != null &&
      brigade != null &&
      time != null;

  int get type {
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
}

class VehicleType {
  static const int BUS = 1;
  static const int TRAM = 2;

  VehicleType._();
}

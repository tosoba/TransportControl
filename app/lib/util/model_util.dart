import 'package:latlong/latlong.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/model/location.dart';
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

extension LocationExt on Location {
  String get timesSearchedInfo {
    return timesSearched > 0
        ? 'Searched ${timesSearched} ${timesSearched > 1 ? 'times' : 'time'}'
        : 'Never searched';
  }

  String get lastSearchedInfo {
    if (lastSearched == null) return 'Never searched';
    final diffMillis = DateTime.now().millisecondsSinceEpoch -
        lastSearched.millisecondsSinceEpoch;
    final diffSeconds = diffMillis ~/ 1000;
    if (diffSeconds < 1) return 'Searched less than a second ago';
    final diffMinutes = diffMillis ~/ (60 * 1000);
    if (diffMinutes < 1)
      return diffSeconds > 1 ? 'Searched ${diffSeconds} seconds ago' : 'Searched 1 second ago';
    final diffHours = diffMillis ~/ (60 * 60 * 1000);
    if (diffHours < 1)
      return diffMinutes > 1 ? 'Searched ${diffMinutes} minutes ago' : 'Searched 1 minute ago';
    final diffDays = diffMillis ~/ (60 * 60 * 1000 * 24);
    if (diffDays < 1)
      return diffHours > 1 ? 'Searched ${diffHours} hours ago' : 'Searched 1 hour ago';
    final diffWeeks = diffMillis ~/ (60 * 60 * 1000 * 24 * 7);
    if (diffWeeks < 1)
      return diffDays > 1 ? 'Searched ${diffDays} days ago' : 'Searched 1 day ago';
    final diffMonths =
        diffMillis ~/ (60.0 * 60.0 * 1000.0 * 24.0 * 30.41666666);
    if (diffMonths < 1)
      return diffWeeks > 1 ? 'Searched ${diffWeeks} weeks ago' : 'Searched 1 week ago';
    final diffYears = diffMillis ~/ (60 * 60 * 1000 * 24 * 365);
    if (diffYears < 1)
      return diffMonths > 1 ? 'Searched ${diffMonths} months ago' : 'Searched 1 month ago';
    return diffYears > 1 ? 'Searched ${diffYears} years ago' : 'Searched 1 year ago';
  }
}

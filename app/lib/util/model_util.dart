import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:moor_flutter/moor_flutter.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/model/location.dart';
import 'package:transport_control/model/place_suggestion.dart';
import 'package:transport_control/model/vehicle.dart';
import 'package:transport_control/pages/map/map_vehicle_source.dart';
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

  String get updatedAgoLabel {
    if (lastUpdate == null) return 'Unknown update time.';
    final diff = DateTime.now().difference(lastUpdate).inMilliseconds;
    return _dateTimeDiffInfo(diffMillis: diff, prefix: 'Updated');
  }
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
        return 'OTHER';
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

String _dateTimeDiffInfo({
  @required int diffMillis,
  @required String prefix,
}) {
  final diffSeconds = diffMillis ~/ 1000;
  if (diffSeconds < 1) return '$prefix less than a second ago';
  final diffMinutes = diffMillis ~/ (60 * 1000);
  if (diffMinutes < 1)
    return diffSeconds > 1
        ? '$prefix ${diffSeconds} seconds ago'
        : '$prefix 1 second ago';
  final diffHours = diffMillis ~/ (60 * 60 * 1000);
  if (diffHours < 1)
    return diffMinutes > 1
        ? '$prefix ${diffMinutes} minutes ago'
        : '$prefix 1 minute ago';
  final diffDays = diffMillis ~/ (60 * 60 * 1000 * 24);
  if (diffDays < 1)
    return diffHours > 1
        ? '$prefix ${diffHours} hours ago'
        : '$prefix 1 hour ago';
  final diffWeeks = diffMillis ~/ (60 * 60 * 1000 * 24 * 7);
  if (diffWeeks < 1)
    return diffDays > 1 ? '$prefix ${diffDays} days ago' : '$prefix 1 day ago';
  final diffMonths = diffMillis ~/ (60.0 * 60.0 * 1000.0 * 24.0 * 30.41666666);
  if (diffMonths < 1)
    return diffWeeks > 1
        ? '$prefix ${diffWeeks} weeks ago'
        : '$prefix 1 week ago';
  final diffYears = diffMillis ~/ (60 * 60 * 1000 * 24 * 365);
  if (diffYears < 1)
    return diffMonths > 1
        ? '$prefix ${diffMonths} months ago'
        : '$prefix 1 month ago';
  return diffYears > 1
      ? '$prefix ${diffYears} years ago'
      : '$prefix 1 year ago';
}

extension LocationExt on Location {
  String get timesSearchedInfo {
    return timesSearched > 0
        ? 'Searched ${timesSearched} ${timesSearched > 1 ? 'times' : 'time'}'
        : 'Never searched';
  }

  String get lastSearchedInfo {
    if (lastSearched == null) return 'Never searched';
    return _dateTimeDiffInfo(
      diffMillis: DateTime.now().millisecondsSinceEpoch -
          lastSearched.millisecondsSinceEpoch,
      prefix: 'Searched',
    );
  }

  String get savedAtInfo {
    return _dateTimeDiffInfo(
      diffMillis: DateTime.now().millisecondsSinceEpoch -
          savedAt.millisecondsSinceEpoch,
      prefix: 'Saved',
    );
  }
}

extension PlaceSuggestionExt on PlaceSuggestion {
  String get lastSearchedLabel {
    if (lastSearched == null) return 'Never searched';
    return _dateTimeDiffInfo(
      diffMillis: DateTime.now().millisecondsSinceEpoch -
          lastSearched.millisecondsSinceEpoch,
      prefix: 'Searched',
    );
  }
}

Value<T> nullableValueFrom<T>(T value) {
  return value == null ? Value.absent() : Value(value);
}

extension MapVehicleSourceExt on MapVehicleSource {
  DateTime get loadedAt {
    return when(
      ofLine: (ol) => ol.loadedAt,
      inBounds: (ib) => ib.loadedAt,
      nearby: (n) => n.loadedAt,
    );
  }
}

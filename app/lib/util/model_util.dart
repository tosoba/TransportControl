import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:moor_flutter/moor_flutter.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/model/location.dart';
import 'package:transport_control/model/place_suggestion.dart';
import 'package:transport_control/model/searched_item.dart';
import 'package:transport_control/model/vehicle.dart';
import 'package:transport_control/pages/map/map_bloc.dart';
import 'package:transport_control/pages/map/map_signal.dart';
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
    return dateTimeDiffInfo(diffMillis: diff, prefix: 'Updated');
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

  String get lastSearchedInfo {
    if (lastSearched == null) return 'Never searched';
    return dateTimeDiffInfo(
      diffMillis: DateTime.now().millisecondsSinceEpoch -
          lastSearched.millisecondsSinceEpoch,
      prefix: 'Searched',
    );
  }
}

int _typeFrom(String symbol) {
  if (symbol == null)
    return null;
  else {
    final parsedSymbol = int.tryParse(symbol);
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

String dateTimeDiffInfo({
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
    return dateTimeDiffInfo(
      diffMillis: DateTime.now().millisecondsSinceEpoch -
          lastSearched.millisecondsSinceEpoch,
      prefix: 'Searched',
    );
  }

  String get savedAtInfo {
    return dateTimeDiffInfo(
      diffMillis: DateTime.now().millisecondsSinceEpoch -
          savedAt.millisecondsSinceEpoch,
      prefix: 'Saved',
    );
  }
}

extension PlaceSuggestionExt on PlaceSuggestion {
  String get lastSearchedLabel {
    if (lastSearched == null) return 'Never searched';
    return dateTimeDiffInfo(
      diffMillis: DateTime.now().millisecondsSinceEpoch -
          lastSearched.millisecondsSinceEpoch,
      prefix: 'Searched',
    );
  }
}

extension SearchItemExt on SearchedItem {
  DateTime get lastSearched {
    return when(
      lineItem: (lineItem) => lineItem.line.lastSearched,
      locationItem: (locationItem) => locationItem.location.lastSearched,
    );
  }
}

Value<T> nullableValueFrom<T>(T value) {
  return value == null ? Value.absent() : Value(value);
}

extension MapVehicleSourceExt on MapVehicleSource {
  DateTime get loadedAt {
    return when(
      ofLine: (source) => source.loadedAt,
      nearbyLocation: (source) => source.loadedAt,
      nearbyUserLocation: (source) => source.loadedAt,
      nearbyPlace: (source) => source.loadedAt,
    );
  }
}

class Pair<A, B> {
  final A first;
  final B second;

  Pair(this.first, this.second);
}

class LoadingSignalTracker<Signal, Loading extends Signal> {
  final Signal signal;
  final int currentlyLoading;

  LoadingSignalTracker._({
    @required this.signal,
    @required this.currentlyLoading,
  });

  LoadingSignalTracker.first(this.signal)
      : currentlyLoading = signal is Loading ? 1 : 0;

  LoadingSignalTracker<Signal, Loading> next(Signal signal) {
    int nextLoading;
    if (signal is Loading) {
      nextLoading = currentlyLoading + 1;
    } else if (currentlyLoading > 0) {
      nextLoading = currentlyLoading - 1;
    } else {
      nextLoading = 0;
    }
    return LoadingSignalTracker._(
      signal: signal,
      currentlyLoading: nextLoading,
    );
  }
}

extension MapBlocExt on MapBloc {
  StreamSubscription<LoadingSignalTracker<MapSignal, Loading>>
      listenToLoadingSignalTrackers(
    void Function(LoadingSignalTracker<MapSignal, Loading>) onData,
  ) {
    return signals
        .loadingSignalTrackerStream<Loading>()
        .debounce(const Duration(milliseconds: 250), leading: true)
        .listen(onData);
  }
}

extension SignalStreamExt<Signal> on Stream<Signal> {
  Stream<LoadingSignalTracker<Signal, Loading>>
      loadingSignalTrackerStream<Loading extends Signal>() {
    return scan<
        Pair<LoadingSignalTracker<Signal, Loading>,
            LoadingSignalTracker<Signal, Loading>>>(
      Pair(null, null),
      (latest2Trackers, signal) => Pair(
        latest2Trackers.second,
        latest2Trackers.second?.next(signal) ??
            LoadingSignalTracker.first(signal),
      ),
    ).map((pair) => pair.second);
  }
}

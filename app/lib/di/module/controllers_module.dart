import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/model/location.dart';

@registerModule
abstract class ControllersModule {
  @singleton
  LoadVehiclesInLocation get loadVehiclesInLocation {
    return LoadVehiclesInLocation(StreamController<Location>());
  }

  @singleton
  LoadVehiclesNearby get loadVehiclesNearby {
    return LoadVehiclesNearby(StreamController<LatLng>());
  }

  @singleton
  TrackedLinesAdded get trackedLinesAdded {
    return TrackedLinesAdded(StreamController<TrackedLinesAddedEvent>());
  }

  @singleton
  TrackedLinesRemoved get trackedLinesRemoved {
    return TrackedLinesRemoved(StreamController<Set<Line>>());
  }

  @singleton
  UntrackLines get untrackLines => UntrackLines(StreamController<Set<Line>>());

  @singleton
  UntrackAllLines get mapCleared => UntrackAllLines(StreamController<Object>());
}

class Injectable<T> {
  final T injected;

  Injectable(this.injected);
}

class LoadVehiclesInLocation extends Injectable<StreamController<Location>> {
  LoadVehiclesInLocation(StreamController<Location> controller)
      : super(controller);
}

class LoadVehiclesNearby extends Injectable<StreamController<LatLng>> {
  LoadVehiclesNearby(StreamController<LatLng> controller) : super(controller);
}

class TrackedLinesAddedEvent {
  final Set<Line> lines;
  final void Function() beforeRetry;

  TrackedLinesAddedEvent({@required this.lines, this.beforeRetry});
}

class TrackedLinesAdded
    extends Injectable<StreamController<TrackedLinesAddedEvent>> {
  TrackedLinesAdded(StreamController<TrackedLinesAddedEvent> controller)
      : super(controller);
}

class TrackedLinesRemoved extends Injectable<StreamController<Set<Line>>> {
  TrackedLinesRemoved(StreamController<Set<Line>> controller)
      : super(controller);
}

class UntrackLines extends Injectable<StreamController<Set<Line>>> {
  UntrackLines(StreamController<Set<Line>> controller) : super(controller);
}

class UntrackAllLines extends Injectable<StreamController<Object>> {
  UntrackAllLines(StreamController<Object> controller) : super(controller);
}

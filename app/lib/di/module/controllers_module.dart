import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:transport_control/model/line.dart';

@registerModule
abstract class ControllersModule {
  @singleton
  LoadVehiclesInBounds get loadVehiclesInBounds {
    return LoadVehiclesInBounds(StreamController<LatLngBounds>());
  }

  @singleton
  LoadVehiclesNearby get loadVehiclesNearby {
    return LoadVehiclesNearby(StreamController<LatLng>());
  }

  @singleton
  TrackedLinesAdded get trackedLinesAdded {
    return TrackedLinesAdded(StreamController<Set<Line>>());
  }

  @singleton
  TrackedLinesRemoved get trackedLinesRemoved {
    return TrackedLinesRemoved(StreamController<Set<Line>>());
  }

  @singleton
  LoadingVehiclesOfLinesFailed get loadingVehiclesOfLinesFailed {
    return LoadingVehiclesOfLinesFailed(StreamController<Set<Line>>());
  }
}

class Injectable<T> {
  final T injected;

  Injectable(this.injected);
}

class LoadVehiclesInBounds extends Injectable<StreamController<LatLngBounds>> {
  LoadVehiclesInBounds(StreamController<LatLngBounds> controller)
      : super(controller);
}

class LoadVehiclesNearby extends Injectable<StreamController<LatLng>> {
  LoadVehiclesNearby(StreamController<LatLng> controller) : super(controller);
}

class TrackedLinesAdded extends Injectable<StreamController<Set<Line>>> {
  TrackedLinesAdded(StreamController<Set<Line>> controller) : super(controller);
}

class TrackedLinesRemoved extends Injectable<StreamController<Set<Line>>> {
  TrackedLinesRemoved(StreamController<Set<Line>> controller)
      : super(controller);
}

class LoadingVehiclesOfLinesFailed
    extends Injectable<StreamController<Set<Line>>> {
  LoadingVehiclesOfLinesFailed(StreamController<Set<Line>> controller)
      : super(controller);
}

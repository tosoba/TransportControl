import 'dart:async';
import 'dart:developer';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_animarker/lat_lng_interpolation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:transport_control/di/module/controllers_module.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/model/location.dart';
import 'package:transport_control/model/place_suggestion.dart';
import 'package:transport_control/model/result.dart';
import 'package:transport_control/model/vehicle.dart';
import 'package:transport_control/pages/map/map_constants.dart';
import 'package:transport_control/pages/map/map_event.dart';
import 'package:transport_control/pages/map/map_markers.dart';
import 'package:transport_control/pages/map/map_signal.dart';
import 'package:transport_control/pages/map/map_state.dart';
import 'package:transport_control/pages/map/map_vehicle.dart';
import 'package:transport_control/pages/map/map_vehicle_source.dart';
import 'package:transport_control/repo/vehicles_repo.dart';
import 'package:transport_control/util/asset_util.dart';
import 'package:transport_control/util/lat_lng_util.dart';
import 'package:transport_control/util/marker_util.dart';
import 'package:transport_control/util/preferences_util.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final RxSharedPreferences _preferences;
  final VehiclesRepo _vehiclesRepo;
  final Sink<Set<Line>> _untrackLinesSink;
  final Sink<Object> _untrackAllLinesSink;

  final List<StreamSubscription> _subscriptions = [];

  final StreamController<MapSignal> _signals = StreamController.broadcast();
  Stream<MapSignal> get signals => _signals.stream;

  MapBloc(
    this._vehiclesRepo,
    this._preferences,
    this._untrackLinesSink,
    this._untrackAllLinesSink,
    Stream<Location> loadVehiclesInLocationStream,
    Stream<LatLng> loadVehiclesNearbyUserLocationStream,
    Stream<PlaceSuggestion> loadVehiclesNearbyPlaceStream,
    Stream<TrackedLinesAddedEvent> trackedLinesAddedStream,
    Stream<Set<Line>> trackedLinesRemovedStream,
  ) {
    _subscriptions
      ..add(
        Stream.periodic(const Duration(seconds: 15))
            .where((_) => state.trackedVehicles.isNotEmpty)
            .asyncMap(
              (_) => _vehiclesRepo.loadUpdatedVehicles(
                state.trackedVehicles.values.map((tracked) => tracked.vehicle),
              ),
            )
            .listen(
              (result) => result.when(
                success: (success) => add(
                  MapEvent.updateVehicles(vehicles: success.data),
                ),
                failure: (failure) => failure.logError(),
              ),
            ),
      )
      ..add(loadVehiclesInLocationStream.listen(_loadVehiclesInLocation))
      ..add(
        loadVehiclesNearbyUserLocationStream.listen(
          (position) async => _loadVehiclesNearbyUserLocation(
            position,
            radiusInMeters: await _preferences.getInt(
              Preferences.nearbySearchRadius.key,
            ),
          ),
        ),
      )
      ..add(
        loadVehiclesNearbyPlaceStream.listen(
          (place) async => _loadVehiclesNearbyPlace(
            LatLng(place.position.lat, place.position.lng),
            title: place.title,
            radiusInMeters: await _preferences.getInt(
              Preferences.nearbySearchRadius.key,
            ),
          ),
        ),
      )
      ..add(trackedLinesAddedStream.listen(_loadVehiclesOfLines))
      ..add(
        trackedLinesRemovedStream
            .listen((lines) => add(MapEvent.trackedLinesRemoved(lines: lines))),
      );
  }

  @override
  MapState get initialState => MapState.initial();

  static final double _minAnimationZoom = 12;

  @override
  Stream<MapState> mapEventToState(MapEvent event) async* {
    if (event is UpdateVehicles) {
      final bounds = state.bounds;
      final trackedVehicles = state.trackedVehicles;
      // 1) empty trackedVehicles Map
      // 2) put vehicles that are outside of current bounds into the map with null Marker
      // 3) create markers for those that are in bounds and assign each Marker to Vehicle inside the map in place
      // depending on current zoom
      // (if zoom > _minAnimationZoom) give all unclustered markers their initial position = previous position (or destination in case it's the first load)
      // and position = destination for clustered ones
      // else make them all equal to destination
      // keep the part of the map holding clustered markers as a variable
      // animate unclustered markers
      final eventVehiclesMap = Map<String, Vehicle>.fromIterable(
        event.vehicles,
        key: (vehicle) => vehicle.number,
        value: (vehicle) => vehicle,
      );

      final updatedVehicles = <String, MapVehicle>{};
      final clusterables = <String, ClusterableMarker>{};
      event.vehicles.forEach((updatedVehicle) {
        if (!bounds.containsLatLng(updatedVehicle.lat, updatedVehicle.lon)) {
          final current = trackedVehicles[updatedVehicle.number];
          if (current?.marker == null) {
            updatedVehicles[updatedVehicle.number] = MapVehicle.withoutMarker(
              updatedVehicle,
              sources: current?.sources,
            );
          } else {
            final currentPosition = current.marker.position;
            if (!bounds.containsLatLng(
              currentPosition.latitude,
              currentPosition.longitude,
            )) {
              updatedVehicles[updatedVehicle.number] = MapVehicle.withoutMarker(
                updatedVehicle,
                sources: current?.sources,
              );
            } else {
              clusterables[updatedVehicle.number] = ClusterableMarker(
                id: updatedVehicle.number,
                lat: updatedVehicle.lat,
                lng: updatedVehicle.lon,
                number: updatedVehicle.number,
                symbol: updatedVehicle.symbol,
                initialPosition: currentPosition,
              );
            }
          }
        } else {
          clusterables[updatedVehicle.number] = ClusterableMarker(
            id: updatedVehicle.number,
            lat: updatedVehicle.lat,
            lng: updatedVehicle.lon,
            number: updatedVehicle.number,
            symbol: updatedVehicle.symbol,
            initialPosition:
                trackedVehicles[updatedVehicle.number]?.marker?.position,
          );
        }
      });

      final fluster = await clusterables.fluster(
        minZoom: MapConstants.minClusterZoom,
        maxZoom: MapConstants.maxClusterZoom,
      );

      final iconifiedMarkers = await fluster.iconifiedMarkers(
        currentZoom: state.zoom,
        clusterColor: Colors.blue,
        clusterTextColor: Colors.white,
      );

      iconifiedMarkers.clustered.forEach((clustered) {
        final marker = clustered.googleMapMarker();
        clustered.children.forEach((clusterable) {
          updatedVehicles[clusterable.number] = MapVehicle.withMarker(
            eventVehiclesMap[clusterable.number],
            marker: marker,
            sources: trackedVehicles[clusterable.number]?.sources,
          );
        });
      });

      final selectedMarker = await state._selectedMarker;

      // if (state.zoom > _minAnimationZoom) {
      // } else {}
      iconifiedMarkers.nonClustered.forEach((nonClustered) {
        final marker = nonClustered.googleMapMarker();
        nonClustered.children.forEach((clusterable) {
          updatedVehicles[clusterable.number] = MapVehicle.withMarker(
            eventVehiclesMap[clusterable.number],
            marker: marker,
            sources: trackedVehicles[clusterable.number]?.sources,
          );
        });
      });

      yield state.copyWith(trackedVehicles: updatedVehicles);
    } else {
      yield event.whenOrElse(
        orElse: (_) => state,
        clearMap: (_) => state.copyWith(trackedVehicles: {}),
        addVehiclesOfLines: (evt) {
          final lineSymbols = Map.fromIterables(
            evt.lines.map((line) => line.symbol),
            evt.lines,
          );
          final loadedAt = DateTime.now();
          return state.withNewVehicles(
            evt.vehicles,
            sourceForVehicle: (vehicle) => MapVehicleSource.ofLine(
              line: lineSymbols[vehicle.symbol],
              loadedAt: loadedAt,
            ),
          );
        },
        addVehiclesInLocation: (evt) {
          final loadedAt = DateTime.now();
          return state.withNewVehicles(
            evt.vehicles,
            sourceForVehicle: (_) => MapVehicleSource.nearbyLocation(
              location: evt.location,
              loadedAt: loadedAt,
            ),
          );
        },
        addVehiclesNearbyUserLocation: (evt) {
          final loadedAt = DateTime.now();
          return state.withNewVehicles(
            evt.vehicles,
            sourceForVehicle: (_) => MapVehicleSource.nearbyUserLocation(
              position: evt.position,
              radius: evt.radius,
              loadedAt: loadedAt,
            ),
          );
        },
        addVehiclesNearbyPlace: (evt) {
          final loadedAt = DateTime.now();
          return state.withNewVehicles(
            evt.vehicles,
            sourceForVehicle: (_) => MapVehicleSource.nearbyPlace(
              position: evt.position,
              radius: evt.radius,
              title: evt.title,
              loadedAt: loadedAt,
            ),
          );
        },
        cameraMoved: (evt) => evt.byUser
            ? state.withNoSelectedVehicleBoundsAndZoom(
                bounds: evt.bounds,
                zoom: evt.zoom,
              )
            : state.copyWith(zoom: evt.zoom, bounds: evt.bounds),
        trackedLinesRemoved: (evt) => state.withRemovedSource(
          (source) => source is OfLine && evt.lines.contains(source.line),
        ),
        removeSource: (evt) => state.withRemovedSource(
          (source) => source == evt.source,
        ),
        selectVehicle: (evt) => evt.number == state.selectedVehicleNumber
            ? state
            : state.copyWith(selectedVehicleNumber: evt.number),
        deselectVehicle: (_) => state.withNoSelectedVehicle,
      );
    }
  }

  @override
  void onTransition(Transition<MapEvent, MapState> transition) {
    super.onTransition(transition);
    log(transition.toString());
  }

  @override
  Future<void> close() async {
    await Future.wait([
      ..._subscriptions.map((subscription) => subscription.cancel()),
      _signals.close(),
    ]);
    return super.close();
  }

  Stream<List<Marker>> get markers {
    return state.trackedVehicles.isEmpty
        ? map((state) => null)
        : asyncExpand((state) => state.mapMarkers);
  }

  void _loadVehiclesOfLines(TrackedLinesAddedEvent event) {
    final lines = event.lines;
    _loadVehicles(
      loadingMsg:
          'Loading vehicles of ${lines.length} ${lines.length > 1 ? 'lines' : 'line'}...',
      emptyResultErrorMsg: 'No vehicles of requested lines were found.',
      loadVehicles: () => _vehiclesRepo.loadVehiclesOfLines(lines),
      successEvent: (vehicles) => MapEvent.addVehiclesOfLines(
        vehicles: vehicles,
        lines: lines,
      ),
      onFailure: (_) => _untrackLinesSink.add(lines),
      beforeRetry: event.beforeRetry,
    );
  }

  void _loadVehiclesInLocation(Location location) {
    _loadVehicles(
      loadingMsg: 'Loading vehicles nearby ${location.name}',
      emptyResultErrorMsg: 'No vehicles were found nearby ${location.name}.',
      loadVehicles: () => _vehiclesRepo.loadVehiclesInBounds(location.bounds),
      successEvent: (vehicles) => MapEvent.addVehiclesInLocation(
        vehicles: vehicles,
        location: location,
      ),
    );
  }

  void _loadVehiclesNearbyUserLocation(
    LatLng position, {
    @required int radiusInMeters,
  }) {
    _loadVehicles(
      loadingMsg: 'Loading nearby vehicles...',
      emptyResultErrorMsg: 'No vehicles were found nearby your location.',
      loadVehicles: () => _vehiclesRepo.loadVehiclesNearby(
        position,
        radiusInMeters: radiusInMeters,
      ),
      successEvent: (vehicles) => MapEvent.addVehiclesNearbyUserLocation(
        vehicles: vehicles,
        position: position,
        radius: radiusInMeters,
      ),
    );
  }

  void _loadVehiclesNearbyPlace(
    LatLng position, {
    @required String title,
    @required int radiusInMeters,
  }) {
    _loadVehicles(
      loadingMsg: 'Loading vehicles nearby $title...',
      emptyResultErrorMsg: 'No vehicles were found nearby $title.',
      loadVehicles: () => _vehiclesRepo.loadVehiclesNearby(
        position,
        radiusInMeters: radiusInMeters,
      ),
      successEvent: (vehicles) => MapEvent.addVehiclesNearbyPlace(
        vehicles: vehicles,
        position: position,
        title: title,
        radius: radiusInMeters,
      ),
    );
  }

  void _loadVehicles({
    @required String loadingMsg,
    @required String emptyResultErrorMsg,
    @required Future<Result<List<Vehicle>>> Function() loadVehicles,
    @required MapEvent Function(List<Vehicle>) successEvent,
    void Function(Failure<List<Vehicle>>) onFailure,
    void Function() beforeRetry,
  }) async {
    if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
      _signals.add(
        MapSignal.loadingError(message: 'No internet connection.', retry: null),
      );
      onFailure?.call(Failure(error: Exception('No internet connection.')));
      return;
    }

    _signals.add(MapSignal.loading(message: loadingMsg));

    final result = await loadVehicles();
    result.asyncWhen(
      success: (success) async {
        final vehicles = success.data;
        if (vehicles.isEmpty) {
          onFailure?.call(Failure(error: Exception('No vehicles found.')));
          _signals.add(
            MapSignal.loadingError(
              message: emptyResultErrorMsg,
              retry: () {
                beforeRetry?.call();
                _loadVehicles(
                  loadingMsg: loadingMsg,
                  emptyResultErrorMsg: emptyResultErrorMsg,
                  loadVehicles: loadVehicles,
                  successEvent: successEvent,
                  onFailure: onFailure,
                  beforeRetry: beforeRetry,
                );
              },
            ),
          );
        } else {
          add(successEvent(vehicles));
          final zoomToLoadedMarkersBounds = await _preferences
              .getBool(Preferences.zoomToLoadedMarkersBounds.key);
          _signals.add(
            zoomToLoadedMarkersBounds
                ? MapSignal.zoomToBoundsAfterLoadedSuccessfully(
                    bounds: vehicles
                        .map((vehicle) => LatLng(vehicle.lat, vehicle.lon))
                        .bounds,
                  )
                : MapSignal.loadedSuccessfully(),
          );
        }
      },
      failure: (failure) {
        failure.logError();
        onFailure?.call(failure);
        _signals.add(
          MapSignal.loadingError(
            message: 'Loading error occurred.',
            retry: () {
              beforeRetry?.call();
              _loadVehicles(
                loadingMsg: loadingMsg,
                emptyResultErrorMsg: emptyResultErrorMsg,
                loadVehicles: loadVehicles,
                successEvent: successEvent,
                onFailure: onFailure,
                beforeRetry: beforeRetry,
              );
            },
          ),
        );
      },
    );
  }

  void cameraMoved({
    @required LatLngBounds bounds,
    @required double zoom,
    @required bool byUser,
  }) {
    add(MapEvent.cameraMoved(bounds: bounds, zoom: zoom, byUser: byUser));
  }

  void selectVehicle(String number) {
    add(MapEvent.selectVehicle(number: number));
  }

  void deselectVehicle() {
    if (state.selectedVehicleNumber != null) add(MapEvent.deselectVehicle());
  }

  void clearMap() {
    _untrackAllLinesSink.add(Object());
    add(MapEvent.clearMap());
  }

  void removeSource(MapVehicleSource source) {
    if (source is OfLine) {
      _untrackLinesSink.add({source.line});
    }
    add(MapEvent.removeSource(source: source));
  }

  Stream<Set<MapVehicleSource>> get mapVehicleSourcesStream {
    return map((state) {
      final sources = <MapVehicleSource>{};
      state.trackedVehicles.values.forEach((tracked) {
        sources.addAll(tracked.sources);
      });
      return sources;
    });
  }
}

extension _IconifiedMarkersExt on IconifiedMarkers {
  List<IconifiedMarker> _markersToAnimate({IconifiedMarker selectedMarker}) {
    if (selectedMarker != null) {
      return nonClustered..add(selectedMarker);
    } else {
      return nonClustered;
    }
  }

  Stream<List<Marker>> animatedMarkersStream({IconifiedMarker selectedMarker}) {
    return CombineLatestStream.list(
      _markersToAnimate(selectedMarker: selectedMarker).map(
        (marker) {
          if (marker.initialPosition != null) {
            final interpolationStream = LatLngInterpolationStream()
              ..addLatLng(marker.initialPosition)
              ..addLatLng(marker.position);
            return interpolationStream
                .getLatLngInterpolation()
                .map((delta) => marker.googleMapMarker(position: delta.from))
                .tap(
                  (marker) => log('${marker.markerId.value}: has prev pos.'),
                );
          } else {
            return Stream.value(marker.toGoogleMapMarker())
                .tap((marker) => log('${marker.markerId.value}: no prev pos.'));
          }
        },
      ),
    );
  }
}

extension _MapStateExt on MapState {
  Stream<List<Marker>> get mapMarkers async* {
    final fluster = await _markersToCluster.fluster(
      minZoom: MapConstants.minClusterZoom,
      maxZoom: MapConstants.maxClusterZoom,
    );
    final iconifiedMarkers = await fluster.iconifiedMarkers(
      currentZoom: zoom,
      clusterColor: Colors.blue,
      clusterTextColor: Colors.white,
    );
    final clusteredMarkers = iconifiedMarkers.clustered
        .map((marker) => marker.googleMapMarker())
        .toList();
    yield* iconifiedMarkers
        .animatedMarkersStream(selectedMarker: await _selectedMarker)
        .map((animatedMarkers) => [...clusteredMarkers, ...animatedMarkers]);
  }

  Future<IconifiedMarker> get _selectedMarker async {
    if (selectedVehicleNumber == null) return null;
    final selected = trackedVehicles[selectedVehicleNumber];
    if (selected == null) return null;
    return IconifiedMarker(
      ClusterableMarker(
        symbol: selected.vehicle.symbol,
        id: selectedVehicleNumber,
        lat: selected.vehicle.lat,
        lng: selected.vehicle.lon,
      ),
      icon: await markerBitmap(
        symbol: selected.vehicle.symbol,
        width: MapConstants.markerWidth,
        height: MapConstants.markerHeight,
        imageAsset: await rootBundle.loadUiImage(
          ImageAssets.selectedMarker,
        ),
      ),
    );
  }

  Map<String, ClusterableMarker> get _markersToCluster {
    final markers = Map.fromEntries(
      trackedVehicles.entries.where(
        (entry) {
          final vehicle = entry.value.vehicle;
          return bounds.containsLatLng(vehicle.lat, vehicle.lon);
        },
      ),
    ).map(
      (number, tracked) {
        final vehicle = tracked.vehicle;
        return MapEntry(
          number,
          ClusterableMarker(
            id: number,
            lat: vehicle.lat,
            lng: vehicle.lon,
            number: number,
            symbol: vehicle.symbol,
            initialPosition: tracked.previousPositions.isNotEmpty
                ? tracked.previousPositions.removeLast()
                : null,
          ),
        );
      },
    );
    if (selectedVehicleNumber != null) markers.remove(selectedVehicleNumber);
    return markers;
  }

  MapState withNewVehicles(
    Iterable<Vehicle> vehicles, {
    @required MapVehicleSource Function(Vehicle) sourceForVehicle,
  }) {
    final updatedVehicles = Map.of(trackedVehicles);
    vehicles.forEach((vehicle) {
      final tracked = updatedVehicles[vehicle.number];
      if (tracked != null) {
        updatedVehicles[vehicle.number] = tracked.withUpdatedVehicle(
          vehicle,
          bounds: bounds,
          sources: tracked.sources..add(sourceForVehicle(vehicle)),
        );
      } else {
        updatedVehicles[vehicle.number] = MapVehicle.fromNewlyLoadedVehicle(
          vehicle,
          source: sourceForVehicle(vehicle),
        );
      }
    });
    return copyWith(trackedVehicles: updatedVehicles);
  }

  MapState withRemovedSource(bool Function(MapVehicleSource) sourceMatcher) {
    final updatedVehicles = Map<String, MapVehicle>();
    trackedVehicles.forEach((number, tracked) {
      final sources = tracked.sources;
      final sourceToRemove = sources.firstWhere(
        sourceMatcher,
        orElse: () => null,
      );

      if (sourceToRemove == null) {
        updatedVehicles[number] = tracked;
      } else if (sources.length == 1) {
        return;
      } else {
        updatedVehicles[number] = tracked.withRemovedSource(sourceToRemove);
      }
    });
    return copyWith(trackedVehicles: updatedVehicles);
  }
}

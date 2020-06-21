import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:transport_control/pages/map/map_bloc.dart';
import 'package:transport_control/pages/map/map_constants.dart';
import 'package:transport_control/pages/map/map_markers.dart';
import 'package:transport_control/util/asset_util.dart';
import 'package:transport_control/util/lat_lng_util.dart';
import 'package:transport_control/util/model_util.dart';
import 'package:transport_control/util/preferences_util.dart';
import 'package:transport_control/util/snack_bar_util.dart';

class MapPage extends StatefulWidget {
  final void Function() mapTapped;
  final void Function() animatedToBounds;
  final void Function() cameraMovedByUser;
  final void Function(IconifiedMarker) markerTapped;
  final ValueNotifier<LatLng> moveToPositionNotifier;

  const MapPage({
    Key key,
    @required this.mapTapped,
    @required this.animatedToBounds,
    @required this.cameraMovedByUser,
    @required this.markerTapped,
    @required this.moveToPositionNotifier,
  }) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>
    with AutomaticKeepAliveClientMixin<MapPage> {
  final _preferences = GetIt.instance<RxSharedPreferences>();
  final _mapController = Completer<GoogleMapController>();
  final _subscriptions = <StreamSubscription>[];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    final bloc = context.bloc<MapBloc>();
    _subscriptions
      ..add(
        bloc
            .where((state) => state.selectedVehicleNumber != null)
            .map(
              (state) => state.trackedVehicles[state.selectedVehicleNumber]
                  .vehicle.position,
            )
            .distinct()
            .debounce(const Duration(milliseconds: 250))
            .listen(
          (position) async {
            final controller = await _mapController.future;
            controller.animateCamera(
              CameraUpdate.newLatLng(
                LatLng(position.latitude, position.longitude),
              ),
            );
          },
        ),
      )
      ..add(
        bloc.listenToLoadingSignalTrackers(
          (tracker) {
            tracker.signal.when(
              loading: (loading) {
                Scaffold.of(context).showNewLoadingSnackBar(
                  text: loading.message,
                  currentlyLoading: tracker.currentlyLoading,
                );
              },
              loadedSuccessfully: (_) {
                if (tracker.currentlyLoading == 0) {
                  Scaffold.of(context).hideCurrentSnackBar();
                } else {
                  Scaffold.of(context).showNewLoadedSuccessfullySnackBar(
                    tracker: tracker,
                    getScaffoldState: () => Scaffold.of(context),
                  );
                }
              },
              loadingError: (loadingError) {
                Scaffold.of(context).showNewLoadingErrorSnackBar(
                  tracker: tracker,
                  getScaffoldState: () => Scaffold.of(context),
                  errorMessage: loadingError.message,
                  retry: loadingError.retry,
                  autoHide: true,
                );
              },
              zoomToBoundsAfterLoadedSuccessfully: (signal) {
                if (tracker.currentlyLoading == 0) {
                  Scaffold.of(context).hideCurrentSnackBar();
                } else {
                  Scaffold.of(context).showNewLoadedSuccessfullySnackBar(
                    tracker: tracker,
                    getScaffoldState: () => Scaffold.of(context),
                  );
                }

                _mapController.future.then(
                  (controller) => controller.animateCamera(
                    CameraUpdate.newLatLngBounds(signal.bounds, 10.0),
                  ),
                );
              },
            );
          },
        ),
      )
      ..add(
        _preferences
            .themeBrightnessStream(context: () => context)
            .listen((brightness) async {
          final controller = await _mapController.future;
          controller.setMapStyle(brightness == Brightness.light
              ? await rootBundle.loadString(JsonAssets.darkMapStyle)
              : null);
        }),
      );

    widget.moveToPositionNotifier.addListener(() async {
      final latLng = widget.moveToPositionNotifier.value;
      if (latLng != null) {
        final controller = await _mapController.future;
        controller.animateCamera(CameraUpdate.newLatLng(latLng));
      }
    });
  }

  @override
  void dispose() {
    _subscriptions.forEach((subscription) {
      subscription.cancel();
    });
    super.dispose();
  }

  bool _cameraWasMovedByUser = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder<List<IconifiedMarker>>(
      stream: context.bloc<MapBloc>().markers,
      builder: (context, snapshot) => Listener(
        onPointerDown: (event) => _cameraWasMovedByUser = true,
        child: GoogleMap(
          zoomControlsEnabled: false,
          rotateGesturesEnabled: false,
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: MapConstants.initialTarget,
            zoom: MapConstants.initialZoom,
          ),
          onMapCreated: _mapController.complete,
          onCameraIdle: () => _cameraMoved(context),
          markers: snapshot.data == null
              ? null
              : snapshot.data
                  .map(
                    (marker) => marker.toGoogleMapMarker(
                      onTap: marker.isCluster
                          ? () => _animateToClusterChildrenBounds(
                                marker.childrenPositions,
                              )
                          : () {
                              widget.markerTapped(marker);
                              _cameraWasMovedByUser = false;
                            },
                    ),
                  )
                  .toSet(),
          onTap: (position) {
            context.bloc<MapBloc>().deselectVehicle();
            widget.mapTapped();
          },
        ),
      ),
    );
  }

  void _cameraMoved(BuildContext context) async {
    final controller = await _mapController.future;
    final results = await Future.wait([
      controller.getVisibleRegion(),
      controller.getZoomLevel(),
    ]);
    context.bloc<MapBloc>().cameraMoved(
          bounds: results[0] as LatLngBounds,
          zoom: results[1] as double,
          byUser: _cameraWasMovedByUser,
        );
    if (_cameraWasMovedByUser) {
      widget.cameraMovedByUser();
      _cameraWasMovedByUser = false;
    }
  }

  void _animateToClusterChildrenBounds(List<LatLng> childrenPositions) async {
    final controller = await _mapController.future;
    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(childrenPositions.bounds, 50),
    );
    widget.animatedToBounds();
  }
}

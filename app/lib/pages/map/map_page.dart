import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transport_control/pages/map/map_bloc.dart';
import 'package:transport_control/pages/map/map_constants.dart';
import 'package:transport_control/pages/map/map_markers.dart';
import 'package:transport_control/pages/map/map_signal.dart';
import 'package:transport_control/util/lat_lng_util.dart';
import 'package:transport_control/util/model_util.dart';
import 'package:transport_control/util/snack_bar_util.dart';

class MapPage extends StatefulWidget {
  final void Function() mapTapped;
  final void Function() animatedToBounds;
  final void Function(IconifiedMarker) markerTapped;
  final ValueNotifier<LatLng> moveToPositionNotifier;

  const MapPage({
    Key key,
    @required this.mapTapped,
    @required this.animatedToBounds,
    @required this.markerTapped,
    @required this.moveToPositionNotifier,
  }) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>
    with AutomaticKeepAliveClientMixin<MapPage> {
  final _mapController = Completer<GoogleMapController>();
  StreamSubscription<LoadingSignalTracker<MapSignal, Loading>>
      _signalTrackersSubscription;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _signalTrackersSubscription =
        context.bloc<MapBloc>().listenToLoadingSignalTrackers(
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
    _signalTrackersSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder<List<IconifiedMarker>>(
      stream: context.bloc<MapBloc>().markers,
      builder: (context, snapshot) => GoogleMap(
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
                        : () => widget.markerTapped(marker),
                  ),
                )
                .toSet(),
        onTap: (position) {
          context.bloc<MapBloc>().mapTapped();
          widget.mapTapped();
        },
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
        );
  }

  void _animateToClusterChildrenBounds(List<LatLng> childrenPositions) async {
    final controller = await _mapController.future;
    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(childrenPositions.bounds, 50),
    );
    widget.animatedToBounds();
  }
}

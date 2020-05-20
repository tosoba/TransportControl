import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transport_control/pages/map/map_bloc.dart';
import 'package:transport_control/pages/map/map_constants.dart';
import 'package:transport_control/pages/map/map_markers.dart';
import 'package:transport_control/pages/map/map_signal.dart';
import 'package:transport_control/util/lat_lng_util.dart';

class MapPage extends StatefulWidget {
  final void Function() mapTapped;
  final void Function() animatedToBounds;
  final void Function(IconifiedMarker) markerTapped;

  const MapPage({
    Key key,
    @required this.mapTapped,
    @required this.animatedToBounds,
    @required this.markerTapped,
  }) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>
    with AutomaticKeepAliveClientMixin<MapPage> {
  final Completer<GoogleMapController> _mapController = Completer();
  StreamSubscription<MapSignal> _signalsSubscription;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _signalsSubscription = context.bloc<MapBloc>().signals.listen(
          (signal) => signal.when(
            loading: (loading) {
              Scaffold.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(loading.message),
                    duration: const Duration(days: 1),
                  ),
                );
            },
            loadedSuccessfully: (_) =>
                Scaffold.of(context).hideCurrentSnackBar(),
            loadingError: (loadingError) {
              Scaffold.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(loadingError.message)));
            },
            zoomToBoundsAfterLoadedSuccessfully: (signal) {
              Scaffold.of(context).hideCurrentSnackBar();
              _mapController.future.then(
                (controller) => controller.animateCamera(
                  CameraUpdate.newLatLngBounds(signal.bounds, 10.0),
                ),
              );
            },
          ),
        );
  }

  @override
  void dispose() {
    _signalsSubscription?.cancel();
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
                        : () => _markerTapped(marker),
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

  void _markerTapped(IconifiedMarker marker) {
    context.bloc<MapBloc>().markerTapped(marker.number);
    widget.markerTapped(marker);
  }
}

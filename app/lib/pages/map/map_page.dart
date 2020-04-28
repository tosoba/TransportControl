import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transport_control/pages/map/map_bloc.dart';
import 'package:transport_control/pages/map/map_constants.dart';
import 'package:transport_control/pages/map/map_markers.dart';
import 'package:transport_control/pages/map/map_signal.dart';

class MapPage extends StatefulWidget {
  final void Function() mapTapped;

  const MapPage({Key key, @required this.mapTapped}) : super(key: key);

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
  void dispose() {
    _signalsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final bloc = context.bloc<MapBloc>();
    _signalsSubscription = bloc.signals.listen(
      (signal) => signal.when(
        loading: (loading) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(loading.message),
              duration: Duration(days: 1),
            ),
          );
        },
        loadedSuccessfully: (_) => Scaffold.of(context).hideCurrentSnackBar(),
        loadingError: (loadingError) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(loadingError.message)),
            );
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

    return StreamBuilder<List<IconifiedMarker>>(
      stream: bloc.markers,
      builder: (context, snapshot) {
        return GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: MapConstants.initialTarget,
            zoom: MapConstants.initialZoom,
          ),
          onMapCreated: _mapController.complete,
          onCameraIdle: () => _mapController.future
              .then((controller) => _cameraMoved(context, controller)),
          markers: snapshot.data == null
              ? null
              : snapshot.data
                  .map(
                    (marker) => marker.toGoogleMapMarker(
                      onTap: marker.isCluster
                          ? () => _zoomOnCluster(marker.position)
                          : () => _markerTapped(marker.number),
                    ),
                  )
                  .toSet(),
          onTap: (position) {
            context.bloc<MapBloc>().mapTapped();
            widget.mapTapped();
          },
        );
      },
    );
  }

  void _cameraMoved(BuildContext context, GoogleMapController controller) {
    Future.wait([
      controller.getVisibleRegion(),
      controller.getZoomLevel(),
    ]).then((results) {
      context.bloc<MapBloc>().cameraMoved(
            bounds: results[0] as LatLngBounds,
            zoom: results[1] as double,
          );
    });
  }

  void _zoomOnCluster(LatLng position) {
    _mapController.future.then((controller) async {
      final increasedZoom = (await controller.getZoomLevel()) + 1.0;
      controller.animateCamera(
        increasedZoom < MapConstants.maxClusterZoom
            ? CameraUpdate.newLatLngZoom(position, increasedZoom)
            : CameraUpdate.newLatLng(position),
      );
    });
  }

  void _markerTapped(String id) {
    context.bloc<MapBloc>().markerTapped(id);
  }
}

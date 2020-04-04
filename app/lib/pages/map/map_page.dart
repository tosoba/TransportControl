import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transport_control/pages/map/map_bloc.dart';
import 'package:transport_control/pages/map/map_constants.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>
    with AutomaticKeepAliveClientMixin<MapPage> {
  Completer<GoogleMapController> _mapController = Completer();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder<Set<Marker>>(
      stream: context.bloc<MapBloc>().markers,
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
          markers: snapshot.data,
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
}

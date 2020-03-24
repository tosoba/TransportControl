import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transport_control/pages/map/map_bloc.dart';
import 'package:transport_control/pages/map/map_constants.dart';
import 'package:transport_control/pages/map/map_state.dart';

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
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        return GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: MapConstants.initialTarget,
            zoom: MapConstants.initialZoom,
          ),
          onMapCreated: _mapController.complete,
          onCameraIdle: () => _mapController.future
              .then((controller) => _cameraMoved(context, controller)),
          markers: state.trackedVehiclesMap
              .map(
                (number, animated) => MapEntry(
                  number,
                  Marker(
                    markerId: MarkerId(number),
                    position: LatLng(
                      animated.stage.current.latitude,
                      animated.stage.current.longitude,
                    ),
                    infoWindow: InfoWindow(
                      title: 'Last updated at: ${animated.vehicle.lastUpdate}',
                    ),
                  ),
                ),
              )
              .values
              .toSet(),
        );
      },
    );
  }

  _cameraMoved(BuildContext context, GoogleMapController controller) {
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

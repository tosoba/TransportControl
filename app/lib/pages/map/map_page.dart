import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transport_control/pages/map/map_bloc.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>
    with AutomaticKeepAliveClientMixin<MapPage> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<MapBloc, MapState>(
      listener: (context, state) {
        log('Number of lines: ${state.trackedLines.length}');
        log('Number of vehicles: ${state.trackedVehicles.length}');
      },
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(52.237049, 21.017532),
          zoom: 11,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

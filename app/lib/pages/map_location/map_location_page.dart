import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transport_control/pages/map_location/map_location_page_mode.dart';
import 'package:transport_control/pages/map/map_constants.dart';

class MapLocationPage extends StatefulWidget {
  final MapLocationPageMode mode;

  const MapLocationPage({Key key, this.mode}) : super(key: key);

  @override
  _MapLocationPageState createState() => _MapLocationPageState();
}

class _MapLocationPageState extends State<MapLocationPage> {
  final Completer<GoogleMapController> _mapController = Completer();

  @override
  Widget build(BuildContext context) {
    final query = MediaQuery.of(context);
    final size = query.size;
    final List<Widget> boundsLimiters = [];
    if (query.orientation == Orientation.portrait) {
      final boundsLimiterHeight = (size.height - size.width) / 2;
      boundsLimiters.add(
        Container(
          width: double.infinity,
          height: boundsLimiterHeight,
          color: Colors.white,
        ),
      );
      boundsLimiters.add(
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            height: boundsLimiterHeight,
            color: Colors.white,
          ),
        ),
      );
    } else {
      final boundsLimiterWidth = (size.width - size.height) / 2;
      boundsLimiters.add(
        Container(
          width: boundsLimiterWidth,
          height: double.infinity,
          color: Colors.white,
        ),
      );
      boundsLimiters.add(
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: boundsLimiterWidth,
            height: double.infinity,
            color: Colors.white,
          ),
        ),
      );
    }
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: MapConstants.initialTarget,
                zoom: MapConstants.initialZoom,
              ),
              onMapCreated: _mapController.complete,
            ),
            ...boundsLimiters
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() {
    //TODO: show dialog if in edit/add mode asking for save/cancel confirmation
    return Future.value(true);
  }
}

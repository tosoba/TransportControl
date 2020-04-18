import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transport_control/pages/map_location/map_location_page_mode.dart';
import 'package:transport_control/pages/map/map_constants.dart';
import 'package:transport_control/widgets/circular_icon_button.dart';
import 'package:transport_control/widgets/search_app_bar.dart';

class MapLocationPage extends HookWidget {
  final MapLocationPageMode _mode;
  final Completer<GoogleMapController> _mapController = Completer();

  MapLocationPage(this._mode, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchFieldFocusNode = useFocusNode();
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        resizeToAvoidBottomPadding: false,
        appBar: SearchAppBar(
          searchFieldFocusNode: searchFieldFocusNode,
          leading: _backButton(searchFieldFocusNode, context),
          hint: 'Location name',
          onChanged: (query) {},
        ),
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
            ..._boundsLimiters(context)
          ],
        ),
      ),
    );
  }

  Widget _backButton(
    FocusNode searchFieldFocusNode,
    BuildContext context,
  ) {
    return CircularButton(
      child: Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () {
        if (searchFieldFocusNode.hasFocus) {
          searchFieldFocusNode.unfocus();
        } else {
          Navigator.pop(context);
        }
      },
    );
  }

  List<Widget> _boundsLimiters(BuildContext context) {
    final query = MediaQuery.of(context);
    final size = query.size;
    if (query.orientation == Orientation.portrait) {
      final boundsLimiterHeight = (size.height - size.width) / 2;
      final limiter = boundsLimiter(height: boundsLimiterHeight);
      return [
        limiter,
        Align(alignment: Alignment.bottomCenter, child: limiter),
      ];
    } else {
      final boundsLimiterWidth = (size.width - size.height) / 2;
      final limiter = boundsLimiter(width: boundsLimiterWidth);
      return [
        limiter,
        Align(alignment: Alignment.centerRight, child: limiter),
      ];
    }
  }

  Widget boundsLimiter({
    double width = double.infinity,
    double height = double.infinity,
  }) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: width,
          height: height,
          color: Colors.black.withOpacity(0),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() {
    //TODO: show dialog if in edit/add mode asking for save/cancel confirmation
    return Future.value(true);
  }
}

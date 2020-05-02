import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transport_control/model/location.dart';
import 'package:transport_control/pages/map_location/map_location_page_mode.dart';
import 'package:transport_control/pages/map/map_constants.dart';
import 'package:transport_control/pages/map_location/map_location_page_result.dart';
import 'package:transport_control/pages/map_location/map_location_page_result_action.dart';
import 'package:transport_control/widgets/text_field_app_bar.dart';
import 'package:transport_control/widgets/text_field_app_bar_back_button.dart';

class MapLocationPage extends HookWidget {
  final MapLocationPageMode _mode;
  final Completer<GoogleMapController> _mapController = Completer();

  MapLocationPage(this._mode, {Key key}) : super(key: key);

  ValueNotifier<Location> _useLocationState(TextEditingController controller) {
    return useState(
      _mode.when(
        add: (mode) => Location.initial(),
        existing: (mode) {
          controller.value = TextEditingValue(text: mode.location.name);
          return mode.location;
        },
      ),
    );
  }

  LatLng _targetFor(Location location) {
    final bounds = location.bounds;
    return bounds != null
        ? LatLng(
            (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
            (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
          )
        : MapConstants.initialTarget;
  }

  @override
  Widget build(BuildContext context) {
    final textFieldFocusNode = useFocusNode();
    final textFieldController = useTextEditingController();
    final location = _useLocationState(textFieldController);
    textFieldController.addListener(() {
      location.value = location.value.copyWith(
        name: textFieldController.value.text?.trim(),
      );
    });
    final readOnly = useState(
      _mode.when(add: (_) => false, existing: (mode) => !mode.edit),
    );

    final queryData = MediaQuery.of(context);

    //TODO: reset bounds button for existing mode
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        resizeToAvoidBottomPadding: false,
        //TODO: trailing reset name button for existing mode
        appBar: TextFieldAppBar(
          textFieldController: textFieldController,
          textFieldFocusNode: textFieldFocusNode,
          leading: TextFieldAppBarBackButton(
            textFieldFocusNode,
            textFieldDisabled: readOnly.value,
          ),
          hint: 'Location name',
          enabled: !readOnly.value,
          readOnly: readOnly.value,
        ),
        body: Stack(
          children: [
            _googleMap(
              location: location,
              readOnly: readOnly,
              queryData: queryData,
            ),
            ..._boundsLimiters(queryData),
          ],
        ),
        //TODO: replace these with bottom nav buttons like in HomePage
        persistentFooterButtons: [
          if (!readOnly.value)
            Builder(
              builder: (context) => RaisedButton(
                color: Colors.white,
                onPressed: () => _savePressed(
                  context,
                  location: location,
                  action: MapLocationPageResultAction.save(),
                ),
                child: Text(
                  'Save',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          RaisedButton(
            color: Colors.white,
            onPressed: () => Navigator.pop(
              context,
              MapLocationPageResult(
                location: location.value.copyWith(
                  lastSearched: DateTime.now(),
                  timesSearched: location.value.timesSearched + 1,
                ),
                mode: _mode,
                action: MapLocationPageResultAction.load(),
              ),
            ),
            child: Text(
              'Load',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          if (!readOnly.value)
            Builder(
              builder: (context) => RaisedButton(
                color: Colors.white,
                child: Text(
                  'Save & load',
                  style: const TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  location.value = location.value.copyWith(
                    lastSearched: DateTime.now(),
                    timesSearched: location.value.timesSearched + 1,
                  );
                  _savePressed(
                    context,
                    location: location,
                    action: MapLocationPageResultAction.saveAndLoad(),
                  );
                },
              ),
            )
        ],
      ),
    );
  }

  void _savePressed(
    BuildContext context, {
    @required ValueNotifier<Location> location,
    @required MapLocationPageResultAction action,
  }) {
    final locationValue = location.value;
    if (locationValue.name == null || locationValue.name.trim().isEmpty) {
      Scaffold.of(context).showSnackBar(
        SnackBar(content: Text('Enter a name for location to save')),
      );
    } else {
      Navigator.pop(
        context,
        MapLocationPageResult(
          location: location.value,
          mode: _mode,
          action: action,
        ),
      );
    }
  }

  GoogleMap _googleMap({
    @required ValueNotifier<Location> location,
    @required ValueNotifier<bool> readOnly,
    @required MediaQueryData queryData,
  }) {
    final interactionEnabled = !readOnly.value;
    return GoogleMap(
      mapType: MapType.normal,
      rotateGesturesEnabled: interactionEnabled,
      scrollGesturesEnabled: interactionEnabled,
      zoomGesturesEnabled: interactionEnabled,
      tiltGesturesEnabled: interactionEnabled,
      //TODO:
      // minMaxZoomPreference: MinMaxZoomPreference(
      //   MapConstants.minLocationPageMapZoom,
      //   MapConstants.maxLocationPageMapZoom,
      // ),
      initialCameraPosition: CameraPosition(
        target: _targetFor(location.value),
        zoom: MapConstants.initialZoom,
      ),
      onMapCreated: (controller) {
        _mapController.complete(controller);
        if (location.value.bounds != null) {
          Future.delayed(
            const Duration(milliseconds: 200),
            () => controller.moveCamera(
              CameraUpdate.newLatLngBounds(location.value.bounds, 0),
            ),
          );
        }
      },
      onCameraIdle: () {
        if (!readOnly.value) {
          _updateLocationBounds(location, _screenCoordinateBounds(queryData));
        }
      },
    );
  }

  _ScreenCoordinateBounds _screenCoordinateBounds(MediaQueryData queryData) {
    final size = queryData.size;
    final dpr = queryData.devicePixelRatio;
    if (queryData.orientation == Orientation.portrait) {
      final southWestScreenCoordinate = ScreenCoordinate(
        x: 0,
        y: ((size.height + size.width) / 2 * dpr).toInt(),
      );
      final northEastScreenCoordinate = ScreenCoordinate(
        x: (size.width * dpr).toInt(),
        y: ((size.height - size.width) / 2 * dpr).toInt(),
      );
      return _ScreenCoordinateBounds(
        northEast: northEastScreenCoordinate,
        southWest: southWestScreenCoordinate,
      );
    } else {
      final southWestScreenCoordinate = ScreenCoordinate(
        x: ((size.width - size.height) / 2 * dpr).toInt(),
        y: (size.height * dpr).toInt(),
      );
      final northEastScreenCoordinate = ScreenCoordinate(
        x: ((size.height + size.width) / 2 * dpr).toInt(),
        y: 0,
      );
      return _ScreenCoordinateBounds(
        northEast: northEastScreenCoordinate,
        southWest: southWestScreenCoordinate,
      );
    }
  }

  void _updateLocationBounds(
    ValueNotifier<Location> location,
    _ScreenCoordinateBounds bounds,
  ) {
    _mapController.future
        .then(
          (controller) => Future.wait([
            controller.getLatLng(bounds.southWest),
            controller.getLatLng(bounds.northEast)
          ]),
        )
        .then(
          (boundsLatLngs) => location.value = location.value.copyWith(
            bounds: LatLngBounds(
              southwest: boundsLatLngs[0],
              northeast: boundsLatLngs[1],
            ),
          ),
        );
  }

  List<Widget> _boundsLimiters(MediaQueryData queryData) {
    final size = queryData.size;
    if (queryData.orientation == Orientation.portrait) {
      final boundsLimiterHeight = (size.height - size.width) / 2;
      final limiter = _boundsLimiter(height: boundsLimiterHeight);
      return [
        limiter,
        Align(alignment: Alignment.bottomCenter, child: limiter),
      ];
    } else {
      final boundsLimiterWidth = (size.width - size.height) / 2;
      final limiter = _boundsLimiter(width: boundsLimiterWidth);
      return [
        limiter,
        Align(alignment: Alignment.centerRight, child: limiter),
      ];
    }
  }

  Widget _boundsLimiter({
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

class _ScreenCoordinateBounds {
  final ScreenCoordinate northEast;
  final ScreenCoordinate southWest;

  _ScreenCoordinateBounds({@required this.northEast, @required this.southWest});
}

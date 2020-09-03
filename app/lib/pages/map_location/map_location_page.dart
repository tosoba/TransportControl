import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:transport_control/model/location.dart';
import 'package:transport_control/pages/map_location/map_location_page_mode.dart';
import 'package:transport_control/pages/map/map_constants.dart';
import 'package:transport_control/pages/map_location/map_location_page_result.dart';
import 'package:transport_control/pages/map_location/map_location_page_result_action.dart';
import 'package:transport_control/util/asset_util.dart';
import 'package:transport_control/util/preferences_util.dart';
import 'package:transport_control/widgets/circular_icon_button.dart';
import 'package:transport_control/widgets/preferred_size_wrapped.dart';
import 'package:transport_control/widgets/slide_transition_preferred_size_widget.dart';
import 'package:transport_control/widgets/text_field_app_bar.dart';
import 'package:transport_control/widgets/text_field_app_bar_back_button.dart';

class MapLocationPage extends HookWidget {
  final MapLocationPageMode mode;
  final void Function({@required MapLocationPageResult result}) finishWith;
  final _mapController = Completer<GoogleMapController>();
  final _preferences = GetIt.instance<RxSharedPreferences>();

  MapLocationPage({
    Key key,
    @required this.mode,
    @required this.finishWith,
  }) : super(key: key);

  ValueNotifier<Location> _useLocationState() {
    return useState(
      mode.when(
        add: (mode) => Location.initial(),
        existing: (mode) => mode.location,
      ),
    );
  }

  TextEditingController _useLocationNameEditingController() {
    return mode.when(
      add: (_) => useTextEditingController(),
      existing: (mode) => useTextEditingController
          .fromValue(TextEditingValue(text: mode.location.name)),
    );
  }

  LatLng get _initialMapTarget {
    return mode.when(
      add: (_) => MapConstants.initialTarget,
      existing: (mode) {
        final bounds = mode.location.bounds;
        return LatLng(
          (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
          (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textFieldFocusNode = useFocusNode();
    final textFieldController = _useLocationNameEditingController();
    final location = _useLocationState();
    textFieldController.addListener(() {
      location.value = location.value.copyWith(
        name: textFieldController.value.text?.trim(),
      );
    });

    final mapTapAnimController = useAnimationController(
      duration: kThemeAnimationDuration,
    );
    final appBarOffset = useMemoized(
      () => Tween(begin: Offset.zero, end: const Offset(0.0, -1.0))
          .animate(mapTapAnimController),
    );
    final bottomNavSize = useMemoized(
      () => Tween(begin: 1.0, end: 0.0).animate(mapTapAnimController),
    );
    final controlsOpacity = useMemoized(
      () => Tween(begin: 1.0, end: 0.0).animate(mapTapAnimController),
    );

    _preferences.useThemeBrightness(
      context: () => context,
      onChanged: (brightness) async {
        final controller = await _mapController.future;
        controller.setMapStyle(brightness == Brightness.dark
            ? await rootBundle.loadString(JsonAssets.darkMapStyle)
            : null);
      },
    );

    final appBar = TextFieldAppBar(
      textFieldController: textFieldController,
      textFieldFocusNode: textFieldFocusNode,
      leading: TextFieldAppBarBackButton(textFieldFocusNode),
      hint: 'Location name',
      trailing: _trailingResetNameButton(
        context,
        textFieldController: textFieldController,
      ),
    );

    final queryData = MediaQuery.of(context);

    return WillPopScope(
      onWillPop: () => _onWillPop(context, location: location),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        resizeToAvoidBottomPadding: false,
        appBar: SlideTransitionPreferredSizeWidget(
          offset: appBarOffset,
          child: PreferredSizeWrapped(
            size: appBar.size,
            child: FadeTransition(child: appBar, opacity: controlsOpacity),
          ),
        ),
        body: Stack(
          children: [
            _googleMap(
              location: location,
              queryData: queryData,
              mapTapAnimController: mapTapAnimController,
            ),
            ..._boundsLimiters(queryData),
          ],
        ),
        floatingActionButton: _floatingActionButton(
          location: location,
          textFieldController: textFieldController,
        ),
        bottomNavigationBar: SizeTransition(
          child: _bottomNavBar(
            context,
            location: location,
            controlsOpacity: controlsOpacity,
          ),
          sizeFactor: bottomNavSize,
        ),
      ),
    );
  }

  Widget _trailingResetNameButton(
    BuildContext context, {
    @required TextEditingController textFieldController,
  }) {
    if (textFieldController.value == null ||
        textFieldController.value.text.isEmpty) return null;
    return Row(children: [
      CircularButton(
        child: Icon(
          Icons.close,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        onPressed: () {
          textFieldController.value = TextEditingValue();
        },
      ),
    ]);
  }

  Widget _floatingActionButton({
    @required ValueNotifier<Location> location,
    @required TextEditingController textFieldController,
  }) {
    return mode.when(
      add: (_) => null,
      existing: (mode) => FloatingActionButton.extended(
        onPressed: () async {
          final preEditLocation = mode.location;
          location.value = preEditLocation;
          if (textFieldController.value.text != preEditLocation.name) {
            textFieldController.value = TextEditingValue(
              text: preEditLocation.name,
            );
          }
          final controller = await _mapController.future;
          controller.animateCamera(
            CameraUpdate.newLatLngBounds(preEditLocation.bounds, 0),
          );
        },
        icon: Icon(Icons.restore),
        label: Text('Reset'),
      ),
    );
  }

  Widget _bottomNavBar(
    BuildContext context, {
    @required ValueNotifier<Location> location,
    @required Animation<double> controlsOpacity,
  }) {
    return Container(
      height: kBottomNavigationBarHeight,
      child: Align(
        alignment: Alignment.centerRight,
        child: ListView(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          children: [
            _bottomNavBarButton(
              context,
              labelText: 'Save',
              controlsOpacity: controlsOpacity,
              onPressed: () {
                if (mode is Add) {
                  location.value = location.value.copyWith(
                    savedAt: DateTime.now(),
                  );
                }
                _savePressed(
                  context,
                  location: location,
                  action: MapLocationPageResultAction.save(),
                );
              },
            ),
            _bottomNavBarButton(
              context,
              labelText: 'Load',
              controlsOpacity: controlsOpacity,
              onPressed: () {
                finishWith(
                  result: MapLocationPageResult(
                    location: location.value.copyWith(
                      lastSearched: DateTime.now(),
                      timesSearched: location.value.timesSearched + 1,
                    ),
                    mode: mode,
                    action: MapLocationPageResultAction.load(),
                  ),
                );
                Navigator.pop(context);
              },
            ),
            _bottomNavBarButton(
              context,
              labelText: 'Save & load',
              controlsOpacity: controlsOpacity,
              onPressed: () {
                location.value = location.value.copyWith(
                  lastSearched: DateTime.now(),
                  timesSearched: location.value.timesSearched + 1,
                  savedAt: mode is Add ? DateTime.now() : null,
                );
                _savePressed(
                  context,
                  location: location,
                  action: MapLocationPageResultAction.saveAndLoad(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavBarButton(
    BuildContext context, {
    @required String labelText,
    @required void Function() onPressed,
    @required Animation<double> controlsOpacity,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FadeTransition(
        opacity: controlsOpacity,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          color: Theme.of(context).primaryColor,
          onPressed: onPressed,
          child: Text(
            labelText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 18),
          ),
        ),
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
      finishWith(
        result: MapLocationPageResult(
          location: location.value,
          mode: mode,
          action: action,
        ),
      );
      Navigator.pop(context);
    }
  }

  Widget _googleMap({
    @required ValueNotifier<Location> location,
    @required MediaQueryData queryData,
    @required AnimationController mapTapAnimController,
  }) {
    return GoogleMap(
      zoomControlsEnabled: false,
      rotateGesturesEnabled: false,
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: _initialMapTarget,
        zoom: MapConstants.initialZoom,
      ),
      onMapCreated: (controller) {
        _mapController.complete(controller);
        Future.delayed(const Duration(milliseconds: 200), () async {
          if (location.value.bounds != null) {
            controller.moveCamera(
              CameraUpdate.newLatLngBounds(location.value.bounds, 0),
            );
          } else {
            final bounds = await controller.getVisibleRegion();
            location.value = location.value.copyWith(bounds: bounds);
          }
        });
      },
      onCameraIdle: () => _updateLocationBounds(
        location,
        _screenCoordinateBounds(queryData),
      ),
      onTap: (_) => _mapTapped(mapTapAnimController),
    );
  }

  void _mapTapped(AnimationController mapTapAnimController) {
    if (mapTapAnimController.isCompleted) {
      mapTapAnimController.reverse();
    } else {
      mapTapAnimController.forward();
    }
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
  ) async {
    final controller = await _mapController.future;
    final boundsLatLngs = await Future.wait([
      controller.getLatLng(bounds.southWest),
      controller.getLatLng(bounds.northEast)
    ]);
    location.value = location.value.copyWith(
      bounds: LatLngBounds(
        southwest: boundsLatLngs[0],
        northeast: boundsLatLngs[1],
      ),
    );
  }

  List<Widget> _boundsLimiters(MediaQueryData queryData) {
    final size = queryData.size;
    if (queryData.orientation == Orientation.portrait) {
      final boundsLimiterHeight = (size.height - size.width) / 2;
      return [
        _boundsLimiter(
          height: boundsLimiterHeight,
          border: const Border(
            top: const BorderSide(width: 1, color: Colors.transparent),
            bottom: const BorderSide(width: 1, color: Colors.redAccent),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: _boundsLimiter(
            height: boundsLimiterHeight,
            border: const Border(
              top: const BorderSide(width: 1, color: Colors.redAccent),
              bottom: const BorderSide(width: 1, color: Colors.transparent),
            ),
          ),
        ),
      ];
    } else {
      final boundsLimiterWidth = (size.width - size.height) / 2;
      return [
        _boundsLimiter(
          width: boundsLimiterWidth,
          border: const Border(
            right: const BorderSide(width: 1, color: Colors.redAccent),
            left: const BorderSide(width: 1, color: Colors.transparent),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: _boundsLimiter(
            width: boundsLimiterWidth,
            border: const Border(
              right: const BorderSide(width: 1, color: Colors.transparent),
              left: const BorderSide(width: 1, color: Colors.redAccent),
            ),
          ),
        ),
      ];
    }
  }

  Widget _boundsLimiter({
    @required Border border,
    double width = double.infinity,
    double height = double.infinity,
  }) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            border: border,
            color: Colors.black.withOpacity(0),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop(
    BuildContext context, {
    @required ValueNotifier<Location> location,
  }) {
    return mode.when(
      add: (_) => Future.value(true),
      existing: (mode) => showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          content: Text("Discard changes?"),
          actions: [
            FlatButton(
              child: const Text('Yes'),
              onPressed: () => Navigator.pop(context, true),
            ),
            FlatButton(
              child: const Text('No'),
              onPressed: () => Navigator.pop(context, false),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScreenCoordinateBounds {
  final ScreenCoordinate northEast;
  final ScreenCoordinate southWest;

  _ScreenCoordinateBounds({@required this.northEast, @required this.southWest});
}

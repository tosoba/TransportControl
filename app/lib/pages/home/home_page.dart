import 'package:auto_size_text/auto_size_text.dart';
import 'package:connection_status_bar/connection_status_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:snaplist/snaplist.dart';
import 'package:transport_control/di/module/controllers_module.dart';
import 'package:transport_control/pages/lines/lines_bloc.dart';
import 'package:transport_control/pages/lines/lines_page.dart';
import 'package:transport_control/pages/locations/locations_bloc.dart';
import 'package:transport_control/pages/locations/locations_page.dart';
import 'package:transport_control/pages/map/map_bloc.dart';
import 'package:transport_control/pages/map/map_markers.dart';
import 'package:transport_control/pages/map/map_page.dart';
import 'package:transport_control/pages/nearby/nearby_bloc.dart';
import 'package:transport_control/pages/nearby/nearby_page.dart';
import 'package:transport_control/pages/settings/settings_page.dart';
import 'package:transport_control/pages/tracked/tracked_page.dart';
import 'package:transport_control/repo/locations_repo.dart';
import 'package:transport_control/util/string_util.dart';
import 'package:transport_control/widgets/circular_icon_button.dart';
import 'package:transport_control/widgets/text_field_app_bar.dart';
import 'package:transport_control/widgets/slide_transition_preferred_size_widget.dart';

enum _HomeSubPage { map, places }

class HomePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final currentPage = useState(_HomeSubPage.map);

    final placesPageAnimController = useAnimationController(
      duration: kThemeAnimationDuration,
    );
    final placesPageOffset = useMemoized(
      () => Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(placesPageAnimController),
    );

    final mapTapAnimController = useAnimationController(
      duration: kThemeAnimationDuration,
    );
    final appBarOffset = useMemoized(
      () => Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(0.0, -1.0),
      ).animate(mapTapAnimController),
    );
    final connectivityStatusBarOffset = useMemoized(
      () => Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(0.0, -0.58),
      ).animate(mapTapAnimController),
    );
    final bottomNavSize = useMemoized(
      () => Tween(
        begin: 1.0,
        end: 0.0,
      ).animate(mapTapAnimController),
    );
    final bottomNavButtonsOpacity = useMemoized(
      () => Tween<double>(
        begin: 1.0,
        end: 0.0,
      ).animate(mapTapAnimController),
    );

    final bottomSheetController =
        useState<PersistentBottomSheetController>(null);

    final searchFieldFocusNode = useFocusNode();
    searchFieldFocusNode.addListener(() {
      if (searchFieldFocusNode.hasFocus &&
          currentPage.value != _HomeSubPage.places)
        _changeSubPage(
          _HomeSubPage.places,
          currentPage: currentPage,
          placesPageAnimController: placesPageAnimController,
          mapTapAnimController: mapTapAnimController,
          bottomSheetController: bottomSheetController,
        );
    });
    final searchFieldController = useTextEditingController();
    searchFieldController.addListener(
      () => context
          .bloc<NearbyBloc>()
          .queryUpdated(searchFieldController.value.text, submitted: false),
    );

    final drawerItemTextGroup = useMemoized(() => AutoSizeGroup());

    return WillPopScope(
      onWillPop: () => _onWillPop(
        currentPage: currentPage,
        searchFieldFocusNode: searchFieldFocusNode,
        mapTapAnimController: mapTapAnimController,
        placesPageAnimController: placesPageAnimController,
        bottomSheetController: bottomSheetController,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        resizeToAvoidBottomPadding: false,
        appBar: SlideTransitionPreferredSizeWidget(
          offset: appBarOffset,
          child: _appBar(
            currentPage: currentPage,
            searchFieldFocusNode: searchFieldFocusNode,
            searchFieldController: searchFieldController,
            placesPageAnimController: placesPageAnimController,
            mapTapAnimController: mapTapAnimController,
            bottomSheetController: bottomSheetController,
          ),
        ),
        body: Builder(
          builder: (context) => Stack(children: [
            MapPage(
              mapTapped: () => _mapTapped(mapTapAnimController),
              animatedToBounds: () => _hideControls(mapTapAnimController),
              markerTapped: (marker) => _markerTapped(
                marker: marker,
                bottomSheetController: bottomSheetController,
                context: context,
              ),
            ),
            SlideTransition(
              child: NearbyPage(),
              position: placesPageOffset,
            ),
            SlideTransition(
              position: connectivityStatusBarOffset,
              child: ConnectionStatusBar(),
            ),
          ]),
        ),
        bottomNavigationBar: Visibility(
          visible: currentPage.value == _HomeSubPage.map,
          child: SizeTransition(
            child: _bottomNavBar(
              context,
              bottomNavButtonsOpacity: bottomNavButtonsOpacity,
              bottomSheetController: bottomSheetController,
            ),
            sizeFactor: bottomNavSize,
          ),
        ),
        drawer: _navigationDrawer(
          context,
          drawerItemTextGroup: drawerItemTextGroup,
          bottomSheetController: bottomSheetController,
        ),
      ),
    );
  }

  Future<bool> _onWillPop({
    @required ValueNotifier<_HomeSubPage> currentPage,
    @required FocusNode searchFieldFocusNode,
    @required AnimationController placesPageAnimController,
    @required AnimationController mapTapAnimController,
    @required
        ValueNotifier<PersistentBottomSheetController> bottomSheetController,
  }) {
    if (currentPage.value == _HomeSubPage.places) {
      _showMapPage(
        currentPage: currentPage,
        searchFieldFocusNode: searchFieldFocusNode,
        placesPageAnimController: placesPageAnimController,
        mapTapAnimController: mapTapAnimController,
        bottomSheetController: bottomSheetController,
      );
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  Widget _bottomNavBar(
    BuildContext context, {
    @required Animation<double> bottomNavButtonsOpacity,
    @required
        ValueNotifier<PersistentBottomSheetController> bottomSheetController,
  }) {
    return StreamBuilder<bool>(
      stream: context
          .bloc<MapBloc>()
          .map((state) => state.trackedVehicles.isNotEmpty),
      builder: (context, snapshot) => Container(
        height: kBottomNavigationBarHeight,
        child: Align(
          alignment: Alignment.centerRight,
          child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: [
              _bottomNavBarButton(
                labelText: Strings.lines,
                onPressed: () {
                  bottomSheetController.value?.close();
                  _showLinesPage(context);
                },
                bottomNavButtonsOpacity: bottomNavButtonsOpacity,
                icon: Icons.grid_on,
              ),
              _bottomNavBarButton(
                labelText: Strings.locations,
                onPressed: () {
                  bottomSheetController.value?.close();
                  _showLocationsPage(context);
                },
                bottomNavButtonsOpacity: bottomNavButtonsOpacity,
                icon: Icons.location_on,
              ),
              if (snapshot.data ?? false)
                _bottomNavBarButton(
                  labelText: 'Tracked',
                  onPressed: () {
                    bottomSheetController.value?.close();
                    _showTrackedPage(context);
                  },
                  bottomNavButtonsOpacity: bottomNavButtonsOpacity,
                  icon: Icons.track_changes,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomNavBarButton({
    @required String labelText,
    @required void Function() onPressed,
    @required Animation<double> bottomNavButtonsOpacity,
    @required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FadeTransition(
        opacity: bottomNavButtonsOpacity,
        child: RaisedButton.icon(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          icon: Icon(icon),
          color: Colors.white,
          onPressed: onPressed,
          label: Text(
            labelText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }

  TextFieldAppBar _appBar({
    @required FocusNode searchFieldFocusNode,
    @required TextEditingController searchFieldController,
    @required ValueNotifier<_HomeSubPage> currentPage,
    @required AnimationController placesPageAnimController,
    @required AnimationController mapTapAnimController,
    @required
        ValueNotifier<PersistentBottomSheetController> bottomSheetController,
  }) {
    return TextFieldAppBar(
      textFieldFocusNode: searchFieldFocusNode,
      textFieldController: searchFieldController,
      leading: _leadingAppBarButton(
        currentPage: currentPage,
        searchFieldFocusNode: searchFieldFocusNode,
        placesPageAnimController: placesPageAnimController,
        mapTapAnimController: mapTapAnimController,
        bottomSheetController: bottomSheetController,
      ),
      hint: Strings.transportNearby,
      onChanged: (query) {},
    );
  }

  void _changeSubPage(
    _HomeSubPage page, {
    @required ValueNotifier<_HomeSubPage> currentPage,
    @required AnimationController placesPageAnimController,
    @required AnimationController mapTapAnimController,
    @required
        ValueNotifier<PersistentBottomSheetController> bottomSheetController,
  }) {
    currentPage.value = page;
    if (page == _HomeSubPage.map) {
      placesPageAnimController.reverse();
    } else if (page == _HomeSubPage.places) {
      bottomSheetController.value?.close();
      placesPageAnimController.forward();
      mapTapAnimController.reverse();
    }
  }

  void _showMapPage({
    @required FocusNode searchFieldFocusNode,
    @required ValueNotifier<_HomeSubPage> currentPage,
    @required AnimationController placesPageAnimController,
    @required AnimationController mapTapAnimController,
    @required
        ValueNotifier<PersistentBottomSheetController> bottomSheetController,
  }) {
    searchFieldFocusNode.unfocus();
    _changeSubPage(
      _HomeSubPage.map,
      currentPage: currentPage,
      placesPageAnimController: placesPageAnimController,
      mapTapAnimController: mapTapAnimController,
      bottomSheetController: bottomSheetController,
    );
  }

  Widget _leadingAppBarButton({
    @required ValueNotifier<_HomeSubPage> currentPage,
    @required FocusNode searchFieldFocusNode,
    @required AnimationController placesPageAnimController,
    @required AnimationController mapTapAnimController,
    @required
        ValueNotifier<PersistentBottomSheetController> bottomSheetController,
  }) {
    return Builder(
      builder: (context) => CircularButton(
        child: Icon(
          currentPage.value == _HomeSubPage.places
              ? Icons.arrow_back
              : Icons.menu,
          color: Colors.black,
        ),
        onPressed: () {
          if (currentPage.value == _HomeSubPage.places) {
            _showMapPage(
              searchFieldFocusNode: searchFieldFocusNode,
              currentPage: currentPage,
              placesPageAnimController: placesPageAnimController,
              mapTapAnimController: mapTapAnimController,
              bottomSheetController: bottomSheetController,
            );
          } else {
            Scaffold.of(context).openDrawer();
          }
        },
      ),
    );
  }

  void _showLinesPage(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.bloc<LinesBloc>(),
          child: LinesPage(),
        ),
      ),
    );
  }

  void _showLocationsPage(BuildContext context) async {
    final getIt = GetIt.instance;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider<LocationsBloc>(
          create: (_) => LocationsBloc(
            getIt<LocationsRepo>(),
            getIt<LoadVehiclesInBounds>().injected.sink,
            getIt<LoadVehiclesNearby>().injected.sink,
          ),
          child: LocationsPage(),
        ),
      ),
    );
  }

  void _showTrackedPage(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.bloc<MapBloc>(),
          child: TrackedPage(),
        ),
      ),
    );
  }

  Widget _drawerListTile({
    @required String labelText,
    @required AutoSizeGroup group,
    @required IconData icon,
    @required void Function() onTap,
  }) {
    return ListTile(
      title: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Icon(icon),
          ),
          Expanded(
            child: AutoSizeText(
              labelText,
              style: const TextStyle(fontSize: 16),
              group: group,
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _navigationDrawer(
    BuildContext context, {
    @required AutoSizeGroup drawerItemTextGroup,
    @required
        ValueNotifier<PersistentBottomSheetController> bottomSheetController,
  }) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Text(Strings.transportControl),
            decoration: const BoxDecoration(color: Colors.blue),
          ),
          _drawerListTile(
            labelText: Strings.lines,
            icon: Icons.grid_on,
            group: drawerItemTextGroup,
            onTap: () {
              Navigator.pop(context);
              bottomSheetController.value?.close();
              _showLinesPage(context);
            },
          ),
          _drawerListTile(
            labelText: Strings.locations,
            icon: Icons.location_on,
            group: drawerItemTextGroup,
            onTap: () {
              Navigator.pop(context);
              bottomSheetController.value?.close();
              _showLocationsPage(context);
            },
          ),
          _drawerListTile(
            labelText: 'Settings',
            icon: Icons.settings,
            group: drawerItemTextGroup,
            onTap: () {
              Navigator.pop(context);
              bottomSheetController.value?.close();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  void _mapTapped(AnimationController mapTapAnimController) {
    if (mapTapAnimController.isCompleted) {
      mapTapAnimController.reverse();
    } else {
      mapTapAnimController.forward();
    }
  }

  void _hideControls(AnimationController mapTapAnimController) {
    mapTapAnimController.forward();
  }

  void _markerTapped({
    @required IconifiedMarker marker,
    @required BuildContext context,
    @required
        ValueNotifier<PersistentBottomSheetController> bottomSheetController,
  }) {
    final vehicles =
        context.bloc<MapBloc>().state.trackedVehicles.entries.toList();
    bottomSheetController.showIfClosed(
      context: context,
      builder: (context) {
        final Size cardSize = const Size(300.0, 460.0);
        return SnapList(
          padding: EdgeInsets.only(
              left: (MediaQuery.of(context).size.width - cardSize.width) / 2),
          sizeProvider: (index, data) => cardSize,
          separatorProvider: (index, data) => const Size(10.0, 10.0),
          snaplistController: SnaplistController(
            initialPosition:
                vehicles.indexWhere((entry) => entry.key == marker.number),
          ),
          builder: (context, index, data) {
            final tracked = vehicles.elementAt(index).value;
            return ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(color: Colors.red),
                child: Text(
                  'Last updated ${tracked.vehicle.lastUpdate}',
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
            );
          },
          count: vehicles.length,
        );
      },
    );
  }
}

extension PersistantBottomSheetExt
    on ValueNotifier<PersistentBottomSheetController> {
  void showIfClosed({
    @required BuildContext context,
    @required Widget Function(BuildContext) builder,
  }) {
    if (value == null) {
      final controller = showBottomSheet(
        context: context,
        builder: builder,
        backgroundColor: Colors.transparent,
      );
      value = controller;
      controller.closed.then((_) => value = null);
    }
  }
}

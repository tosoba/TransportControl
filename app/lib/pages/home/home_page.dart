import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:connection_status_bar/connection_status_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:transport_control/di/module/controllers_module.dart';
import 'package:transport_control/pages/lines/lines_bloc.dart';
import 'package:transport_control/pages/lines/lines_page.dart';
import 'package:transport_control/pages/locations/locations_bloc.dart';
import 'package:transport_control/pages/locations/locations_page.dart';
import 'package:transport_control/pages/map/map_bloc.dart';
import 'package:transport_control/pages/map/map_markers.dart';
import 'package:transport_control/pages/map/map_page.dart';
import 'package:transport_control/pages/map/map_vehicle.dart';
import 'package:transport_control/pages/nearby/nearby_bloc.dart';
import 'package:transport_control/pages/nearby/nearby_page.dart';
import 'package:transport_control/pages/settings/settings_page.dart';
import 'package:transport_control/pages/tracked/tracked_page.dart';
import 'package:transport_control/repo/locations_repo.dart';
import 'package:transport_control/util/model_util.dart';
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

    final bottomSheetControllers =
        useState<_VehiclesBottomSheetCarouselControllers>(null);

    final searchFieldFocusNode = useFocusNode();
    searchFieldFocusNode.addListener(() {
      if (searchFieldFocusNode.hasFocus &&
          currentPage.value != _HomeSubPage.places)
        _changeSubPage(
          _HomeSubPage.places,
          currentPage: currentPage,
          placesPageAnimController: placesPageAnimController,
          mapTapAnimController: mapTapAnimController,
          bottomSheetControllers: bottomSheetControllers,
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
        bottomSheetControllers: bottomSheetControllers,
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
            bottomSheetControllers: bottomSheetControllers,
          ),
        ),
        body: Builder(
          builder: (context) => Stack(children: [
            MapPage(
              mapTapped: () => _mapTapped(mapTapAnimController),
              animatedToBounds: () => _hideControls(mapTapAnimController),
              markerTapped: (marker) => bottomSheetControllers.showIfClosed(
                context,
                marker: marker,
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
              bottomSheetControllers: bottomSheetControllers,
            ),
            sizeFactor: bottomNavSize,
          ),
        ),
        drawer: _navigationDrawer(
          context,
          drawerItemTextGroup: drawerItemTextGroup,
          bottomSheetControllers: bottomSheetControllers,
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
        ValueNotifier<_VehiclesBottomSheetCarouselControllers>
            bottomSheetControllers,
  }) {
    if (currentPage.value == _HomeSubPage.places) {
      _showMapPage(
        currentPage: currentPage,
        searchFieldFocusNode: searchFieldFocusNode,
        placesPageAnimController: placesPageAnimController,
        mapTapAnimController: mapTapAnimController,
        bottomSheetControllers: bottomSheetControllers,
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
        ValueNotifier<_VehiclesBottomSheetCarouselControllers>
            bottomSheetControllers,
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
                  bottomSheetControllers.close();
                  _showLinesPage(context);
                },
                bottomNavButtonsOpacity: bottomNavButtonsOpacity,
                icon: Icons.grid_on,
              ),
              _bottomNavBarButton(
                labelText: Strings.locations,
                onPressed: () {
                  bottomSheetControllers.close();
                  _showLocationsPage(context);
                },
                bottomNavButtonsOpacity: bottomNavButtonsOpacity,
                icon: Icons.location_on,
              ),
              if (snapshot.data ?? false)
                _bottomNavBarButton(
                  labelText: 'Tracked',
                  onPressed: () {
                    bottomSheetControllers.close();
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
        ValueNotifier<_VehiclesBottomSheetCarouselControllers>
            bottomSheetControllers,
  }) {
    return TextFieldAppBar(
      textFieldFocusNode: searchFieldFocusNode,
      textFieldController: searchFieldController,
      leading: _leadingAppBarButton(
        currentPage: currentPage,
        searchFieldFocusNode: searchFieldFocusNode,
        placesPageAnimController: placesPageAnimController,
        mapTapAnimController: mapTapAnimController,
        bottomSheetControllers: bottomSheetControllers,
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
        ValueNotifier<_VehiclesBottomSheetCarouselControllers>
            bottomSheetControllers,
  }) {
    currentPage.value = page;
    if (page == _HomeSubPage.map) {
      placesPageAnimController.reverse();
    } else if (page == _HomeSubPage.places) {
      bottomSheetControllers.close();
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
        ValueNotifier<_VehiclesBottomSheetCarouselControllers>
            bottomSheetControllers,
  }) {
    searchFieldFocusNode.unfocus();
    _changeSubPage(
      _HomeSubPage.map,
      currentPage: currentPage,
      placesPageAnimController: placesPageAnimController,
      mapTapAnimController: mapTapAnimController,
      bottomSheetControllers: bottomSheetControllers,
    );
  }

  Widget _leadingAppBarButton({
    @required ValueNotifier<_HomeSubPage> currentPage,
    @required FocusNode searchFieldFocusNode,
    @required AnimationController placesPageAnimController,
    @required AnimationController mapTapAnimController,
    @required
        ValueNotifier<_VehiclesBottomSheetCarouselControllers>
            bottomSheetControllers,
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
              bottomSheetControllers: bottomSheetControllers,
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
        ValueNotifier<_VehiclesBottomSheetCarouselControllers>
            bottomSheetControllers,
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
              bottomSheetControllers.close();
              _showLinesPage(context);
            },
          ),
          _drawerListTile(
            labelText: Strings.locations,
            icon: Icons.location_on,
            group: drawerItemTextGroup,
            onTap: () {
              Navigator.pop(context);
              bottomSheetControllers.close();
              _showLocationsPage(context);
            },
          ),
          _drawerListTile(
            labelText: 'Settings',
            icon: Icons.settings,
            group: drawerItemTextGroup,
            onTap: () {
              Navigator.pop(context);
              bottomSheetControllers.close();
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
}

extension PersistantBottomSheetExt
    on ValueNotifier<_VehiclesBottomSheetCarouselControllers> {
  void close() {
    value?.sheetController?.close();
  }

  void showIfClosed(BuildContext context, {@required IconifiedMarker marker}) {
    final bloc = context.bloc<MapBloc>();
    if (value == null) {
      final carouselController = CarouselControllerImpl();
      final sheetController = showBottomSheet(
        context: context,
        builder: (context) => StreamBuilder<List<MapEntry<String, MapVehicle>>>(
          stream: bloc.map((state) => state.trackedVehicles.entries.toList()),
          builder: (context, snapshot) {
            final vehicles = snapshot.data;
            if (vehicles == null) return Container();
            return CarouselSlider.builder(
              carouselController: carouselController,
              options: CarouselOptions(
                viewportFraction: .5,
                aspectRatio: 3.0,
                enlargeCenterPage: true,
                initialPage:
                    vehicles.indexWhere((entry) => entry.key == marker.number),
                onPageChanged: (index, reason) {},
              ),
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final tracked = vehicles.elementAt(index).value;
                return Card(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        Text(
                          tracked.vehicle.symbol,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(tracked.vehicle.updatedAgoLabel)
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        backgroundColor: Colors.transparent,
      );
      value = _VehiclesBottomSheetCarouselControllers(
        sheetController,
        carouselController,
      );
      sheetController.closed.then((_) => value = null);
    } else {
      final selectedVehicleIndex = bloc.state.trackedVehicles.entries
          .toList()
          .indexWhere((entry) => entry.key == marker.number);
      if (selectedVehicleIndex != -1) {
        value.carouselController.animateToPage(selectedVehicleIndex);
      }
    }
  }
}

class _VehiclesBottomSheetCarouselControllers {
  final PersistentBottomSheetController sheetController;
  final CarouselController carouselController;

  _VehiclesBottomSheetCarouselControllers(
    this.sheetController,
    this.carouselController,
  );
}

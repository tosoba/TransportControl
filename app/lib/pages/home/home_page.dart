import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:connection_status_bar/connection_status_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transport_control/hooks/use_unfocus_on_keyboard_hidden.dart';
import 'package:transport_control/pages/last_searched/last_searched_bloc.dart';
import 'package:transport_control/pages/last_searched/last_searched_page.dart';
import 'package:transport_control/pages/lines/lines_bloc.dart';
import 'package:transport_control/pages/lines/lines_page.dart';
import 'package:transport_control/pages/locations/locations_bloc.dart';
import 'package:transport_control/pages/locations/locations_page.dart';
import 'package:transport_control/pages/map/map_bloc.dart';
import 'package:transport_control/pages/map/map_page.dart';
import 'package:transport_control/pages/map/map_vehicle.dart';
import 'package:transport_control/pages/nearby/nearby_bloc.dart';
import 'package:transport_control/pages/nearby/nearby_page.dart';
import 'package:transport_control/pages/preferences/preferences_page.dart';
import 'package:transport_control/pages/tracked/tracked_page.dart';
import 'package:transport_control/util/model_util.dart';
import 'package:transport_control/widgets/circular_icon_button.dart';
import 'package:transport_control/widgets/last_searched_items_list.dart';
import 'package:transport_control/widgets/preferred_size_column.dart';
import 'package:transport_control/widgets/preferred_size_wrapped.dart';
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
    final controlsOpacity = useMemoized(
      () => Tween<double>(
        begin: 1.0,
        end: 0.0,
      ).animate(mapTapAnimController),
    );

    final bottomSheetControllers =
        useState<_VehiclesBottomSheetCarouselControllers>(null);
    final moveToPositionNotifier = useState<LatLng>(null);

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

    useUnfocusOnKeyboardHidden(focusNode: searchFieldFocusNode);

    final appBar = _appBar(
      context,
      currentPage: currentPage,
      searchFieldFocusNode: searchFieldFocusNode,
      searchFieldController: searchFieldController,
      placesPageAnimController: placesPageAnimController,
      mapTapAnimController: mapTapAnimController,
      bottomSheetControllers: bottomSheetControllers,
    );
    final wrappedAppBar = PreferredSizeWrapped(
      size: appBar.size,
      child: FadeTransition(
        child: appBar,
        opacity: controlsOpacity,
      ),
    );

    return WillPopScope(
      onWillPop: () => _onWillPop(
        currentPage: currentPage,
        searchFieldFocusNode: searchFieldFocusNode,
        mapTapAnimController: mapTapAnimController,
        placesPageAnimController: placesPageAnimController,
        bottomSheetControllers: bottomSheetControllers,
      ),
      child: StreamBuilder<SearchedItems>(
        stream: context
            .bloc<LastSearchedBloc>()
            .notLoadedLastSearchedItemsDataStream(
              loadedVehicleSourcesStream:
                  context.bloc<MapBloc>().mapVehicleSourcesStream,
              limit: 10,
            ),
        builder: (context, snapshot) => Scaffold(
          extendBodyBehindAppBar: true,
          extendBody: true,
          resizeToAvoidBottomPadding: false,
          appBar: SlideTransitionPreferredSizeWidget(
            offset: appBarOffset,
            child: MediaQuery.of(context).orientation == Orientation.portrait
                ? PreferredSizeColumn(
                    children: [
                      wrappedAppBar,
                      if (snapshot.data != null &&
                          snapshot.data.mostRecentItems.isNotEmpty)
                        LastSearchedItemsList(
                          itemsSnapshot: snapshot,
                          opacity: controlsOpacity,
                          lineItemPressed: context.bloc<LinesBloc>().track,
                          locationItemPressed: context
                              .bloc<LocationsBloc>()
                              .loadVehiclesInLocation,
                          morePressed: () {
                            _showLastSearchedPage(context);
                          },
                        )
                    ],
                  )
                : wrappedAppBar,
          ),
          body: Builder(
            builder: (context) => Stack(children: [
              MapPage(
                mapTapped: () => _mapTapped(
                  mapTapAnimController: mapTapAnimController,
                  bottomSheetControllers: bottomSheetControllers,
                ),
                animatedToBounds: () => _hideControls(mapTapAnimController),
                cameraMovedByUser: () {
                  bottomSheetControllers.closeBottomSheet();
                },
                markerTapped: (number) {
                  bottomSheetControllers.showOrUpdateBottomSheet(
                    context,
                    number: number,
                    moveToPositionNotifier: moveToPositionNotifier,
                  );
                },
                moveToPositionNotifier: moveToPositionNotifier,
              ),
              SlideTransition(
                child: NearbyPage(
                  suggestionSelected: () => _showMapPage(
                    currentPage: currentPage,
                    searchFieldFocusNode: searchFieldFocusNode,
                    placesPageAnimController: placesPageAnimController,
                    mapTapAnimController: mapTapAnimController,
                    bottomSheetControllers: bottomSheetControllers,
                  ),
                ),
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
                controlsOpacity: controlsOpacity,
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
    @required Animation<double> controlsOpacity,
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
                context,
                labelText: 'Lines',
                onPressed: () {
                  bottomSheetControllers.closeBottomSheet();
                  _showLinesPage(context);
                },
                controlsOpacity: controlsOpacity,
                icon: Icons.grid_on,
              ),
              _bottomNavBarButton(
                context,
                labelText: 'Locations',
                onPressed: () {
                  bottomSheetControllers.closeBottomSheet();
                  _showLocationsPage(context);
                },
                controlsOpacity: controlsOpacity,
                icon: Icons.location_on,
              ),
              if (snapshot.data ?? false)
                _bottomNavBarButton(
                  context,
                  labelText: 'Tracked',
                  onPressed: () {
                    bottomSheetControllers.closeBottomSheet();
                    _showTrackedPage(context);
                  },
                  controlsOpacity: controlsOpacity,
                  icon: Icons.track_changes,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomNavBarButton(
    BuildContext context, {
    @required String labelText,
    @required void Function() onPressed,
    @required Animation<double> controlsOpacity,
    @required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FadeTransition(
        opacity: controlsOpacity,
        child: RaisedButton.icon(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          icon: Icon(icon),
          color: Theme.of(context).primaryColor,
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

  TextFieldAppBar _appBar(
    BuildContext context, {
    @required FocusNode searchFieldFocusNode,
    @required TextEditingController searchFieldController,
    @required ValueNotifier<_HomeSubPage> currentPage,
    @required AnimationController placesPageAnimController,
    @required AnimationController mapTapAnimController,
    @required
        ValueNotifier<_VehiclesBottomSheetCarouselControllers>
            bottomSheetControllers,
  }) {
    final nearbyBloc = context.bloc<NearbyBloc>();
    return TextFieldAppBar(
      textFieldFocusNode: searchFieldFocusNode,
      textFieldController: searchFieldController,
      onSubmitted: (query) => nearbyBloc.queryUpdated(query, submitted: true),
      leading: _leadingAppBarButton(
        currentPage: currentPage,
        searchFieldFocusNode: searchFieldFocusNode,
        placesPageAnimController: placesPageAnimController,
        mapTapAnimController: mapTapAnimController,
        bottomSheetControllers: bottomSheetControllers,
      ),
      trailing: StreamBuilder<String>(
        stream: nearbyBloc.map((state) => state.query),
        builder: (context, snapshot) {
          if (snapshot.data == null || snapshot.data.isEmpty)
            return Container(width: 0.0, height: 0.0);
          return CircularButton(
            child: Icon(
              Icons.close,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            onPressed: () {
              searchFieldController.value = TextEditingValue();
            },
          );
        },
      ),
      hint: 'Search for a place...',
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
      bottomSheetControllers.closeBottomSheet();
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
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
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

  void _showLastSearchedPage(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.bloc<MapBloc>()),
            BlocProvider.value(value: context.bloc<LinesBloc>()),
            BlocProvider.value(value: context.bloc<LocationsBloc>()),
            BlocProvider.value(value: context.bloc<LastSearchedBloc>()),
          ],
          child: LastSearchedPage(filterMode: LastSearchedPageFilterMode.ALL),
        ),
      ),
    );
  }

  void _showLinesPage(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.bloc<MapBloc>()),
            BlocProvider.value(value: context.bloc<LinesBloc>()),
            BlocProvider.value(value: context.bloc<LastSearchedBloc>()),
          ],
          child: LinesPage(),
        ),
      ),
    );
  }

  void _showLocationsPage(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.bloc<LocationsBloc>()),
            BlocProvider.value(value: context.bloc<MapBloc>()),
            BlocProvider.value(value: context.bloc<LastSearchedBloc>()),
          ],
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
            child: const Text(
              'Transport Control',
              style: const TextStyle(fontSize: 22),
            ),
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          ),
          _drawerListTile(
            labelText: 'Lines',
            icon: Icons.grid_on,
            group: drawerItemTextGroup,
            onTap: () {
              Navigator.pop(context);
              bottomSheetControllers.closeBottomSheet();
              _showLinesPage(context);
            },
          ),
          _drawerListTile(
            labelText: 'Locations',
            icon: Icons.location_on,
            group: drawerItemTextGroup,
            onTap: () {
              Navigator.pop(context);
              bottomSheetControllers.closeBottomSheet();
              _showLocationsPage(context);
            },
          ),
          _drawerListTile(
            labelText: 'Preferences',
            icon: Icons.settings,
            group: drawerItemTextGroup,
            onTap: () {
              Navigator.pop(context);
              bottomSheetControllers.closeBottomSheet();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PreferencesPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  void _mapTapped({
    @required AnimationController mapTapAnimController,
    @required
        ValueNotifier<_VehiclesBottomSheetCarouselControllers>
            bottomSheetControllers,
  }) {
    if (mapTapAnimController.isCompleted) {
      mapTapAnimController.reverse();
    } else {
      mapTapAnimController.forward();
    }
    bottomSheetControllers.closeBottomSheet();
  }

  void _hideControls(AnimationController mapTapAnimController) {
    mapTapAnimController.forward();
  }
}

extension _VehiclesBottomSheetCarouselControllersExt
    on ValueNotifier<_VehiclesBottomSheetCarouselControllers> {
  void closeBottomSheet() {
    value?.sheetController?.close();
  }

  void showOrUpdateBottomSheet(
    BuildContext context, {
    @required number,
    @required ValueNotifier<LatLng> moveToPositionNotifier,
  }) {
    final bloc = context.bloc<MapBloc>();
    bloc.selectVehicle(number);

    if (value == null) {
      final carouselController = CarouselControllerImpl();
      final sheetController = showBottomSheet(
        context: context,
        builder: (context) => StreamBuilder<List<MapEntry<String, MapVehicle>>>(
          stream: bloc.map(
            (state) => state.trackedVehicles.entries.toList()
              ..sort(
                (entry1, entry2) => entry1.value.vehicle.lon
                    .compareTo(entry2.value.vehicle.lon),
              ),
          ),
          builder: (context, snapshot) {
            final entries = snapshot.data;
            if (entries == null) return Container();
            return CarouselSlider.builder(
              carouselController: carouselController,
              options: CarouselOptions(
                viewportFraction: .5,
                aspectRatio: 3.0,
                enlargeCenterPage: true,
                enableInfiniteScroll: entries.length > 2,
                initialPage: entries.indexWhere((entry) => entry.key == number),
                onPageChanged: (index, reason) {
                  final entry = entries.elementAt(index);
                  if (entry != null) {
                    bloc.selectVehicle(entry.key);
                    final vehicle = entry.value.vehicle;
                    moveToPositionNotifier.value = LatLng(
                      vehicle.lat,
                      vehicle.lon,
                    );
                  }
                },
              ),
              itemCount: entries.length,
              itemBuilder: (context, index) => _vehicleCard(
                context: context,
                tracked: entries.elementAt(index).value,
              ),
            );
          },
        ),
        backgroundColor: Colors.transparent,
      );

      value = _VehiclesBottomSheetCarouselControllers(
        sheetController,
        carouselController,
      );

      sheetController.closed.then((_) {
        bloc.deselectVehicle();
        value = null;
      });
    } else {
      final selectedVehicleIndex = bloc.state.trackedVehicles.entries
          .toList()
          .indexWhere((entry) => entry.key == number);
      if (selectedVehicleIndex != -1) {
        value.carouselController.animateToPage(selectedVehicleIndex);
      }
    }
  }

  Widget _vehicleCard({
    @required BuildContext context,
    @required MapVehicle tracked,
  }) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(5),
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tracked.vehicle.symbol,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            AutoSizeText(
              tracked.vehicle.updatedAgoLabel,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
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

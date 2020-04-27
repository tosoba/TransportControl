import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:transport_control/pages/home/home_bloc.dart';
import 'package:transport_control/pages/lines/lines_page.dart';
import 'package:transport_control/pages/locations/locations_bloc.dart';
import 'package:transport_control/pages/locations/locations_page.dart';
import 'package:transport_control/pages/map/map_page.dart';
import 'package:transport_control/pages/nearby/nearby_page.dart';
import 'package:transport_control/pages/settings/settings_page.dart';
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
        begin: Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(placesPageAnimController),
    );

    final mapTapAnimController = useAnimationController(
      duration: kThemeAnimationDuration,
    );
    final appBarOffset = useMemoized(
      () => Tween<Offset>(
        begin: Offset.zero,
        end: Offset(0.0, -1.0),
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

    final searchFieldFocusNode = useFocusNode();
    searchFieldFocusNode.addListener(() {
      if (searchFieldFocusNode.hasFocus &&
          currentPage.value != _HomeSubPage.places)
        _changeSubPage(
          _HomeSubPage.places,
          currentPage: currentPage,
          placesPageAnimController: placesPageAnimController,
          mapTapAnimController: mapTapAnimController,
        );
    });

    return WillPopScope(
      onWillPop: () => _onWillPop(
        currentPage: currentPage,
        searchFieldFocusNode: searchFieldFocusNode,
        mapTapAnimController: mapTapAnimController,
        placesPageAnimController: placesPageAnimController,
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
            placesPageAnimController: placesPageAnimController,
            mapTapAnimController: mapTapAnimController,
          ),
        ),
        body: Stack(children: [
          MapPage(mapTapped: () => _mapTapped(mapTapAnimController)),
          SlideTransition(
            child: NearbyPage(),
            position: placesPageOffset,
          )
        ]),
        bottomNavigationBar: Visibility(
          visible: currentPage.value == _HomeSubPage.map,
          child: SizeTransition(
            child: _bottomNavBar(
              context,
              bottomNavButtonsOpacity: bottomNavButtonsOpacity,
            ),
            sizeFactor: bottomNavSize,
          ),
        ),
        drawer: _navigationDrawer(context),
      ),
    );
  }

  Future<bool> _onWillPop({
    @required ValueNotifier<_HomeSubPage> currentPage,
    @required FocusNode searchFieldFocusNode,
    @required AnimationController placesPageAnimController,
    @required AnimationController mapTapAnimController,
  }) {
    if (currentPage.value == _HomeSubPage.places) {
      _showMapPage(
        currentPage: currentPage,
        searchFieldFocusNode: searchFieldFocusNode,
        placesPageAnimController: placesPageAnimController,
        mapTapAnimController: mapTapAnimController,
      );
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  Widget _bottomNavBar(
    BuildContext context, {
    @required Animation<double> bottomNavButtonsOpacity,
  }) {
    return Container(
      padding: EdgeInsets.zero,
      color: Colors.white,
      height: kBottomNavigationBarHeight,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _bottomNavBarButton(
            labelText: Strings.lines,
            onPressed: () => _showLinesPage(context),
            bottomNavButtonsOpacity: bottomNavButtonsOpacity,
            icon: Icons.grid_on,
          ),
          _bottomNavBarButton(
            labelText: Strings.locations,
            onPressed: () => _showLocationsPage(context),
            bottomNavButtonsOpacity: bottomNavButtonsOpacity,
            icon: Icons.location_on,
          ),
        ],
      ),
    );
  }

  Widget _bottomNavBarButton({
    @required String labelText,
    @required void Function() onPressed,
    @required Animation<double> bottomNavButtonsOpacity,
    @required IconData icon,
  }) {
    return Expanded(
      child: FadeTransition(
        opacity: bottomNavButtonsOpacity,
        child: FlatButton.icon(
          padding: EdgeInsets.zero,
          icon: Icon(icon),
          color: Colors.white,
          onPressed: onPressed,
          label: Text(
            labelText,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }

  TextFieldAppBar _appBar({
    @required FocusNode searchFieldFocusNode,
    @required ValueNotifier<_HomeSubPage> currentPage,
    @required AnimationController placesPageAnimController,
    @required AnimationController mapTapAnimController,
  }) {
    return TextFieldAppBar(
      textFieldFocusNode: searchFieldFocusNode,
      leading: _drawerButton(
        currentPage: currentPage,
        searchFieldFocusNode: searchFieldFocusNode,
        placesPageAnimController: placesPageAnimController,
        mapTapAnimController: mapTapAnimController,
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
  }) {
    currentPage.value = page;
    if (page == _HomeSubPage.map) {
      placesPageAnimController.reverse();
    } else if (page == _HomeSubPage.places) {
      placesPageAnimController.forward();
      mapTapAnimController.reverse();
    }
  }

  void _showMapPage({
    @required FocusNode searchFieldFocusNode,
    @required ValueNotifier<_HomeSubPage> currentPage,
    @required AnimationController placesPageAnimController,
    @required AnimationController mapTapAnimController,
  }) {
    searchFieldFocusNode.unfocus();
    _changeSubPage(
      _HomeSubPage.map,
      currentPage: currentPage,
      placesPageAnimController: placesPageAnimController,
      mapTapAnimController: mapTapAnimController,
    );
  }

  Widget _drawerButton({
    @required ValueNotifier<_HomeSubPage> currentPage,
    @required FocusNode searchFieldFocusNode,
    @required AnimationController placesPageAnimController,
    @required AnimationController mapTapAnimController,
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
            );
          } else {
            Scaffold.of(context).openDrawer();
          }
        },
      ),
    );
  }

  Future _showLinesPage(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.bloc<HomeBloc>().linesBloc,
          child: LinesPage(),
        ),
      ),
    );
  }

  Future _showLocationsPage(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider<LocationsBloc>(
          create: (_) => context.bloc<HomeBloc>().locationsBloc,
          child: LocationsPage(),
        ),
      ),
    );
  }

  Widget _drawerListTile({
    @required String labelText,
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
          Text(
            labelText,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _navigationDrawer(BuildContext context) {
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
            onTap: () {
              Navigator.pop(context);
              _showLinesPage(context);
            },
          ),
          _drawerListTile(
            labelText: Strings.locations,
            icon: Icons.location_on,
            onTap: () {
              Navigator.pop(context);
              _showLocationsPage(context);
            },
          ),
          _drawerListTile(
            labelText: 'Settings',
            icon: Icons.settings,
            onTap: () {
              Navigator.pop(context);
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
}

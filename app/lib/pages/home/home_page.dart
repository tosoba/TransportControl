import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transport_control/pages/lines/lines_bloc.dart';
import 'package:transport_control/pages/lines/lines_page.dart';
import 'package:transport_control/pages/locations/locations_page.dart';
import 'package:transport_control/pages/map/map_page.dart';
import 'package:transport_control/pages/places/places_page.dart';
import 'package:transport_control/util/string_util.dart';
import 'package:transport_control/widgets/circular_icon_button.dart';
import 'package:transport_control/widgets/search_app_bar.dart';
import 'package:transport_control/widgets/slide_transition_preferred_size_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin<HomePage> {
  FocusNode _searchFieldFocusNode;

  int _currentPageIndex = 0;
  List<Widget> _subPages;

  AnimationController _mapTapAnimController;
  Animation<Offset> _appBarOffset;
  Animation<double> _bottomNavSize;
  Animation<double> _bottomNavButtonsOpacity;

  AnimationController _placesPageAnimController;
  Animation<Offset> _placesPageOffset;

  @override
  void initState() {
    super.initState();

    _placesPageAnimController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
    );
    _placesPageOffset = Tween<Offset>(
      begin: Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(_placesPageAnimController);

    _subPages = [
      MapPage(mapTapped: _mapTapped),
      SlideTransition(
        child: PlacesPage(),
        position: _placesPageOffset,
      )
    ];

    _searchFieldFocusNode = FocusNode()
      ..addListener(() {
        if (_searchFieldFocusNode.hasFocus && _currentPageIndex != 1)
          _changeSubPage(index: 1);
      });

    _mapTapAnimController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
    );
    _appBarOffset = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0.0, -1.0),
    ).animate(_mapTapAnimController);
    _bottomNavSize = Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(_mapTapAnimController);
    _bottomNavButtonsOpacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_mapTapAnimController);
  }

  @override
  void dispose() {
    _searchFieldFocusNode.dispose();

    _mapTapAnimController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: SlideTransitionPreferredSizeWidget(
          offset: _appBarOffset,
          child: _appBar,
        ),
        body: _subPagesStack,
        bottomNavigationBar: Visibility(
          visible: _currentPageIndex == 0,
          child: SizeTransition(
            child: _bottomNavBar(context),
            sizeFactor: _bottomNavSize,
          ),
        ),
        drawer: _navigationDrawer(context),
      ),
    );
  }

  Future<bool> _onWillPop() {
    if (_currentPageIndex == 1) {
      _showMapPage();
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  Widget _bottomNavBar(BuildContext context) {
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
            icon: Icons.grid_on,
          ),
          _bottomNavBarButton(
            labelText: Strings.locations,
            onPressed: () => _showLocationsPage(context),
            icon: Icons.location_on,
          ),
        ],
      ),
    );
  }

  Widget _bottomNavBarButton({
    @required String labelText,
    @required void Function() onPressed,
    @required IconData icon,
  }) {
    return Expanded(
      child: FadeTransition(
        opacity: _bottomNavButtonsOpacity,
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

  SearchAppBar get _appBar {
    return SearchAppBar(
      searchFieldFocusNode: _searchFieldFocusNode,
      leading: _drawerButton,
      hint: Strings.transportNearby,
      onChanged: (query) {},
    );
  }

  void _changeSubPage({int index}) {
    setState(() => _currentPageIndex = index);
    if (index == 0) {
      _placesPageAnimController.reverse();
    } else if (index == 1) {
      _placesPageAnimController.forward();
      _mapTapAnimController.reverse();
    }
  }

  void _showMapPage() {
    _searchFieldFocusNode.unfocus();
    _changeSubPage(index: 0);
  }

  Widget get _subPagesStack {
    return Stack(children: _subPages);
  }

  Widget get _drawerButton {
    return Builder(
      builder: (context) => CircularButton(
        child: Icon(
          _currentPageIndex == 1 ? Icons.arrow_back : Icons.menu,
          color: Colors.black,
        ),
        onPressed: () {
          if (_currentPageIndex == 1) {
            _showMapPage();
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
          value: context.bloc<LinesBloc>(),
          child: LinesPage(),
        ),
      ),
    );
  }

  Future _showLocationsPage(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LocationsPage()),
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
        ],
      ),
    );
  }

  void _mapTapped() {
    if (_mapTapAnimController.isCompleted) {
      _mapTapAnimController.reverse();
    } else {
      _mapTapAnimController.forward();
    }
  }
}

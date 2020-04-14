import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transport_control/pages/lines/lines_bloc.dart';
import 'package:transport_control/pages/lines/lines_page.dart';
import 'package:transport_control/pages/locations/locations_page.dart';
import 'package:transport_control/pages/map/map_page.dart';
import 'package:transport_control/pages/places/places_page.dart';
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
  PageController _pageController;
  List<Widget> _subPages;

  AnimationController _mapTapAnimController;
  Animation<Offset> _appBarOffset;

  @override
  void initState() {
    super.initState();

    _subPages = [MapPage(mapTapped: _mapTapped), PlacesPage()];

    _searchFieldFocusNode = FocusNode()
      ..addListener(() {
        if (_searchFieldFocusNode.hasFocus && _currentPageIndex != 1)
          _changeSubPage(index: 1);
      });

    _pageController = PageController();

    _mapTapAnimController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
    );
    _appBarOffset = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0.0, -1.0),
    ).animate(_mapTapAnimController);
  }

  @override
  void dispose() {
    _searchFieldFocusNode.dispose();

    _pageController.dispose();

    _mapTapAnimController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (_currentPageIndex == 1) {
          _showMapPage();
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: SlideTransitionPreferredSizeWidget(
          offset: _appBarOffset,
          child: _appBar,
        ),
        body: _subPagesView,
        bottomNavigationBar: _bottomNavBar(context),
        drawer: _navigationDrawer(context),
      ),
    );
  }

  Widget _bottomNavBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _bottomNavBarButton(
          labelText: 'Lines',
          onPressed: () => _showLinesPage(context),
          icon: Icons.grid_on,
        ),
        _bottomNavBarButton(
          labelText: 'Locations',
          onPressed: () => _showLocationsPage(context),
          icon: Icons.location_on,
        ),
      ],
    );
  }

  Widget _bottomNavBarButton({
    @required String labelText,
    @required void Function() onPressed,
    @required IconData icon,
  }) {
    return Expanded(
      child: FlatButton.icon(
        icon: Icon(icon),
        color: Colors.white,
        onPressed: onPressed,
        label: Text(
          labelText,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  SearchAppBar get _appBar {
    return SearchAppBar(
      searchFieldFocusNode: _searchFieldFocusNode,
      leading: _drawerButton,
      hint: "Transport nearby...",
      onChanged: (query) {},
    );
  }

  void _changeSubPage({int index}) {
    setState(() {
      _currentPageIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _showMapPage() {
    _searchFieldFocusNode.unfocus();
    _changeSubPage(index: 0);
  }

  Widget get _subPagesView {
    return PageView(
      scrollDirection: Axis.vertical,
      physics: NeverScrollableScrollPhysics(),
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentPageIndex = index;
          if (index == 1) _mapTapAnimController.reverse();
        });
      },
      children: _subPages,
    );
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

  Widget _navigationDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Text('Transport Control'),
            decoration: const BoxDecoration(color: Colors.blue),
          ),
          ListTile(
            title: Text('Lines'),
            onTap: () {
              Navigator.pop(context);
              _showLinesPage(context);
            },
          ),
          ListTile(
            title: Text('Locations'),
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

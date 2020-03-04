import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:quiver/iterables.dart';
import 'package:transport_control/pages/lines/lines_bloc.dart';
import 'package:transport_control/pages/lines/lines_page.dart';
import 'package:transport_control/pages/locations/locations_page.dart';
import 'package:transport_control/pages/map/map_bloc.dart';
import 'package:transport_control/pages/map/map_page.dart';
import 'package:transport_control/repo/vehicles_repo.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomeSubPage {
  final Widget widget;
  final _HomeBottomNavMenuItem menuItem;

  _HomeSubPage(this.widget, this.menuItem);
}

class _HomeBottomNavMenuItem {
  final String title;
  final IconData icon;
  final Color color;

  _HomeBottomNavMenuItem(this.title, this.icon, this.color);
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin<HomePage> {
  int _currentPageIndex = 0;
  final List<_HomeSubPage> _subPages = [
    _HomeSubPage(
        BlocProvider(
          create: (BuildContext context) =>
              MapBloc(GetIt.instance<VehiclesRepo>()),
          child: MapPage(),
        ),
        _HomeBottomNavMenuItem('Map', Icons.map, Colors.white)),
    _HomeSubPage(
        BlocProvider(
          create: (BuildContext context) => LinesBloc(),
          child: LinesPage(),
        ),
        _HomeBottomNavMenuItem('Lines', Icons.list, Colors.white)),
    _HomeSubPage(LocationsPage(),
        _HomeBottomNavMenuItem('Locations', Icons.my_location, Colors.white))
  ];

  List<AnimationController> _fadeAnimationControllers;
  List<Key> _subPageKeys;

  @override
  void initState() {
    super.initState();

    _fadeAnimationControllers = List<AnimationController>.generate(
        _subPages.length,
        (_) => AnimationController(
            vsync: this, duration: Duration(milliseconds: 200))).toList();
    _fadeAnimationControllers[_currentPageIndex].value = 1.0;
    _subPageKeys =
        List<Key>.generate(_subPages.length, (_) => GlobalKey()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        child: Stack(
          fit: StackFit.expand,
          children: enumerate(_subPages)
              .map((indexed) => _subPageWidget(indexed.value, indexed.index))
              .toList(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPageIndex,
        backgroundColor: _subPages[_currentPageIndex].menuItem.color,
        onTap: (int index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        items: _subPages
            .map((page) => BottomNavigationBarItem(
                  icon: Icon(page.menuItem.icon),
                  title: Text(page.menuItem.title),
                ))
            .toList(),
      ),
    );
  }

  Widget _subPageWidget(_HomeSubPage subPage, int index) {
    final Widget view = FadeTransition(
      opacity: _fadeAnimationControllers[index]
          .drive(CurveTween(curve: Curves.fastOutSlowIn)),
      child: KeyedSubtree(
        key: _subPageKeys[index],
        child: subPage.widget,
      ),
    );
    if (index == _currentPageIndex) {
      _fadeAnimationControllers[index].forward();
      return view;
    } else {
      _fadeAnimationControllers[index].reverse();
      return _fadeAnimationControllers[index].isAnimating
          ? IgnorePointer(child: view)
          : Offstage(child: view);
    }
  }

  @override
  void dispose() {
    for (final controller in _fadeAnimationControllers) controller.dispose();
    super.dispose();
  }
}

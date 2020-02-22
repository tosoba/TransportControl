import 'package:flutter/material.dart';

import 'package:transport_control/pages/lines/lines_page.dart';
import 'package:transport_control/pages/locations/locations_page.dart';
import 'package:transport_control/pages/map/map_page.dart';

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

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin<HomePage> {
  int _currentPageIndex = 0;
  final List<_HomeSubPage> _mainPages = [
    _HomeSubPage(
        MapPage(), _HomeBottomNavMenuItem('Map', Icons.map, Colors.white)),
    _HomeSubPage(
        LinesPage(), _HomeBottomNavMenuItem('Lines', Icons.list, Colors.white)),
    _HomeSubPage(LocationsPage(),
        _HomeBottomNavMenuItem('Locations', Icons.my_location, Colors.white))
  ];

  List<AnimationController> _fadeAnimationControllers;
  List<Key> _pageKeys;

  @override
  void initState() {
    super.initState();

    _fadeAnimationControllers = List<AnimationController>.generate(
        _mainPages.length,
        (_) => AnimationController(
            vsync: this, duration: Duration(milliseconds: 200))).toList();
    _fadeAnimationControllers[_currentPageIndex].value = 1.0;
    _pageKeys =
        List<Key>.generate(_mainPages.length, (_) => GlobalKey()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        child: Stack(
          fit: StackFit.expand,
          children: _mainPages
              .asMap()
              .map((index, page) {
                final Widget view = FadeTransition(
                  opacity: _fadeAnimationControllers[index]
                      .drive(CurveTween(curve: Curves.fastOutSlowIn)),
                  child: KeyedSubtree(
                    key: _pageKeys[index],
                    child: page.widget,
                  ),
                );
                if (index == _currentPageIndex) {
                  _fadeAnimationControllers[index].forward();
                  return MapEntry(index, view);
                } else {
                  _fadeAnimationControllers[index].reverse();
                  return _fadeAnimationControllers[index].isAnimating
                      ? MapEntry(index, IgnorePointer(child: view))
                      : MapEntry(index, Offstage(child: view));
                }
              })
              .values
              .toList(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPageIndex,
        backgroundColor: _mainPages[_currentPageIndex].menuItem.color,
        onTap: (int index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        items: _mainPages
            .map((page) => BottomNavigationBarItem(
                  icon: Icon(page.menuItem.icon),
                  title: Text(page.menuItem.title),
                ))
            .toList(),
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in _fadeAnimationControllers) controller.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:transport_control/pages/lines_page.dart';
import 'package:transport_control/pages/locations_page.dart';
import 'package:transport_control/pages/map_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(),
    );
  }
}

class MainPageBottomMenuItem {
  final String title;
  final IconData icon;
  final Color color;

  MainPageBottomMenuItem(this.title, this.icon, this.color);
}

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with TickerProviderStateMixin<MainPage> {
  static final int _mapPageIndex = 1;
  int _currentPageIndex = _mapPageIndex;
  final List<MainPageBottomMenuItem> _bottomMenuItems = [
    MainPageBottomMenuItem('Lines', Icons.list, Colors.white),
    MainPageBottomMenuItem('Map', Icons.map, Colors.white),
    MainPageBottomMenuItem('Location', Icons.my_location, Colors.white),
  ];

  final List<Widget> mainPages = [LinesPage(), MapPage(), LocationsPage()];

  List<AnimationController> _fadeAnimationControllers;
  List<Key> _destinationKeys;

  @override
  void initState() {
    super.initState();

    _fadeAnimationControllers = _bottomMenuItems
        .map<AnimationController>((item) => AnimationController(
            vsync: this, duration: Duration(milliseconds: 200)))
        .toList();
    _fadeAnimationControllers[_currentPageIndex].value = 1.0;
    _destinationKeys =
        List<Key>.generate(_bottomMenuItems.length, (int index) => GlobalKey())
            .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        child: Stack(
          fit: StackFit.expand,
          children: mainPages
              .asMap()
              .map((index, page) {
                final Widget view = FadeTransition(
                  opacity: _fadeAnimationControllers[index]
                      .drive(CurveTween(curve: Curves.fastOutSlowIn)),
                  child: KeyedSubtree(
                    key: _destinationKeys[index],
                    child: page,
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
        backgroundColor: _bottomMenuItems[_currentPageIndex].color,
        onTap: (int index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        items: _bottomMenuItems
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  title: Text(item.title),
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

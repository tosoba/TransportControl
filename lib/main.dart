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

class _MainPageState extends State<MainPage> {
  static int _mapPageIndex = 1;
  int _currentPageIndex = _mapPageIndex;
  List<MainPageBottomMenuItem> _bottomMenuItems = [
    MainPageBottomMenuItem('Lines', Icons.list, Colors.white),
    MainPageBottomMenuItem('Map', Icons.map, Colors.white),
    MainPageBottomMenuItem('Location', Icons.my_location, Colors.white),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        child: IndexedStack(
          index: _currentPageIndex,
          children: [LinesPage(), MapPage(), LocationsPage()],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPageIndex,
        onTap: (int index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        items: _bottomMenuItems
            .map((MainPageBottomMenuItem item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  title: Text(item.title),
                ))
            .toList(),
      ),
    );
  }
}

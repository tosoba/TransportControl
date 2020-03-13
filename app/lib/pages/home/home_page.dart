import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:transport_control/pages/map/map_page.dart';
import 'package:transport_control/pages/search/search_page.dart';

class HomePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: Container(
            color: Colors.white,
            child: IconButton(
              icon: Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                _scaffoldKey.currentState.openDrawer();
              },
            ),
          ),
          titleSpacing: 0.0,
          title: Container(
            child: Text(
              'TransportControl',
              style: TextStyle(color: Colors.black),
            ),
            width: double.infinity,
            height: kToolbarHeight,
            color: Colors.white,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        body: Container(child: MapPage()),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SearchPage()),
              );
            }),
        drawer: _navigationDrawer(context),
      ));

  Widget _navigationDrawer(BuildContext context) => Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text('Drawer Header'),
              decoration: BoxDecoration(color: Colors.blue),
            ),
            ListTile(
              title: Text('Item 1'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Item 2'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
}

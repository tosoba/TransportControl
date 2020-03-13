import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:transport_control/pages/map/map_page.dart';
import 'package:transport_control/pages/search/search_page.dart';

class HomePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: true,
        appBar: _appBar,
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
      );

  Widget get _appBar => PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: AppBar(
            leading: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                ),
              ),
              child: IconButton(
                icon: Icon(Icons.menu, color: Colors.black),
                onPressed: () {
                  _scaffoldKey.currentState.openDrawer();
                },
              ),
            ),
            titleSpacing: 0.0,
            title: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15.0),
                ),
                color: Colors.white,
              ),
              child: Text(
                'TransportControl',
                style: TextStyle(color: Colors.black),
              ),
              width: double.infinity,
              height: kToolbarHeight,
            ),
            backgroundColor: Colors.transparent,
            elevation: 10,
          ),
        ),
      );

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

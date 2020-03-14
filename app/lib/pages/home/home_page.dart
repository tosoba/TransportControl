import 'package:flutter/material.dart';
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
        preferredSize: Size.fromHeight(kToolbarHeight + 10.0),
        child: Padding(
          padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
          child: AppBar(
            leading: Padding(
              padding: EdgeInsets.only(left: 2.0, top: 2.0, bottom: 2.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20.0),
                    bottomLeft: const Radius.circular(20.0),
                  ),
                  color: Colors.white,
                ),
                child: IconButton(
                  icon: Icon(Icons.menu, color: Colors.black),
                  onPressed: () {
                    _scaffoldKey.currentState.openDrawer();
                  },
                ),
              ),
            ),
            titleSpacing: 0.0,
            title: Padding(
              padding: EdgeInsets.only(right: 2.0, top: 2.0, bottom: 2.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: const Radius.circular(20.0),
                    bottomRight: const Radius.circular(20.0),
                  ),
                  color: Colors.white,
                ),
                child: Text(
                  'TransportControl',
                  style: TextStyle(color: Colors.black),
                ),
                width: double.infinity,
                height: kToolbarHeight - 4.0,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
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

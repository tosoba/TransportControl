import 'package:flutter/material.dart';
import 'package:transport_control/pages/map/map_page.dart';
import 'package:transport_control/pages/search/search_page.dart';

class HomePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: true,
        appBar: _appBar(context),
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

  Widget _appBar(BuildContext context) => PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 10.0),
        child: Padding(
          padding: EdgeInsets.only(
              left: 15.0,
              right: 15.0,
              top: MediaQuery.of(context).padding.top + 10.0),
          child: Container(
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.menu, color: Colors.black),
                  onPressed: () {
                    _scaffoldKey.currentState.openDrawer();
                  },
                )
              ],
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomRight: const Radius.circular(15.0),
                topRight: const Radius.circular(15.0),
                topLeft: const Radius.circular(15.0),
                bottomLeft: const Radius.circular(15.0),
              ),
              boxShadow: [
                const BoxShadow(
                    color: Colors.grey, blurRadius: 4.0, spreadRadius: 1.0)
              ],
              color: Colors.white,
            ),
            width: double.infinity,
            height: kToolbarHeight,
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

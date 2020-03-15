import 'package:flutter/material.dart';
import 'package:quiver/iterables.dart';
import 'package:transport_control/pages/map/map_page.dart';
import 'package:transport_control/pages/places/places_page.dart';
import 'package:transport_control/pages/search/search_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _searchQueryController;

  int _currentPageIndex = 0;
  List<AnimationController> _slideAnimationControllers;
  List<Key> _subPageKeys;
  final List<Widget> _subPages = [MapPage(), PlacesPage()];

  @override
  void initState() {
    super.initState();

    _searchQueryController = TextEditingController();

    _slideAnimationControllers = List<AnimationController>.generate(
      _subPages.length,
      (_) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 200),
      ),
    ).toList();
    _slideAnimationControllers[_currentPageIndex].value = 1.0;
    _subPageKeys = List<Key>.generate(
      _subPages.length,
      (_) => GlobalKey(),
    ).toList();
  }

  @override
  void dispose() {
    _searchQueryController.dispose();
    for (final controller in _slideAnimationControllers) controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: true,
        appBar: _appBar(context),
        body: Stack(
          fit: StackFit.expand,
          children: enumerate(_subPages)
              .map((indexed) => _subPageWidget(indexed.value, indexed.index))
              .toList(),
        ),
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

  Widget _subPageWidget(Widget subPage, int index) {
    if (index == 0) return subPage;
    
    final Widget view = SlideTransition(
      position: Tween<Offset>(begin: Offset.zero, end: Offset(0.0, 1.0))
          .animate(_slideAnimationControllers[index]),
      child: KeyedSubtree(
        key: _subPageKeys[index],
        child: subPage,
      ),
    );
    if (index == _currentPageIndex) {
      _slideAnimationControllers[index].forward();
      return view;
    } else {
      _slideAnimationControllers[index].reverse();
      return _slideAnimationControllers[index].isAnimating
          ? IgnorePointer(child: view)
          : Offstage(child: view);
    }
  }

  Widget get _drawerButton => IconButton(
        icon: Icon(Icons.menu, color: Colors.black),
        onPressed: () {
          _scaffoldKey.currentState.openDrawer();
        },
      );

  Widget get _placesSearchField => TextField(
        controller: _searchQueryController,
        autofocus: false,
        decoration: InputDecoration(
          hintText: "Transport nearby...",
          border: InputBorder.none,
          labelStyle: TextStyle(color: Colors.black12),
          hintStyle: TextStyle(color: Colors.grey),
        ),
        style: TextStyle(color: Colors.white, fontSize: 16.0),
        onChanged: (query) {},
      );

  Widget _appBar(BuildContext context) => PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 10.0),
        child: Padding(
          padding: EdgeInsets.only(
            left: 15.0,
            right: 15.0,
            top: MediaQuery.of(context).padding.top + 10.0,
          ),
          child: Container(
            child: Row(
              children: [_drawerButton, Flexible(child: _placesSearchField)],
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
                  color: Colors.grey,
                  blurRadius: 4.0,
                  spreadRadius: 1.0,
                )
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

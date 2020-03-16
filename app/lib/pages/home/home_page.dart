import 'package:flutter/material.dart';
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
  final FocusNode _searchFieldFocusNode = FocusNode();

  int _currentPageIndex = 0;
  PageController _pageController;
  final List<Widget> _subPages = [MapPage(), PlacesPage()];

  @override
  void initState() {
    super.initState();

    _searchQueryController = TextEditingController();
    _searchFieldFocusNode.addListener(() {
      if (_searchFieldFocusNode.hasFocus && _currentPageIndex != 1)
        _changeSubPage(index: 1);
    });

    _pageController = PageController();
  }

  @override
  void dispose() {
    _searchQueryController.dispose();
    _searchFieldFocusNode.dispose();

    _pageController.dispose();

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
        key: _scaffoldKey,
        extendBodyBehindAppBar: true,
        appBar: _appBar(context),
        body: _subPagesView,
        floatingActionButton: _floatingActionButton(context),
        drawer: _navigationDrawer(context),
      ),
    );
  }

  _changeSubPage({int index}) {
    setState(() {
      _currentPageIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  _showMapPage() {
    _searchFieldFocusNode.unfocus();
    _changeSubPage(index: 0);
  }

  Widget get _subPagesView => PageView(
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentPageIndex = index);
        },
        children: _subPages,
      );

  Widget _appBar(BuildContext context) {
    return PreferredSize(
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
  }

  Widget get _drawerButton => IconButton(
        icon: Icon(
          _currentPageIndex == 1 ? Icons.arrow_back : Icons.menu,
          color: Colors.black,
        ),
        onPressed: () {
          if (_currentPageIndex == 1) {
            _showMapPage();
          } else {
            _scaffoldKey.currentState.openDrawer();
          }
        },
      );

  Widget get _placesSearchField => TextField(
        focusNode: _searchFieldFocusNode,
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

  Widget _floatingActionButton(BuildContext context) {
    return FloatingActionButton(
        child: Icon(Icons.grid_on),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SearchPage()),
          );
        });
  }

  Widget _navigationDrawer(BuildContext context) {
    return Drawer(
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
}

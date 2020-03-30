import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transport_control/pages/lines/lines_bloc.dart';
import 'package:transport_control/pages/lines/lines_page.dart';
import 'package:transport_control/pages/map/map_bloc.dart';
import 'package:transport_control/pages/map/map_page.dart';
import 'package:transport_control/pages/places/places_page.dart';
import 'package:transport_control/widgets/circular_icon_button.dart';
import 'package:transport_control/widgets/search_app_bar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin<HomePage> {
  final FocusNode _searchFieldFocusNode = FocusNode();

  int _currentPageIndex = 0;
  PageController _pageController;
  final List<Widget> _subPages = [MapPage(), PlacesPage()];

  @override
  void initState() {
    super.initState();

    _searchFieldFocusNode.addListener(() {
      if (_searchFieldFocusNode.hasFocus && _currentPageIndex != 1)
        _changeSubPage(index: 1);
    });

    _pageController = PageController();
  }

  @override
  void dispose() {
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
        extendBodyBehindAppBar: true,
        appBar: SearchAppBar(
          searchFieldFocusNode: _searchFieldFocusNode,
          leading: _drawerButton,
          hint: "Transport nearby...",
          onChanged: (query) {},
        ),
        body: _subPagesView,
        floatingActionButton: _floatingActionButton(context),
        drawer: _navigationDrawer(context),
      ),
    );
  }

  void _changeSubPage({int index}) {
    setState(() {
      _currentPageIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _showMapPage() {
    _searchFieldFocusNode.unfocus();
    _changeSubPage(index: 0);
  }

  Widget get _subPagesView {
    return PageView(
      scrollDirection: Axis.vertical,
      physics: NeverScrollableScrollPhysics(),
      controller: _pageController,
      onPageChanged: (index) {
        setState(() => _currentPageIndex = index);
      },
      children: _subPages,
    );
  }

  Widget get _drawerButton {
    return Builder(
      builder: (context) => CircularButton(
        child: Icon(
          _currentPageIndex == 1 ? Icons.arrow_back : Icons.menu,
          color: Colors.black,
        ),
        onPressed: () {
          if (_currentPageIndex == 1) {
            _showMapPage();
          } else {
            Scaffold.of(context).openDrawer();
          }
        },
      ),
    );
  }

  Widget _floatingActionButton(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.grid_on),
      onPressed: () => _showLinesPage(context),
    );
  }

  Future _showLinesPage(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.bloc<LinesBloc>(),
          child: LinesPage(),
        ),
      ),
    );
    if (result != null && result) {
      final lineBloc = context.bloc<LinesBloc>();
      final mapBloc = context.bloc<MapBloc>();
      mapBloc.trackedLinesAdded(lineBloc.selectedLines);
      lineBloc.selectionReset();
    }
  }

  Widget _navigationDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Text('Drawer Header'),
            decoration: const BoxDecoration(color: Colors.blue),
          ),
          ListTile(
            title: Text('Item 1'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            title: Text('Item 2'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

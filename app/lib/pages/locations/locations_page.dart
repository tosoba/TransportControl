import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:transport_control/model/location.dart';
import 'package:transport_control/pages/locations/locations_bloc.dart';
import 'package:transport_control/pages/map_location/map_location_page.dart';
import 'package:transport_control/pages/map_location/map_location_page_mode.dart';
import 'package:transport_control/pages/map_location/map_location_page_result.dart';
import 'package:transport_control/widgets/text_field_app_bar.dart';
import 'package:transport_control/widgets/text_field_app_bar_back_button.dart';
import 'package:transport_control/widgets/slide_transition_preferred_size_widget.dart';

class LocationsPage extends StatefulWidget {
  const LocationsPage({Key key}) : super(key: key);

  @override
  _LocationsPageState createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage>
    with TickerProviderStateMixin<LocationsPage> {
  final ScrollController scrollController = ScrollController();

  FocusNode _searchFieldFocusNode;
  TextEditingController _searchFieldController;

  AnimationController _scrollAnimController;
  Animation<Offset> _appBarOffset;

  @override
  void initState() {
    super.initState();

    _searchFieldController = TextEditingController()
      ..addListener(_searchTextChanged);
    _searchFieldFocusNode = FocusNode();

    _scrollAnimController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
    );
    _appBarOffset = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0.0, -1.0),
    ).animate(_scrollAnimController);
  }

  @override
  void dispose() {
    _searchFieldFocusNode.dispose();
    _searchFieldController.dispose();

    _scrollAnimController.dispose();

    super.dispose();
  }

  void _searchTextChanged() {
    context
        .bloc<LocationsBloc>()
        .nameFilterChanged(_searchFieldController.value.text);
  }

  @override
  Widget build(BuildContext context) {
    final appBar = TextFieldAppBar(
      textFieldFocusNode: _searchFieldFocusNode,
      textFieldController: _searchFieldController,
      hint: "Search locations...",
      leading: TextFieldAppBarBackButton(_searchFieldFocusNode),
      //trailing: _listOrderMenu(context), //TODO:
    );
    final topOffset =
        appBar.size.height + MediaQuery.of(context).padding.top + 10;
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: SlideTransitionPreferredSizeWidget(
        offset: _appBarOffset,
        child: appBar,
      ),
      body: _locationsList(
        topOffset: topOffset,
        locationsStream: context.bloc<LocationsBloc>().filteredLocationsStream,
      ),
      floatingActionButton: _floatingActionButton,
    );
  }

  Widget get _floatingActionButton {
    return FloatingActionButton.extended(
      onPressed: () => _showMapLocationPage(MapLocationPageMode.add()),
      label: Text(
        'New location',
        style: const TextStyle(color: Colors.black),
      ),
      icon: Icon(Icons.add, color: Colors.black),
      backgroundColor: Colors.white,
    );
  }

  void _showMapLocationPage(MapLocationPageMode mode) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapLocationPage(mode),
      ),
    );
    if (result is MapLocationPageResult) {
      result.action.when(
        save: (_) => result.mode.when(
          add: (_) =>
              context.bloc<LocationsBloc>().saveLocation(result.location),
          existing: (_) =>
              context.bloc<LocationsBloc>().updateLocation(result.location),
        ),
        load: (_) {
          //TODO:
        },
        saveAndLoad: (_) {
          //TODO:
        },
      );
    }
  }

  Widget _locationsList({
    @required double topOffset,
    @required Stream<List<Location>> locationsStream,
  }) {
    return StreamBuilder<List<Location>>(
      stream: locationsStream,
      builder: (context, snapshot) {
        if (snapshot.data == null || snapshot.data.isEmpty) {
          return Center(child: Text('No saved locations'));
        }

        return AnimationLimiter(
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  child: FadeInAnimation(
                    child: _locationListItem(snapshot.data.elementAt(index)),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _locationListItem(Location location) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Container(
        color: Colors.white,
        child: ListTile(
          title: Text(location.name),
          //subtitle: Text('SlidableDrawerDelegate'), TODO: last searched/number of searches depending on current list order
        ),
      ),
      actions: <Widget>[
        IconSlideAction(
          caption: 'Show',
          color: Colors.blue,
          icon: Icons.map,
          onTap: () => _showMapLocationPage(
            MapLocationPageMode.existing(
              location: location,
              edit: false,
            ),
          ),
        ),
        IconSlideAction(
          caption: 'Edit',
          color: Colors.indigo,
          icon: Icons.edit,
          onTap: () {},
        ),
      ],
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {},
        ),
      ],
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0 && notification is UserScrollNotification) {
      switch (notification.direction) {
        case ScrollDirection.forward:
          _scrollAnimController.reverse();
          break;
        case ScrollDirection.reverse:
          _scrollAnimController.forward();
          break;
        default:
          break;
      }
    } else if (notification is ScrollStartNotification) {
      FocusScope.of(context).unfocus();
    }
    return false;
  }
}

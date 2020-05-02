import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:transport_control/model/location.dart';
import 'package:transport_control/pages/locations/locations_bloc.dart';
import 'package:transport_control/pages/map_location/map_location_page.dart';
import 'package:transport_control/pages/map_location/map_location_page_mode.dart';
import 'package:transport_control/pages/map_location/map_location_page_result.dart';
import 'package:transport_control/pages/locations/locations_state.dart';
import 'package:transport_control/util/model_util.dart';
import 'package:transport_control/widgets/shake_transition.dart';
import 'package:transport_control/widgets/simple_connectivity_status_bar.dart';
import 'package:transport_control/widgets/text_field_app_bar.dart';
import 'package:transport_control/widgets/text_field_app_bar_back_button.dart';
import 'package:transport_control/widgets/slide_transition_preferred_size_widget.dart';

class LocationsPage extends HookWidget {
  LocationsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchFieldFocusNode = useFocusNode();
    final searchFieldController = useTextEditingController();
    searchFieldController.addListener(
      () => context
          .bloc<LocationsBloc>()
          .nameFilterChanged(searchFieldController.value.text),
    );

    final scrollAnimController = useAnimationController(
      duration: kThemeAnimationDuration,
    );
    final appBarOffset = useMemoized(
      () => Tween(begin: Offset.zero, end: Offset(0.0, -1.0))
          .animate(scrollAnimController),
    );
    final connectivityStatusBarOffset = useMemoized(
      () => Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(0.0, -0.58),
      ).animate(scrollAnimController),
    );

    final appBar = TextFieldAppBar(
      textFieldFocusNode: searchFieldFocusNode,
      textFieldController: searchFieldController,
      hint: "Search locations...",
      leading: TextFieldAppBarBackButton(searchFieldFocusNode),
      trailing: _listOrderMenu(context),
    );

    final statusBarTitleShakeTransition = ShakeTransition(
      child: const Text(
        'Please check your internet connection',
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: SlideTransitionPreferredSizeWidget(
        offset: appBarOffset,
        child: appBar,
      ),
      body: Stack(children: [
        _locationsList(
          appBarHeight: appBar.size.height,
          locationsStream:
              context.bloc<LocationsBloc>().filteredLocationsStream,
          scrollAnimationController: scrollAnimController,
          onNotConnected: () => statusBarTitleShakeTransition.shake(),
        ),
        SlideTransition(
          position: connectivityStatusBarOffset,
          child: SimpleConnectionStatusBar(
            title: statusBarTitleShakeTransition,
          ),
        ),
      ]),
      floatingActionButton: _floatingActionButton(
        onNotConnected: () => statusBarTitleShakeTransition.shake(),
      ),
    );
  }

  Widget _floatingActionButton({
    @required void Function() onNotConnected,
  }) {
    return Builder(
      builder: (context) => FloatingActionButton.extended(
        onPressed: () => _showMapLocationPage(
          context,
          mode: MapLocationPageMode.add(),
          onNotConnected: onNotConnected,
        ),
        label: Text(
          'New location',
          style: const TextStyle(color: Colors.black),
        ),
        icon: Icon(Icons.add, color: Colors.black),
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _listOrderMenu(BuildContext context) {
    return StreamBuilder<List<LocationsListOrder>>(
      stream: context.bloc<LocationsBloc>().listOrdersStream,
      builder: (context, snapshot) {
        if (snapshot.data == null || snapshot.data.isEmpty)
          return Container(width: 0.0, height: 0.0);
        return PopupMenuButton<LocationsListOrder>(
          icon: Icon(Icons.sort),
          onSelected: context.bloc<LocationsBloc>().listOrderChanged,
          itemBuilder: (context) => snapshot.data.map(
            (filter) {
              final filterString = filter.toString();
              final filterName = filterString
                  .substring(filterString.indexOf('.') + 1)
                  .replaceAll('_', ' ')
                  .toLowerCase();
              return PopupMenuItem<LocationsListOrder>(
                value: filter,
                child: Text(
                  '${filterName[0].toUpperCase()}${filterName.substring(1)}',
                ),
              );
            },
          ).toList(),
        );
      },
    );
  }

  void _showMapLocationPage(
    BuildContext context, {
    @required MapLocationPageMode mode,
    @required void Function() onNotConnected,
  }) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapLocationPage(mode),
      ),
    );
    if (result is MapLocationPageResult) {
      _handleLocationMapPageResult(
        result,
        context: context,
        onNotConnected: onNotConnected,
      );
    }
  }

  void _handleLocationMapPageResult(
    MapLocationPageResult result, {
    @required BuildContext context,
    @required void Function() onNotConnected,
  }) {
    result.action.asyncWhenOrElse(
      save: (_) => _saveOrUpdateLocation(context, result),
      orElse: (_) {
        _saveOrUpdateLocation(context, result);
        _loadVehiclesAndPop(
          context,
          result,
          onNotConnected: onNotConnected,
        );
      },
    );
  }

  void _loadVehiclesAndPop(
    BuildContext context,
    MapLocationPageResult result, {
    @required void Function() onNotConnected,
  }) async {
    if (await context
        .bloc<LocationsBloc>()
        .loadVehiclesInBounds(result.location.bounds)) {
      Navigator.pop(context);
    } else {
      onNotConnected();
    }
  }

  void _saveOrUpdateLocation(
    BuildContext context,
    MapLocationPageResult result,
  ) {
    result.mode.when(
      add: (_) => context.bloc<LocationsBloc>().saveLocation(result.location),
      existing: (_) =>
          context.bloc<LocationsBloc>().updateLocation(result.location),
    );
  }

  Widget _locationsList({
    @required double appBarHeight,
    @required Stream<FilteredLocationsResult> locationsStream,
    @required AnimationController scrollAnimationController,
    @required void Function() onNotConnected,
  }) {
    return StreamBuilder<FilteredLocationsResult>(
      stream: locationsStream,
      builder: (context, snapshot) {
        final result = snapshot.data;
        if (result == null || !result.anyLocationsSaved) {
          return Center(child: Text('No saved locations.'));
        } else if (result.locations.isEmpty && result.anyLocationsSaved) {
          return Center(child: Text('No saved locations match entered name.'));
        }

        return AnimationLimiter(
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) => _handleScrollNotification(
              notification,
              appBarHeight: appBarHeight,
              context: context,
              scrollAnimationController: scrollAnimationController,
            ),
            child: ListView.builder(
              itemCount: result.locations.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  child: FadeInAnimation(
                    child: _locationListItem(
                      result.locations.elementAt(index),
                      onNotConnected: onNotConnected,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _locationListItem(
    Location location, {
    @required void Function() onNotConnected,
  }) {
    return Builder(
      builder: (context) => StreamBuilder<LocationsListOrder>(
        stream: context.bloc<LocationsBloc>().listOrderStream,
        builder: (context, snapshot) {
          if (snapshot.data == null) return Container();
          return Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            child: Container(
              color: Colors.white,
              child: ListTile(
                title: Text(location.name),
                subtitle: Text(
                  snapshot.data == LocationsListOrder.TIMES_SEARCHED
                      ? location.timesSearchedInfo
                      : location.lastSearchedInfo,
                ),
              ),
            ),
            actions: [
              IconSlideAction(
                caption: 'Show',
                color: Colors.blue,
                icon: Icons.map,
                onTap: () => _showMapLocationPage(
                  context,
                  mode: MapLocationPageMode.existing(
                    location: location,
                    edit: false,
                  ),
                  onNotConnected: onNotConnected,
                ),
              ),
              IconSlideAction(
                caption: 'Edit',
                color: Colors.indigo,
                icon: Icons.edit,
                onTap: () {},
              ),
            ],
            secondaryActions: [
              IconSlideAction(
                caption: 'Delete',
                color: Colors.red,
                icon: Icons.delete,
                onTap: () {
                  context.bloc<LocationsBloc>().deleteLocation(location);
                },
              ),
            ],
          );
        },
      ),
    );
  }

//TODO: try to sync appBar offset with how much the list was scrolled...
  bool _handleScrollNotification(
    ScrollNotification notification, {
    @required double appBarHeight,
    @required BuildContext context,
    @required AnimationController scrollAnimationController,
  }) {
    if (notification.depth == 0 && notification is UserScrollNotification) {
      if (notification.metrics.maxScrollExtent > appBarHeight) {
        if (notification.direction == ScrollDirection.forward) {
          scrollAnimationController.reverse();
        } else if (notification.direction == ScrollDirection.reverse) {
          scrollAnimationController.forward();
        }
      } else if (scrollAnimationController.isAnimating ||
          scrollAnimationController.isCompleted) {
        scrollAnimationController.reverse();
      }
    } else if (notification is ScrollStartNotification) {
      FocusScope.of(context).unfocus();
    }
    return false;
  }
}

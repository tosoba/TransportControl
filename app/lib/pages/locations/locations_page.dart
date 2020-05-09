import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:transport_control/model/location.dart';
import 'package:transport_control/pages/locations/locations_bloc.dart';
import 'package:transport_control/pages/locations/locations_list_order.dart';
import 'package:transport_control/pages/map_location/map_location_page.dart';
import 'package:transport_control/pages/map_location/map_location_page_mode.dart';
import 'package:transport_control/pages/map_location/map_location_page_result.dart';
import 'package:transport_control/pages/locations/locations_state.dart';
import 'package:transport_control/util/model_util.dart';
import 'package:transport_control/widgets/floating_action_button_with_transition.dart';
import 'package:transport_control/widgets/text_field_app_bar.dart';
import 'package:transport_control/widgets/text_field_app_bar_back_button.dart';

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

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: StreamBuilder<FilteredLocationsResult>(
        stream: context.bloc<LocationsBloc>().filteredLocationsStream,
        builder: (context, snapshot) {
          final result = snapshot.data;

          final appBar = TextFieldAppBar(
            textFieldFocusNode: searchFieldFocusNode,
            textFieldController: searchFieldController,
            hint: "Search locations...",
            leading: TextFieldAppBarBackButton(searchFieldFocusNode),
            trailing: result != null && result.locations.isNotEmpty
                ? _listOrderMenu(context)
                : null,
          );

          if (result == null || !result.anyLocationsSaved) {
            return Column(children: [
              appBar,
              Expanded(child: Center(child: Text('No saved locations.'))),
            ]);
          } else if (result.locations.isEmpty && result.anyLocationsSaved) {
            return Column(children: [
              appBar,
              Expanded(
                child: Center(
                  child: Text('No saved locations match entered name.'),
                ),
              ),
            ]);
          }
          return CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                delegate: SliverTextFieldAppBarDelegate(
                  context,
                  appBar: appBar,
                ),
                floating: true,
              ),
              _locationsList(locations: result.locations),
            ],
          );
        },
      ),
      floatingActionButton: _floatingActionButton,
    );
  }

  Widget get _floatingActionButton {
    return Builder(builder: (context) {
      return FloatingActionButtonWithTransition(
        buildPage: () => MapLocationPage(
          MapLocationPageMode.add(),
          ({@required MapLocationPageResult result}) {
            _handleLocationMapPageResult(result, context: context);
          },
        ),
      );
    });
  }

  Widget _listOrderMenu(BuildContext context) {
    return StreamBuilder<List<LocationsListOrder>>(
      stream: context.bloc<LocationsBloc>().listOrdersStream,
      builder: (context, snapshot) {
        if (snapshot.data == null || snapshot.data.isEmpty)
          return Container(width: 0.0, height: 0.0);
        return PopupMenuButton<LocationsListOrder>(
          icon: const Icon(Icons.sort),
          onSelected: context.bloc<LocationsBloc>().listOrderChanged,
          itemBuilder: (context) => snapshot.data
              .map(
                (order) => PopupMenuItem<LocationsListOrder>(
                  value: order,
                  child: Text(order.props.first.toString()),
                ),
              )
              .toList(),
        );
      },
    );
  }

  void _handleLocationMapPageResult(
    MapLocationPageResult result, {
    @required BuildContext context,
  }) {
    result.action.asyncWhenOrElse(
      save: (_) => _saveOrUpdateLocation(context, result),
      orElse: (_) {
        _saveOrUpdateLocation(context, result);
        _loadVehiclesAndPop(context, result);
      },
    );
  }

  void _loadVehiclesAndPop(
    BuildContext context,
    MapLocationPageResult result,
  ) async {
    if (await context
        .bloc<LocationsBloc>()
        .loadVehiclesInBounds(result.location.bounds)) {
      Navigator.pop(context);
    } else {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('No connection.')));
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
    @required List<Location> locations,
  }) {
    return SliverList(
      delegate: SliverChildListDelegate(
        locations
            .asMap()
            .map(
              (index, location) => MapEntry(
                index,
                AnimationConfiguration.staggeredList(
                  position: index,
                  child: FadeInAnimation(
                    child: _locationListItem(location),
                  ),
                ),
              ),
            )
            .values
            .toList(),
      ),
    );
  }

  Widget _locationListItem(Location location) {
    return Builder(
      builder: (context) => StreamBuilder<LocationsListOrder>(
        stream: context.bloc<LocationsBloc>().listOrderStream,
        builder: (context, snapshot) {
          if (snapshot.data == null) return Container();
          MapLocationPageMode mode;
          return OpenContainer(
            transitionType: ContainerTransitionType.fade,
            openBuilder: (_, close) => MapLocationPage(
              mode,
              ({@required MapLocationPageResult result}) {
                _handleLocationMapPageResult(result, context: context);
              },
            ),
            tappable: false,
            closedShape: const RoundedRectangleBorder(),
            closedElevation: 0.0,
            closedBuilder: (_, showMapLocationPage) {
              return Slidable(
                actionPane: SlidableDrawerActionPane(),
                actionExtentRatio: 0.25,
                child: Container(
                  color: Colors.white,
                  child: ListTile(
                    title: Text(location.name),
                    subtitle: Text(
                      snapshot.data.when(
                        savedTimestamp: (_) => location.savedAtInfo,
                        lastSearched: (_) => location.lastSearchedInfo,
                        timesSearched: (_) => location.timesSearchedInfo,
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconSlideAction(
                    caption: 'Show',
                    color: Colors.blue,
                    icon: Icons.map,
                    onTap: () {
                      mode = MapLocationPageMode.existing(
                        location: location,
                        edit: false,
                      );
                      showMapLocationPage();
                    },
                  ),
                  IconSlideAction(
                    caption: 'Edit',
                    color: Colors.indigo,
                    icon: Icons.edit,
                    onTap: () {
                      mode = MapLocationPageMode.existing(
                        location: location,
                        edit: true,
                      );
                      showMapLocationPage();
                    },
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
          );
        },
      ),
    );
  }
}

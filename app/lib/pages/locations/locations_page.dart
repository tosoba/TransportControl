import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:transport_control/hooks/use_location_signals.dart';
import 'package:transport_control/hooks/use_map_signals.dart';
import 'package:transport_control/model/location.dart';
import 'package:transport_control/pages/locations/locations_bloc.dart';
import 'package:transport_control/pages/locations/locations_list_order.dart';
import 'package:transport_control/pages/map_location/map_location_page.dart';
import 'package:transport_control/pages/map_location/map_location_page_mode.dart';
import 'package:transport_control/pages/map_location/map_location_page_result.dart';
import 'package:transport_control/pages/locations/locations_state.dart';
import 'package:transport_control/util/model_util.dart';
import 'package:transport_control/widgets/text_field_app_bar.dart';
import 'package:transport_control/widgets/text_field_app_bar_back_button.dart';

class LocationsPage extends HookWidget {
  LocationsPage({Key key}) : super(key: key);

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final searchFieldFocusNode = useFocusNode();
    final searchFieldController = useTextEditingController();
    searchFieldController.addListener(
      () => context
          .bloc<LocationsBloc>()
          .nameFilterChanged(searchFieldController.value.text),
    );

    useLocationsSignals(scaffoldKey: _scaffoldKey, context: context);
    final mapSignalsListenTrigger = ValueNotifier<Object>(null);
    useMapSignals(
      scaffoldKey: _scaffoldKey,
      context: context,
      listenTrigger: mapSignalsListenTrigger,
    );

    return Scaffold(
      key: _scaffoldKey,
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
              _locationsList(
                locations: result.locations,
                mapSignalsListenTrigger: mapSignalsListenTrigger,
              ),
            ],
          );
        },
      ),
      floatingActionButton: _floatingActionButtons(
        context,
        loadVehiclesNearbyUserLocation: () {
          mapSignalsListenTrigger.value = Object();
          context.bloc<LocationsBloc>().loadVehiclesNearbyUserLocation();
        },
        mapSignalsListenTrigger: mapSignalsListenTrigger,
      ),
    );
  }

  Widget _floatingActionButtons(
    BuildContext context, {
    @required void Function() loadVehiclesNearbyUserLocation,
    @required ValueNotifier<Object> mapSignalsListenTrigger,
  }) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'tag1',
            child: const Icon(Icons.my_location),
            onPressed: loadVehiclesNearbyUserLocation,
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'tag2',
            child: const Icon(Icons.add),
            onPressed: () => _showMapLocationPageWithTransition(
              context,
              mode: MapLocationPageMode.add(),
              mapSignalsListenTrigger: mapSignalsListenTrigger,
            ),
          ),
        ],
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

  Widget _locationsList({
    @required List<Location> locations,
    @required ValueNotifier<Object> mapSignalsListenTrigger,
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
                    child: _locationListItem(
                      location,
                      mapSignalsListenTrigger: mapSignalsListenTrigger,
                    ),
                  ),
                ),
              ),
            )
            .values
            .toList(),
      ),
    );
  }

  Widget _locationListItem(
    Location location, {
    @required ValueNotifier<Object> mapSignalsListenTrigger,
  }) {
    return Builder(
      builder: (context) => StreamBuilder<LocationsListOrder>(
        stream: context.bloc<LocationsBloc>().listOrderStream,
        builder: (context, snapshot) {
          if (snapshot.data == null) return Container();
          return Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            child: Material(
              child: InkWell(
                onTap: () => _loadVehiclesAndPop(
                  context,
                  location: location,
                  mapSignalsListenTrigger: mapSignalsListenTrigger,
                ),
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
            ),
            actions: [
              IconSlideAction(
                caption: 'Edit',
                color: Colors.indigo,
                icon: Icons.edit,
                onTap: () {
                  _showMapLocationPageWithTransition(
                    context,
                    mode: MapLocationPageMode.existing(location: location),
                    mapSignalsListenTrigger: mapSignalsListenTrigger,
                  );
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
      ),
    );
  }

  void _showMapLocationPageWithTransition(
    BuildContext context, {
    @required MapLocationPageMode mode,
    @required ValueNotifier<Object> mapSignalsListenTrigger,
  }) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (
          BuildContext ctx,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return _mapLocationPage(
            context,
            mode: mode,
            mapSignalsListenTrigger: mapSignalsListenTrigger,
          );
        },
        transitionsBuilder: (
          BuildContext ctx,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Widget _mapLocationPage(
    BuildContext context, {
    @required MapLocationPageMode mode,
    @required ValueNotifier<Object> mapSignalsListenTrigger,
  }) {
    return MapLocationPage(
      mode: mode,
      finishWith: ({@required MapLocationPageResult result}) {
        _handleLocationMapPageResult(
          result,
          context: context,
          mapSignalsListenTrigger: mapSignalsListenTrigger,
        );
      },
    );
  }

  void _handleLocationMapPageResult(
    MapLocationPageResult result, {
    @required BuildContext context,
    @required ValueNotifier<Object> mapSignalsListenTrigger,
  }) {
    result.action.asyncWhenOrElse(
      save: (_) => _saveOrUpdateLocation(context, result),
      orElse: (_) {
        _saveOrUpdateLocation(context, result);
        _loadVehiclesAndPop(
          context,
          location: result.location,
          mapSignalsListenTrigger: mapSignalsListenTrigger,
        );
      },
    );
  }

  void _loadVehiclesAndPop(
    BuildContext context, {
    @required Location location,
    @required ValueNotifier<Object> mapSignalsListenTrigger,
  }) async {
    mapSignalsListenTrigger.value = Object();
    if (!await context.bloc<LocationsBloc>().loadVehiclesInLocation(location)) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('No connection.')));
    }
  }

  void _saveOrUpdateLocation(
    BuildContext context,
    MapLocationPageResult result,
  ) {
    result.mode.when(
      add: (_) {
        context.bloc<LocationsBloc>().saveLocation(result.location);
      },
      existing: (_) {
        context.bloc<LocationsBloc>().updateLocation(result.location);
      },
    );
  }
}

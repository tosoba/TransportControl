import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:transport_control/hooks/use_map_signals.dart';
import 'package:transport_control/hooks/use_unfocus_on_keyboard_hidden.dart';
import 'package:transport_control/model/location.dart';
import 'package:transport_control/model/searched_item.dart';
import 'package:transport_control/pages/last_searched/last_searched_bloc.dart';
import 'package:transport_control/pages/last_searched/last_searched_page.dart';
import 'package:transport_control/pages/locations/locations_bloc.dart';
import 'package:transport_control/pages/locations/locations_list_order.dart';
import 'package:transport_control/pages/map/map_bloc.dart';
import 'package:transport_control/pages/map_location/map_location_page.dart';
import 'package:transport_control/pages/map_location/map_location_page_mode.dart';
import 'package:transport_control/pages/map_location/map_location_page_result.dart';
import 'package:transport_control/pages/locations/locations_state.dart';
import 'package:transport_control/util/model_util.dart';
import 'package:transport_control/widgets/circular_icon_button.dart';
import 'package:transport_control/widgets/last_searched_items_list.dart';
import 'package:transport_control/widgets/loading_button.dart';
import 'package:transport_control/widgets/text_field_app_bar.dart';
import 'package:transport_control/widgets/text_field_app_bar_back_button.dart';

class LocationsPage extends HookWidget {
  LocationsPage({Key key}) : super(key: key);

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _locationBtnController = LoadingButtonController();

  @override
  Widget build(BuildContext context) {
    final searchFieldFocusNode = useFocusNode();
    final searchFieldController = useTextEditingController();
    searchFieldController.addListener(
      () => context
          .bloc<LocationsBloc>()
          .nameFilterChanged(searchFieldController.value.text),
    );

    final nearbyButtonEnabled = useState(true);
    _useLocationsSignals(
      context: context,
      nearbyButtonEnabled: nearbyButtonEnabled,
    );
    useMapSignals(scaffoldKey: _scaffoldKey, context: context);
    useUnfocusOnKeyboardHidden(focusNode: searchFieldFocusNode);

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
            trailing: result == null
                ? null
                : Container(
                    child: Row(
                      children: [
                        if (result.nameFilter != null &&
                            result.nameFilter.isNotEmpty)
                          CircularButton(
                            child: Icon(
                              Icons.close,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            onPressed: () {
                              searchFieldController.value = TextEditingValue();
                            },
                          ),
                        if (result.locations.isNotEmpty)
                          _listOrderMenu(context),
                      ],
                    ),
                  ),
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

          return StreamBuilder<SearchedItems>(
            stream: context
                .bloc<LastSearchedBloc>()
                .notLoadedLastSearchedItemsDataStream(
                  loadedVehicleSourcesStream:
                      context.bloc<MapBloc>().mapVehicleSourcesStream,
                )
                .map(
                  (searched) => searched.filterByType<LocationItem>(),
                ),
            builder: (context, snapshot) => CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  delegate: snapshot.data == null ||
                          snapshot.data.mostRecentItems.isEmpty ||
                          MediaQuery.of(context).orientation !=
                              Orientation.portrait
                      ? SliverTextFieldAppBarDelegate(context, appBar: appBar)
                      : SliverTextFieldAppBarWithSearchedItemsListDelegate(
                          context,
                          appBar: appBar,
                          lastSearchedItemsList: LastSearchedItemsList(
                            itemsSnapshot: snapshot,
                            locationItemPressed: context
                                .bloc<LocationsBloc>()
                                .loadVehiclesInLocation,
                            morePressed: () => _showLastSearchedPage(context),
                          ),
                        ),
                  floating: true,
                ),
                _locationsList(locations: result.locations),
              ],
            ),
          );
        },
      ),
      floatingActionButton: _floatingActionButtons(
        context,
        nearbyButtonEnabled: nearbyButtonEnabled,
        loadVehiclesNearbyUserLocation: () {
          context.bloc<LocationsBloc>().loadVehiclesNearbyUserLocation();
        },
      ),
    );
  }

  void _showLastSearchedPage(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.bloc<MapBloc>()),
            BlocProvider.value(value: context.bloc<LastSearchedBloc>()),
          ],
          child: LastSearchedPage(
              filterMode: LastSearchedPageFilterMode.LOCATIONS),
        ),
      ),
    );
  }

  Widget _floatingActionButtons(
    BuildContext context, {
    @required void Function() loadVehiclesNearbyUserLocation,
    @required ValueNotifier<bool> nearbyButtonEnabled,
  }) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingButton(
            child: Icon(
              Icons.my_location,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
            ),
            controller: _locationBtnController,
            onPressed: nearbyButtonEnabled.value
                ? loadVehiclesNearbyUserLocation
                : null,
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () => _showMapLocationPageWithTransition(
              context,
              mode: MapLocationPageMode.add(),
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
        if (snapshot.data == null || snapshot.data.isEmpty) {
          return Container(width: 0.0, height: 0.0);
        }
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

  Widget _locationsList({@required List<Location> locations}) {
    return SliverList(
      delegate: SliverChildListDelegate(
        locations
            .asMap()
            .map(
              (index, location) => MapEntry(
                index,
                AnimationConfiguration.staggeredList(
                  position: index,
                  child: FadeInAnimation(child: _locationListItem(location)),
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
          return Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            child: Material(
              child: InkWell(
                onTap: () => context
                    .bloc<LocationsBloc>()
                    .loadVehiclesInLocation(location),
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
  }) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (
          BuildContext ctx,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return _mapLocationPage(context, mode: mode);
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
  }) {
    return MapLocationPage(
      mode: mode,
      finishWith: ({@required MapLocationPageResult result}) {
        _handleLocationMapPageResult(result, context: context);
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
        context.bloc<LocationsBloc>().loadVehiclesInLocation(result.location);
      },
    );
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

  void _useLocationsSignals({
    @required BuildContext context,
    @required ValueNotifier<bool> nearbyButtonEnabled,
  }) {
    final void Function() resetAndEnableLocationBtn = () {
      Future.delayed(const Duration(seconds: 3), () {
        _locationBtnController.reset();
        nearbyButtonEnabled.value = true;
      });
    };
    useEffect(() {
      final subscription = context.bloc<LocationsBloc>().signals.listen(
        (signal) {
          signal.when(
            loading: (loading) {
              nearbyButtonEnabled.value = false;
            },
            loadingError: (loadingError) {
              _locationBtnController.error();
              resetAndEnableLocationBtn();
            },
            loadedSuccessfully: (loadedSuccessfully) {
              _locationBtnController.success();
              resetAndEnableLocationBtn();
            },
          );
        },
      );
      return subscription.cancel;
    });
  }
}

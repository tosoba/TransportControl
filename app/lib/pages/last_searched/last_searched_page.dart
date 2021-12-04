import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:transport_control/hooks/use_map_signals.dart';
import 'package:transport_control/hooks/use_unfocus_on_keyboard_hidden.dart';
import 'package:transport_control/model/searched_item.dart';
import 'package:transport_control/pages/last_searched/last_searched_bloc.dart';
import 'package:transport_control/pages/lines/lines_bloc.dart';
import 'package:transport_control/pages/locations/locations_bloc.dart';
import 'package:transport_control/pages/map/map_bloc.dart';
import 'package:transport_control/util/model_util.dart';
import 'package:transport_control/widgets/circular_icon_button.dart';
import 'package:transport_control/widgets/text_field_app_bar.dart';
import 'package:transport_control/widgets/text_field_app_bar_back_button.dart';

enum LastSearchedPageFilterMode { ALL, LINES, LOCATIONS }

class LastSearchedPage extends HookWidget {
  final LastSearchedPageFilterMode filterMode;
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  LastSearchedPage({Key key, @required this.filterMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchFieldFocusNode = useFocusNode();
    final searchFieldController = useTextEditingController();
    final filterController = useStreamController<String>();
    searchFieldController.addListener(() {
      final filter = searchFieldController.value.text;
      filterController.add(filter?.trim()?.toLowerCase() ?? filter);
    });

    useMapSignals(
      scaffoldMessengerKey: _scaffoldMessengerKey,
      context: context,
    );
    useUnfocusOnKeyboardHidden(focusNode: searchFieldFocusNode);

    return StreamBuilder<_FilteredSearchedItems>(
      stream: context
          .read<LastSearchedBloc>()
          .notLoadedLastSearchedItemsDataStream(
            loadedVehicleSourcesStream:
                context.read<MapBloc>().mapVehicleSourcesStream,
            limit: null,
          )
          .combineLatest(
            filterController.stream.startWith(null),
            (searched, String filter) => _FilteredSearchedItems(
              searched: filter == null || filter.isEmpty
                  ? searched
                  : SearchedItems(
                      mostRecentItems: searched.mostRecentItems
                          .where(
                            (entry) =>
                                entry.title.toLowerCase().contains(filter),
                          )
                          .toList(),
                      moreAvailable: searched.moreAvailable,
                    ),
              filter: filter,
            ),
          ),
      builder: (context, snapshot) {
        final filtered = snapshot.data;

        final appBar = TextFieldAppBar(
          textFieldFocusNode: searchFieldFocusNode,
          textFieldController: searchFieldController,
          hint: "Search most recent items...",
          leading: TextFieldAppBarBackButton(searchFieldFocusNode),
          trailing: filtered == null ||
                  filtered.filter == null ||
                  filtered.filter.isEmpty
              ? null
              : CircularButton(
                  child: Icon(
                    Icons.close,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                  onPressed: () {
                    searchFieldController.value = TextEditingValue();
                  },
                ),
        );

        return ScaffoldMessenger(
          key: _scaffoldMessengerKey,
          child: Scaffold(
            extendBodyBehindAppBar: true,
            extendBody: true,
            body: filtered == null || filtered.searched.mostRecentItems.isEmpty
                ? Column(children: [
                    appBar,
                    Expanded(
                      child: Center(child: const Text('No searched items.')),
                    ),
                  ])
                : CustomScrollView(slivers: [
                    SliverPersistentHeader(
                      delegate: SliverTextFieldAppBarDelegate(
                        context,
                        appBar: appBar,
                      ),
                      floating: true,
                    ),
                    _itemsList(
                      context,
                      mostRecentItems: filtered.searched.mostRecentItems,
                    ),
                  ]),
          ),
        );
      },
    );
  }

  Widget _itemsList(
    BuildContext context, {
    @required List<SearchedItem> mostRecentItems,
  }) {
    return SliverList(
      delegate: SliverChildListDelegate(
        mostRecentItems
            .asMap()
            .map(
              (index, source) => MapEntry(
                index,
                AnimationConfiguration.staggeredList(
                  position: index,
                  child: FadeInAnimation(
                    child: _lastSearchedItem(
                      source,
                      context: context,
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

  Widget _lastSearchedItem(
    SearchedItem item, {
    @required BuildContext context,
  }) {
    return Material(
      child: InkWell(
        onTap: () {
          item.when(
            lineItem: (lineItem) {
              context.read<LinesBloc>().track(lineItem.line);
            },
            locationItem: (locationItem) {
              context
                  .read<LocationsBloc>()
                  .loadVehiclesInLocation(locationItem.location);
            },
          );
        },
        child: ListTile(
          title: item.titleWidget(context),
          subtitle: Text(item.when(
            lineItem: (lineItem) => lineItem.line.lastSearchedInfo,
            locationItem: (locationItem) =>
                locationItem.location.lastSearchedInfo,
          )),
        ),
      ),
    );
  }
}

class _FilteredSearchedItems {
  final SearchedItems searched;
  final String filter;

  _FilteredSearchedItems({@required this.searched, @required this.filter});
}

extension _SearchedItemExt on SearchedItem {
  String get title {
    return when(
      lineItem: (item) => 'Vehicles of line: ${item.line.symbol}',
      locationItem: (item) => 'Vehicles nearby location: ${item.location.name}',
    );
  }

  Widget titleWidget(BuildContext context) {
    final titleTextTheme = Theme.of(context).textTheme.subtitle1;
    final normalTextStyle = titleTextTheme.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.normal,
    );
    final boldTextStyle = titleTextTheme.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );
    return when(
      lineItem: (item) => RichText(
        text: TextSpan(children: [
          TextSpan(text: 'Vehicles of line: ', style: normalTextStyle),
          TextSpan(text: item.line.symbol, style: boldTextStyle)
        ]),
        overflow: TextOverflow.ellipsis,
      ),
      locationItem: (item) => RichText(
        text: TextSpan(children: [
          TextSpan(text: 'Vehicles nearby location: ', style: normalTextStyle),
          TextSpan(text: item.location.name, style: boldTextStyle)
        ]),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

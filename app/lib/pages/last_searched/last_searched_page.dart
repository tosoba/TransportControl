import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:transport_control/model/searched_item.dart';
import 'package:transport_control/pages/last_searched/last_searched_bloc.dart';
import 'package:transport_control/pages/map/map_bloc.dart';
import 'package:transport_control/widgets/circular_icon_button.dart';
import 'package:transport_control/widgets/text_field_app_bar.dart';
import 'package:transport_control/widgets/text_field_app_bar_back_button.dart';

enum LastSearchedPageFilterMode { ALL, LINES, LOCATIONS }

class LastSearchedPage extends HookWidget {
  final LastSearchedPageFilterMode filterMode;

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

    return StreamBuilder<_FilteredSearchedItems>(
      stream: context
          .bloc<LastSearchedBloc>()
          .notLoadedLastSearchedItemsDataStream(
            loadedVehicleSourcesStream:
                context.bloc<MapBloc>().mapVehicleSourcesStream,
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
          hint: "Search...",
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

        return Scaffold(
          extendBodyBehindAppBar: true,
          extendBody: true,
          appBar: appBar,
          body: Center(child: const Text('Last searched')),
        );
      },
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
      lineItem: (item) => 'Line: ${item.line.symbol}',
      locationItem: (item) => 'Location: ${item.location.name}',
    );
  }
}

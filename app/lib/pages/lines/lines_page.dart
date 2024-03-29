import 'package:auto_size_text/auto_size_text.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:scroll_bottom_navigation_bar/scroll_bottom_navigation_bar.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:transport_control/hooks/use_map_signals.dart';
import 'package:transport_control/hooks/use_unfocus_on_keyboard_hidden.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/model/searched_item.dart';
import 'package:transport_control/pages/last_searched/last_searched_bloc.dart';
import 'package:transport_control/pages/last_searched/last_searched_page.dart';
import 'package:transport_control/pages/lines/lines_bloc.dart';
import 'package:transport_control/pages/lines/lines_state.dart';
import 'package:transport_control/pages/locations/locations_bloc.dart';
import 'package:transport_control/pages/map/map_bloc.dart';
import 'package:transport_control/util/collection_util.dart';
import 'package:transport_control/util/model_util.dart';
import 'package:transport_control/widgets/circular_icon_button.dart';
import 'package:transport_control/widgets/circular_text_icon_button.dart';
import 'package:transport_control/widgets/last_searched_items_list.dart';
import 'package:transport_control/widgets/text_field_app_bar.dart';
import 'package:transport_control/widgets/text_field_app_bar_back_button.dart';

class LinesPage extends HookWidget {
  LinesPage({Key key}) : super(key: key);

  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final _autoScrollController = AutoScrollController();

  @override
  Widget build(BuildContext context) {
    final searchFieldFocusNode = useFocusNode();
    final searchFieldController = useTextEditingController();
    searchFieldController.addListener(
      () => context
          .read<LinesBloc>()
          .symbolFilterChanged(searchFieldController.text),
    );
    final filter = context.read<LinesBloc>().state.symbolFilter;
    if (filter != null) {
      searchFieldController.value = TextEditingValue(text: filter);
    }

    _autoScrollController.bottomNavigationBar.tabListener((index) {
      _autoScrollController.scrollToIndex(
        index,
        preferPosition: AutoScrollPosition.begin,
      );
    });

    useMapSignals(
        scaffoldMessengerKey: _scaffoldMessengerKey, context: context);

    useUnfocusOnKeyboardHidden(focusNode: searchFieldFocusNode);

    return BlocBuilder<LinesBloc, LinesState>(
      builder: (context, state) => ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          extendBody: true,
          resizeToAvoidBottomInset: false,
          body: _scaffoldBody(
            context,
            state: state,
            searchFieldFocusNode: searchFieldFocusNode,
            searchFieldController: searchFieldController,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: _floatingActionButtons(context, state: state),
          bottomNavigationBar:
              _listGroupNavigationButtons(context, state: state),
        ),
      ),
    );
  }

  Widget _scaffoldBody(
    BuildContext context, {
    @required LinesState state,
    @required FocusNode searchFieldFocusNode,
    @required TextEditingController searchFieldController,
  }) {
    final appBar = _appBar(
      state: state,
      searchFieldFocusNode: searchFieldFocusNode,
      searchFieldController: searchFieldController,
    );

    if (state == null || state.lines.isEmpty) {
      return Column(children: [
        appBar,
        Expanded(child: Center(child: CircularProgressIndicator())),
      ]);
    }

    final filteredLines = state.filteredLines;

    if (filteredLines.isEmpty) {
      return Column(children: [
        appBar,
        Expanded(child: Center(child: Text('No lines match entered filter.'))),
      ]);
    }

    return StreamBuilder<SearchedItems>(
      stream: context
          .read<LastSearchedBloc>()
          .notLoadedLastSearchedItemsDataStream(
            loadedVehicleSourcesStream:
                context.read<MapBloc>().mapVehicleSourcesStream,
            limit: 10,
          )
          .map((searched) => searched.filterByType<LineItem>()),
      builder: (context, snapshot) => CustomScrollView(
        controller: _autoScrollController,
        slivers: [
          SliverPersistentHeader(
            delegate: snapshot.data == null ||
                    snapshot.data.mostRecentItems.isEmpty ||
                    MediaQuery.of(context).orientation != Orientation.portrait
                ? SliverTextFieldAppBarDelegate(context, appBar: appBar)
                : SliverTextFieldAppBarWithSearchedItemsListDelegate(
                    context,
                    appBar: appBar,
                    lastSearchedItemsList: LastSearchedItemsList(
                      itemsSnapshot: snapshot,
                      lineItemPressed: context.read<LinesBloc>().track,
                      morePressed: () => _showLastSearchedPage(context),
                    ),
                  ),
            floating: true,
          ),
          _linesList(context, lines: filteredLines),
        ],
      ),
    );
  }

  void _showLastSearchedPage(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<MapBloc>()),
            BlocProvider.value(value: context.read<LinesBloc>()),
            BlocProvider.value(value: context.read<LocationsBloc>()),
            BlocProvider.value(value: context.read<LastSearchedBloc>()),
          ],
          child: LastSearchedPage(filterMode: LastSearchedPageFilterMode.LINES),
        ),
      ),
    );
  }

  Widget _appBar({
    @required LinesState state,
    @required FocusNode searchFieldFocusNode,
    @required TextEditingController searchFieldController,
  }) {
    return TextFieldAppBar(
      textFieldFocusNode: searchFieldFocusNode,
      textFieldController: searchFieldController,
      hint: "Search lines...",
      leading: TextFieldAppBarBackButton(searchFieldFocusNode),
      trailing: Container(
        child: Row(
          children: [
            CircularButton(
              child: Builder(
                builder: (context) => Icon(
                  Icons.close,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              onPressed: () {
                searchFieldController.value = TextEditingValue();
              },
            ),
            _listFiltersMenu(state.listFilters),
          ],
        ),
      ),
    );
  }

  Widget _listFiltersMenu(List<LineListFilter> listFilters) {
    if (listFilters == null || listFilters.isEmpty) {
      return Container(width: 0.0, height: 0.0);
    }
    return Builder(
      builder: (context) => PopupMenuButton<LineListFilter>(
        icon: const Icon(Icons.filter_list),
        onSelected: context.read<LinesBloc>().listFilterChanged,
        itemBuilder: (context) => listFilters.map(
          (filter) {
            final filterString = filter.toString();
            final filterName = filterString
                .substring(filterString.indexOf('.') + 1)
                .toLowerCase();
            return PopupMenuItem<LineListFilter>(
              value: filter,
              child: Text(
                '${filterName[0].toUpperCase()}${filterName.substring(1)}',
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _floatingActionButtons(
    BuildContext context, {
    @required LinesState state,
  }) {
    if (state == null) return null;

    final selectedLines = state.lines.entries.where(
      (entry) => entry.value.selected,
    );
    if (selectedLines.isEmpty) return null;

    int numberOfTracked = 0,
        numberOfUntracked = 0,
        numberOfFav = 0,
        numberOfNonFav = 0;
    selectedLines.forEach((entry) {
      if (entry.value.tracked)
        ++numberOfTracked;
      else
        ++numberOfUntracked;
      if (entry.key.isFavourite)
        ++numberOfFav;
      else
        ++numberOfNonFav;
    });

    final bloc = context.read<LinesBloc>();
    final buttons = [
      if (numberOfUntracked > 0)
        _LinesFloatingActionButton(
          numberOfLines: numberOfUntracked,
          icon: Icons.location_on,
          label: 'Track',
          onTap: () => bloc.trackSelectedLines(),
        ),
      if (numberOfTracked > 0)
        _LinesFloatingActionButton(
          numberOfLines: numberOfTracked,
          icon: Icons.location_off,
          label: 'Untrack',
          onTap: () => bloc.untrackSelectedLines(),
        ),
      if (numberOfNonFav > 0)
        _LinesFloatingActionButton(
          numberOfLines: numberOfNonFav,
          icon: Icons.save,
          label: 'Save',
          onTap: () => bloc.toggleSelectedLinesFavourite(false),
        ),
      if (numberOfFav > 0)
        _LinesFloatingActionButton(
          numberOfLines: numberOfFav,
          icon: Icons.delete_forever,
          label: 'Delete',
          onTap: () => bloc.toggleSelectedLinesFavourite(true),
        ),
      CircularTextIconButton(
        icon: Icons.cancel,
        text: 'Cancel',
        onTap: () => bloc.resetSelection(),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        height: kBottomNavigationBarHeight,
        child: Align(
          alignment: Alignment.centerRight,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: buttons.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                child: ScaleAnimation(
                  child: FadeInAnimation(child: buttons.elementAt(index)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _listGroupNavigationButtons(
    BuildContext context, {
    @required LinesState state,
  }) {
    if (state == null) return Container();

    final lineGroups =
        state.filteredLines.groupBy((entry) => entry.key.group).entries;
    if (lineGroups.length < 2) return Container();

    final navButtonTextGroup = AutoSizeGroup();

    return ScrollBottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      controller: _autoScrollController,
      items: List.generate(
        lineGroups.length,
        (index) => BottomNavigationBarItem(
          icon: AutoSizeText(
            lineGroups.elementAt(index).key,
            group: navButtonTextGroup,
            style: Theme.of(context)
                .textTheme
                .button
                .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          title: Container(),
        ),
      ),
    );
  }

  Widget _linesList(
    BuildContext context, {
    @required List<MapEntry<Line, LineState>> lines,
  }) {
    final lineGroups = lines.groupBy((entry) => entry.key.group).entries;
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index < 0 || index >= lineGroups.length) return null;
          return AutoScrollTag(
            key: ValueKey(index),
            controller: _autoScrollController,
            index: index,
            child: _linesGroup(context, group: lineGroups.elementAt(index)),
          );
        },
      ),
    );
  }

  Widget _linesGroup(
    BuildContext context, {
    @required MapEntry<String, List<MapEntry<Line, LineState>>> group,
  }) {
    final groupLines = group.value;
    final columnsCount =
        MediaQuery.of(context).orientation == Orientation.portrait ? 4 : 8;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(10, 25, 10, 10),
          child: Text(
            group.key,
            textAlign: TextAlign.left,
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          child: AnimationLimiter(
            child: GridView.builder(
              padding: const EdgeInsets.only(top: 15),
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columnsCount,
              ),
              shrinkWrap: true,
              itemCount: groupLines.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  columnCount: columnsCount,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: _lineListItem(context, line: groupLines[index]),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _lineListItem(
    BuildContext context, {
    @required MapEntry<Line, LineState> line,
  }) {
    return Card(
      child: InkWell(
        onLongPress: () => context.read<LinesBloc>().toggleSelected(line.key),
        onTap: () async => _handleLineActionsDialogResult(
          context,
          result: await showDialog<_LineActionsDialogResult>(
            context: context,
            builder: (context) => _LineActionsDialog(
              line: line.key,
              state: line.value,
            ),
          ),
          line: line,
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  line.key.symbol,
                  style: line.value.selected
                      ? TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        )
                      : const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                ),
              ),
              if (line.value.tracked || line.key.isFavourite)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (line.value.tracked) const Icon(Icons.location_on),
                      if (line.key.isFavourite) const Icon(Icons.favorite),
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
      elevation: line.value.selected ? 0.0 : 5.0,
    );
  }

  void _handleLineActionsDialogResult(
    BuildContext context, {
    @required _LineActionsDialogResult result,
    @required MapEntry<Line, LineState> line,
  }) async {
    if (result == null) return;
    final bloc = context.read<LinesBloc>();
    switch (result) {
      case _LineActionsDialogResult.TOGGLE_SELECTED:
        bloc.toggleSelected(line.key);
        break;
      case _LineActionsDialogResult.TOGGLE_FAVOURITE:
        bloc.toggleFavourite(line.key);
        break;
      case _LineActionsDialogResult.TOGGLE_TRACKED:
        bloc.toggleTracked(line);
        break;
    }
  }
}

class _LinesFloatingActionButton extends StatelessWidget {
  final int numberOfLines;
  final IconData icon;
  final String label;
  final void Function() onTap;

  const _LinesFloatingActionButton({
    Key key,
    @required this.numberOfLines,
    @required this.icon,
    @required this.label,
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Badge(
        padding: const EdgeInsets.all(8.0),
        badgeContent: Text(
          numberOfLines.toString(),
          style: const TextStyle(color: Colors.white),
        ),
        child: CircularTextIconButton(icon: icon, text: label, onTap: onTap),
      ),
    );
  }
}

class _LineActionsDialog extends HookWidget {
  final Line line;
  final LineState state;

  const _LineActionsDialog({
    Key key,
    @required this.line,
    @required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonsTextAutoSizeGroup = useMemoized(() => AutoSizeGroup());
    final lineDestTextAutoSizeGroup = useMemoized(() => AutoSizeGroup());

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(children: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  line.symbol,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _destText(line.dest1, group: lineDestTextAutoSizeGroup),
                    const Divider(color: Colors.grey),
                    _destText(line.dest2, group: lineDestTextAutoSizeGroup),
                  ],
                ),
              )
            ]),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _popWithResultButton(
                    state.selected ? 'Deselect' : 'Select',
                    result: _LineActionsDialogResult.TOGGLE_SELECTED,
                    group: buttonsTextAutoSizeGroup,
                  ),
                  _popWithResultButton(
                    line.isFavourite ? 'Unfavourite' : 'Favourite',
                    result: _LineActionsDialogResult.TOGGLE_FAVOURITE,
                    group: buttonsTextAutoSizeGroup,
                  ),
                  _popWithResultButton(
                    state.tracked ? 'Untrack' : 'Track',
                    result: _LineActionsDialogResult.TOGGLE_TRACKED,
                    group: buttonsTextAutoSizeGroup,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _popWithResultButton(
    String text, {
    @required _LineActionsDialogResult result,
    @required AutoSizeGroup group,
  }) {
    return Builder(
      builder: (context) => Expanded(
        child: TextButton(
          child: AutoSizeText(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
            group: group,
          ),
          onPressed: () => Navigator.pop(context, result),
        ),
      ),
    );
  }

  Widget _destText(String text, {@required AutoSizeGroup group}) {
    return AutoSizeText(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 14),
      group: group,
    );
  }
}

enum _LineActionsDialogResult {
  TOGGLE_SELECTED,
  TOGGLE_FAVOURITE,
  TOGGLE_TRACKED,
}

extension _LinesStateExt on LinesState {
  List<LineListFilter> get listFilters {
    final availableFilters = List.of(LineListFilter.values)..remove(listFilter);
    if (selectedLines.isEmpty) {
      availableFilters.remove(LineListFilter.selected);
    }
    if (trackedLines.isEmpty) {
      availableFilters.remove(LineListFilter.tracked);
    }
    if (favouriteLines.isEmpty) {
      availableFilters.remove(LineListFilter.favourite);
    }
    return availableFilters;
  }
}

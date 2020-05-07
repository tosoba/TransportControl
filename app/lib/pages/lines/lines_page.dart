import 'dart:async';
import 'dart:math';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:scroll_bottom_navigation_bar/scroll_bottom_navigation_bar.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/pages/lines/lines_bloc.dart';
import 'package:transport_control/pages/lines/lines_state.dart';
import 'package:transport_control/widgets/circular_icon_button.dart';
import 'package:transport_control/widgets/circular_text_icon_button.dart';
import 'package:transport_control/widgets/text_field_app_bar.dart';
import 'package:transport_control/util/collection_util.dart';
import 'package:transport_control/util/model_util.dart';
import 'package:transport_control/widgets/text_field_app_bar_back_button.dart';

class LinesPage extends HookWidget {
  LinesPage({Key key}) : super(key: key);

  final AutoScrollController _autoScrollController = AutoScrollController();

  @override
  Widget build(BuildContext context) {
    final searchFieldFocusNode = useFocusNode();
    final searchFieldController = useTextEditingController();
    searchFieldController.addListener(
      () => context
          .bloc<LinesBloc>()
          .symbolFilterChanged(searchFieldController.text),
    );
    final filter = context.bloc<LinesBloc>().state.symbolFilter;
    if (filter != null) {
      searchFieldController.value = TextEditingValue(text: filter);
    }

    final appBar = _appBar(
      context,
      searchFieldFocusNode: searchFieldFocusNode,
      searchFieldController: searchFieldController,
    );

    _autoScrollController.bottomNavigationBar.tabListener((index) {
      _autoScrollController.scrollToIndex(
        index,
        preferPosition: AutoScrollPosition.begin,
      );
    });

    final bloc = context.bloc<LinesBloc>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      resizeToAvoidBottomPadding: false,
      body: StreamBuilder<LinesState>(
        stream: bloc,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Column(children: [
              appBar,
              Expanded(child: Center(child: CircularProgressIndicator())),
            ]);
          }

          final selectedLines = snapshot.data.lines.entries
              .where((entry) => entry.value.selected)
              .toList();
          final symbolFilterPred = snapshot.data.symbolFilterPredicate;
          final listFilterPred = snapshot.data.listFilterPredicate;
          final filteredLines = snapshot.data.lines.entries
              .where(
                (entry) => symbolFilterPred(entry) && listFilterPred(entry),
              )
              .toList();

          if (filteredLines.isEmpty) {
            return Column(children: [
              appBar,
              if (selectedLines.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: _badgeRow(context, selectedLines: selectedLines),
                ),
              Expanded(
                child: Center(
                  child: Text('No lines match entered filter.'),
                ),
              ),
            ]);
          }

          return CustomScrollView(
            controller: _autoScrollController,
            slivers: [
              SliverPersistentHeader(
                delegate: SliverTextFieldAppBarDelegate(
                  context,
                  appBar: appBar,
                ),
                floating: true,
              ),
              if (selectedLines.isNotEmpty)
                _badgeBar(context, selectedLines: selectedLines),
              _linesList(
                selectionChanged: bloc.lineSelectionChanged,
                columnsCount:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? 4
                        : 8,
                lines: filteredLines,
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _listGroupNavigationButtons(
        bloc.filteredLinesStream,
      ),
    );
  }

  Widget _appBar(
    BuildContext context, {
    @required FocusNode searchFieldFocusNode,
    @required TextEditingController searchFieldController,
  }) {
    return TextFieldAppBar(
      textFieldFocusNode: searchFieldFocusNode,
      textFieldController: searchFieldController,
      hint: "Search lines...",
      leading: TextFieldAppBarBackButton(searchFieldFocusNode),
      trailing: StreamBuilder<String>(
        stream: context.bloc<LinesBloc>().symbolFiltersStream,
        builder: (context, snapshot) => Container(
          child: Row(
            children: [
              if (snapshot.data?.isNotEmpty == true)
                CircularButton(
                  child: const Icon(
                    Icons.close,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    searchFieldController.value = TextEditingValue();
                  },
                ),
              _listFiltersMenu(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listFiltersMenu(BuildContext context) {
    return StreamBuilder<List<LineListFilter>>(
      stream: context.bloc<LinesBloc>().listFiltersStream,
      builder: (context, snapshot) {
        if (snapshot.data == null || snapshot.data.isEmpty)
          return Container(width: 0.0, height: 0.0);
        return PopupMenuButton<LineListFilter>(
          icon: const Icon(Icons.filter_list),
          onSelected: context.bloc<LinesBloc>().listFilterChanged,
          itemBuilder: (context) => snapshot.data.map(
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
        );
      },
    );
  }

  Widget _badgeRow(
    BuildContext context, {
    @required Iterable<MapEntry<Line, LineState>> selectedLines,
  }) {
    int numberOfTracked = 0,
        numberOfUntracked = 0,
        numberOfFav = 0,
        numberOfNonFav = 0;
    selectedLines.forEach((entry) {
      if (entry.value.tracked)
        ++numberOfTracked;
      else
        ++numberOfUntracked;
      if (entry.value.favourite)
        ++numberOfFav;
      else
        ++numberOfNonFav;
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (numberOfUntracked > 0)
          Badge(
            badgeContent: Text(numberOfUntracked.toString()),
            child: CircularTextIconButton(
              icon: Icons.location_on,
              text: 'Track',
              onTap: () async {
                if (await context.bloc<LinesBloc>().trackSelectedLines()) {
                  Navigator.pop(context);
                } else {
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text('No connection.')));
                }
              },
            ),
          ),
        if (numberOfTracked > 0)
          Badge(
            badgeContent: Text(numberOfTracked.toString()),
            child: CircularTextIconButton(
              icon: Icons.location_off,
              text: 'Untrack',
              onTap: () {
                context.bloc<LinesBloc>().untrackSelectedLines();
              },
            ),
          ),
        if (numberOfNonFav > 0)
          Badge(
            badgeContent: Text(numberOfNonFav.toString()),
            child: CircularTextIconButton(
              icon: Icons.save,
              text: 'Save',
              onTap: () {
                context.bloc<LinesBloc>().addSelectedLinesToFavourites();
              },
            ),
          ),
        if (numberOfFav > 0)
          Badge(
            badgeContent: Text(numberOfFav.toString()),
            child: CircularTextIconButton(
              icon: Icons.delete_forever,
              text: 'Delete',
              onTap: () {
                context.bloc<LinesBloc>().removeSelectedLinesFromFavourites();
              },
            ),
          ),
      ],
    );
  }

  Widget _badgeBar(
    BuildContext context, {
    @required Iterable<MapEntry<Line, LineState>> selectedLines,
  }) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverBadgeBarDelegate(
        minHeight: 90,
        maxHeight: 90,
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: _badgeRow(context, selectedLines: selectedLines),
        ),
      ),
    );
  }

  Widget _listGroupNavigationButtons(
    Stream<List<MapEntry<Line, LineState>>> linesStream,
  ) {
    return StreamBuilder<List<MapEntry<Line, LineState>>>(
      stream: linesStream,
      builder: (context, snapshot) {
        if (snapshot.data == null || snapshot.data.length < 2)
          return Container();

        final lineGroups =
            snapshot.data.groupBy((entry) => entry.key.group).entries;

        return ScrollBottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          controller: _autoScrollController,
          items: List.generate(
            lineGroups.length,
            (index) => BottomNavigationBarItem(
              icon: Text(
                lineGroups.elementAt(index).key,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              title: Container(),
            ),
          ),
        );
      },
    );
  }

  Widget _linesList({
    @required void Function(Line) selectionChanged,
    @required List<MapEntry<Line, LineState>> lines,
    @required int columnsCount,
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
            child: _linesGroup(
              lineGroups.elementAt(index),
              columnsCount,
              selectionChanged,
            ),
          );
        },
      ),
    );
  }

  Widget _linesGroup(
    MapEntry<String, List<MapEntry<Line, LineState>>> group,
    int columnsCount,
    void Function(Line) selectionChanged,
  ) {
    final groupLines = group.value;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(10, 25, 10, 10),
          child: Text(
            group.key,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
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
                      child: _lineListItem(
                        groupLines[index],
                        index,
                        selectionChanged,
                      ),
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
    MapEntry<Line, LineState> line,
    int index,
    void Function(Line) selectionChanged,
  ) {
    final inkWell = InkWell(
      onTap: () => selectionChanged(line.key),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                line.key.symbol,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (line.value.tracked || line.value.favourite)
              Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (line.value.tracked) Icon(Icons.location_on),
                    if (line.value.favourite) Icon(Icons.favorite),
                  ],
                ),
              )
          ],
        ),
      ),
    );
    return Card(child: inkWell, elevation: line.value.selected ? 0.0 : 5.0);
  }
}

class _SliverBadgeBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverBadgeBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => max(maxHeight, minHeight);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverBadgeBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

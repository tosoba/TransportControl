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

    _autoScrollController.bottomNavigationBar.tabListener((index) {
      _autoScrollController.scrollToIndex(
        index,
        preferPosition: AutoScrollPosition.begin,
      );
    });

    return StreamBuilder<LinesState>(
      stream: context.bloc<LinesBloc>(),
      builder: (context, snapshot) => Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        resizeToAvoidBottomPadding: false,
        body: _scaffoldBody(
          context,
          stateSnapshot: snapshot,
          searchFieldFocusNode: searchFieldFocusNode,
          searchFieldController: searchFieldController,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _floatingActionButtons(
          context,
          stateSnapshot: snapshot,
        ),
        bottomNavigationBar: _listGroupNavigationButtons(
          stateSnapshot: snapshot,
        ),
      ),
    );
  }

  Widget _scaffoldBody(
    BuildContext context, {
    @required AsyncSnapshot<LinesState> stateSnapshot,
    @required FocusNode searchFieldFocusNode,
    @required TextEditingController searchFieldController,
  }) {
    final appBar = _appBar(
      context,
      searchFieldFocusNode: searchFieldFocusNode,
      searchFieldController: searchFieldController,
    );

    if (stateSnapshot.data == null) {
      return Column(children: [
        appBar,
        Expanded(child: Center(child: CircularProgressIndicator())),
      ]);
    }

    final filteredLines = stateSnapshot.data.filteredLines;

    if (filteredLines.isEmpty) {
      return Column(children: [
        appBar,
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
        _linesList(
          selectionChanged: context.bloc<LinesBloc>().lineSelectionChanged,
          columnsCount:
              MediaQuery.of(context).orientation == Orientation.portrait
                  ? 4
                  : 8,
          lines: filteredLines,
        ),
      ],
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
              if (snapshot.data != null && snapshot.data.isNotEmpty)
                CircularButton(
                  child: const Icon(Icons.close, color: Colors.black),
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

  Widget _floatingActionButtons(
    BuildContext context, {
    @required AsyncSnapshot<LinesState> stateSnapshot,
  }) {
    if (stateSnapshot.data == null) return null;

    final selectedLines = stateSnapshot.data.lines.entries.where(
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
      if (entry.value.favourite)
        ++numberOfFav;
      else
        ++numberOfNonFav;
    });
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (numberOfUntracked > 0)
            _LinesFloatingActionButton(
              numberOfLines: numberOfUntracked,
              icon: Icons.location_on,
              label: 'Track',
              onTap: () async {
                if (await context.bloc<LinesBloc>().trackSelectedLines()) {
                  Navigator.pop(context);
                } else {
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text('No connection.'),
                    ),
                  );
                }
              },
            ),
          if (numberOfTracked > 0)
            _LinesFloatingActionButton(
              numberOfLines: numberOfTracked,
              icon: Icons.location_off,
              label: 'Untrack',
              onTap: () => context.bloc<LinesBloc>().untrackSelectedLines(),
            ),
          if (numberOfNonFav > 0)
            _LinesFloatingActionButton(
              numberOfLines: numberOfNonFav,
              icon: Icons.save,
              label: 'Save',
              onTap: () {
                context.bloc<LinesBloc>().addSelectedLinesToFavourites();
              },
            ),
          if (numberOfFav > 0)
            _LinesFloatingActionButton(
              numberOfLines: numberOfFav,
              icon: Icons.delete_forever,
              label: 'Delete',
              onTap: () {
                context.bloc<LinesBloc>().removeSelectedLinesFromFavourites();
              },
            ),
          CircularTextIconButton(
            icon: Icons.cancel,
            text: 'Cancel',
            onTap: () => context.bloc<LinesBloc>().resetSelection(),
          ),
        ],
      ),
    );
  }

  Widget _listGroupNavigationButtons({
    @required AsyncSnapshot<LinesState> stateSnapshot,
  }) {
    if (stateSnapshot.data == null) return Container();

    final lineGroups = stateSnapshot.data.filteredLines
        .groupBy((entry) => entry.key.group)
        .entries;
    if (lineGroups.length < 2) return Container();

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
        badgeContent: Text(numberOfLines.toString()),
        child: CircularTextIconButton(icon: icon, text: label, onTap: onTap),
      ),
    );
  }
}

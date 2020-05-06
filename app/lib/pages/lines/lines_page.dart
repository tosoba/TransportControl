import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/pages/lines/lines_bloc.dart';
import 'package:transport_control/pages/lines/lines_state.dart';
import 'package:transport_control/util/string_util.dart';
import 'package:transport_control/widgets/circular_icon_button.dart';
import 'package:transport_control/widgets/shake_transition.dart';
import 'package:transport_control/widgets/simple_connectivity_status_bar.dart';
import 'package:transport_control/widgets/text_field_app_bar.dart';
import 'package:transport_control/util/collection_util.dart';
import 'package:transport_control/util/model_util.dart';
import 'package:transport_control/widgets/text_field_app_bar_back_button.dart';

class LinesPage extends HookWidget {
  LinesPage({Key key}) : super(key: key);

  final ItemScrollController _linesListScrollController =
      ItemScrollController();

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

    final appBar = TextFieldAppBar(
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
    final topOffset =
        appBar.size.height + MediaQuery.of(context).padding.top + 10;
    final statusBarTitleShakeTransition = ShakeTransition(
      child: const Text(
        'Please check your internet connection',
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      resizeToAvoidBottomPadding: false,
      appBar: appBar,
      body: Stack(
        children: [
          _linesList(
            topOffset: topOffset,
            linesStream: context.bloc<LinesBloc>().filteredLinesStream,
            selectionChanged: context.bloc<LinesBloc>().lineSelectionChanged,
          ),
          SimpleConnectionStatusBar(
            title: statusBarTitleShakeTransition,
          ),
        ],
      ),
      bottomNavigationBar: _listGroupNavigationButtons(
        context.bloc<LinesBloc>().filteredLinesStream,
        topOffset,
      ),
      bottomSheet: _bottomSheet(
        context,
        onNotConnected: () => statusBarTitleShakeTransition.shake(),
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

  Widget _bottomSheet(
    BuildContext context, {
    @required void Function() onNotConnected,
  }) {
    return StreamBuilder<Iterable<MapEntry<Line, LineState>>>(
      stream: context.bloc<LinesBloc>().selectedLinesStream,
      builder: (context, snapshot) {
        final selectedLines = snapshot.data;
        if (selectedLines == null || selectedLines.isEmpty) {
          return Container(width: 0, height: 0);
        }

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
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 5.0,
                color: Colors.grey.shade300,
                offset: Offset(0.0, -5.0),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selectedLines.length > 1
                    ? 'Out ${selectedLines.length} selected lines:'
                    : 'Out of ${selectedLines.length} selected line:',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black, fontSize: 20),
              ),
              if (numberOfUntracked > 0)
                _selectedLinesGroupBottomSheetRow(
                  actionLabel: Strings.trackAll,
                  singularDescription:
                      '$numberOfUntracked line is not tracked.',
                  pluralDescription:
                      '$numberOfUntracked lines are not tracked.',
                  actionPressed: () async {
                    if (await context.bloc<LinesBloc>().trackSelectedLines()) {
                      Navigator.pop(context);
                    } else {
                      onNotConnected();
                    }
                  },
                  numberOfLines: numberOfUntracked,
                ),
              if (numberOfTracked > 0)
                _selectedLinesGroupBottomSheetRow(
                  actionLabel: Strings.untrackAll,
                  singularDescription: '$numberOfTracked line is tracked.',
                  pluralDescription: '$numberOfTracked lines are tracked.',
                  actionPressed: () {
                    context.bloc<LinesBloc>().untrackSelectedLines();
                  },
                  numberOfLines: numberOfTracked,
                ),
              if (numberOfNonFav > 0)
                _selectedLinesGroupBottomSheetRow(
                  actionLabel: Strings.saveAll,
                  singularDescription:
                      '$numberOfNonFav line is not saved as favourite.',
                  pluralDescription:
                      '$numberOfNonFav lines are not saved as favourite.',
                  actionPressed: () {
                    context.bloc<LinesBloc>().addSelectedLinesToFavourites();
                  },
                  numberOfLines: numberOfNonFav,
                ),
              if (numberOfFav > 0)
                _selectedLinesGroupBottomSheetRow(
                  actionLabel: Strings.removeAll,
                  singularDescription:
                      '$numberOfFav line is saved as favourite.',
                  pluralDescription:
                      '$numberOfFav lines are saved as favourite.',
                  actionPressed: () {
                    context
                        .bloc<LinesBloc>()
                        .removeSelectedLinesFromFavourites();
                  },
                  numberOfLines: numberOfFav,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _selectedLinesGroupBottomSheetRow({
    @required int numberOfLines,
    @required String singularDescription,
    @required String pluralDescription,
    @required FutureOr<void> Function() actionPressed,
    @required String actionLabel,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              child: Text(
                numberOfLines > 1 ? pluralDescription : singularDescription,
                textAlign: TextAlign.left,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ),
          RaisedButton(
            color: Colors.white,
            padding: EdgeInsets.zero,
            onPressed: () => actionPressed(),
            child: Text(
              actionLabel,
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
          )
        ],
      ),
    );
  }

  Widget _listGroupNavigationButtons(
    Stream<List<MapEntry<Line, LineState>>> linesStream,
    double topOffset,
  ) {
    return StreamBuilder<List<MapEntry<Line, LineState>>>(
      stream: linesStream,
      builder: (context, snapshot) {
        if (snapshot.data == null) return Container();

        final lineGroups =
            snapshot.data.groupBy((entry) => entry.key.group).entries;

        final listView = ListView.builder(
          itemCount: lineGroups.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              color: Colors.white,
              onPressed: () => _linesListScrollController.jumpTo(
                index: index,
                alignment: topOffset / MediaQuery.of(context).size.height,
              ),
              child: Text(
                lineGroups.elementAt(index).key,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        );

        if (snapshot.data.any((entry) => entry.value.selected)) {
          return Container(
            height: kBottomNavigationBarHeight,
            color: Colors.white,
            child: listView,
          );
        } else {
          const shadowSize = 5.0;
          return Container(
            height: kBottomNavigationBarHeight + shadowSize,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: shadowSize,
                  color: Colors.transparent,
                ),
                Container(
                  height: kBottomNavigationBarHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      const BoxShadow(
                        blurRadius: shadowSize,
                        color: Colors.grey,
                      )
                    ],
                  ),
                  child: listView,
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _linesList({
    @required double topOffset,
    @required Stream<List<MapEntry<Line, LineState>>> linesStream,
    @required void Function(Line) selectionChanged,
  }) {
    return StreamBuilder<List<MapEntry<Line, LineState>>>(
      stream: linesStream,
      builder: (context, snapshot) {
        if (snapshot.data == null) return Container();

        final columnsCount =
            MediaQuery.of(context).orientation == Orientation.portrait ? 4 : 8;
        final lineGroups =
            snapshot.data.groupBy((entry) => entry.key.group).entries;
        return AnimationLimiter(
          child: ScrollablePositionedList.builder(
            padding: EdgeInsets.only(top: topOffset),
            itemScrollController: _linesListScrollController,
            itemCount: lineGroups.length,
            itemBuilder: (context, index) {
              if (index < 0 || index >= lineGroups.length) {
                return null;
              }
              return _linesGroup(
                lineGroups.elementAt(index),
                columnsCount,
                selectionChanged,
              );
            },
          ),
        );
      },
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
          child: GridView.count(
            padding: EdgeInsets.only(top: 15),
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: columnsCount,
            shrinkWrap: true,
            children: List.generate(
              groupLines.length,
              (index) => AnimationConfiguration.staggeredGrid(
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
              ),
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

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
import 'package:transport_control/widgets/text_field_app_bar.dart';
import 'package:transport_control/util/collection_util.dart';
import 'package:transport_control/util/model_util.dart';
import 'package:transport_control/widgets/text_field_app_bar_back_button.dart';
import 'package:transport_control/widgets/slide_transition_preferred_size_widget.dart';

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

    final scrollAnimController = useAnimationController(
      duration: kThemeAnimationDuration,
    );
    final bottomNavSize = useMemoized(
      () => Tween(begin: 1.0, end: 0.0).animate(scrollAnimController),
    );
    final appBarOffset = useMemoized(
      () => Tween(begin: Offset.zero, end: Offset(0.0, -1.0))
          .animate(scrollAnimController),
    );

    final appBar = TextFieldAppBar(
      textFieldFocusNode: searchFieldFocusNode,
      textFieldController: searchFieldController,
      hint: "Search lines...",
      leading: TextFieldAppBarBackButton(searchFieldFocusNode),
      trailing: _listFiltersMenu(context),
    );
    final topOffset =
        appBar.size.height + MediaQuery.of(context).padding.top + 10;
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      resizeToAvoidBottomPadding: false,
      appBar: SlideTransitionPreferredSizeWidget(
        offset: appBarOffset,
        child: appBar,
      ),
      body: _linesList(
        topOffset: topOffset,
        linesStream: context.bloc<LinesBloc>().filteredLinesStream,
        selectionChanged: context.bloc<LinesBloc>().lineSelectionChanged,
        scrollAnimationController: scrollAnimController,
      ),
      bottomNavigationBar: SizeTransition(
        axisAlignment: -1.0,
        sizeFactor: bottomNavSize,
        child: _listGroupNavigationButtons(
          context.bloc<LinesBloc>().filteredLinesStream,
          topOffset,
        ),
      ),
      bottomSheet: _bottomSheet(context),
    );
  }

  Widget _listFiltersMenu(BuildContext context) {
    return StreamBuilder<List<LineListFilter>>(
      stream: context.bloc<LinesBloc>().listFiltersStream,
      builder: (context, snapshot) {
        if (snapshot.data == null || snapshot.data.isEmpty)
          return Container(width: 0.0, height: 0.0);
        return PopupMenuButton<LineListFilter>(
          icon: Icon(Icons.filter_list),
          onSelected: context.bloc<LinesBloc>().listFilterChanged,
          itemBuilder: (context) {
            return snapshot.data.map(
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
            ).toList();
          },
        );
      },
    );
  }

  Widget _bottomSheet(BuildContext context) {
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
                  actionPressed: () {
                    context.bloc<LinesBloc>()
                      ..trackSelectedLines()
                      ..resetSelection();
                    Navigator.pop(context);
                  },
                  numberOfLines: numberOfUntracked,
                ),
              if (numberOfTracked > 0)
                _selectedLinesGroupBottomSheetRow(
                  actionLabel: Strings.untrackAll,
                  singularDescription: '$numberOfTracked line is tracked.',
                  pluralDescription: '$numberOfTracked lines are tracked.',
                  actionPressed: () {
                    context.bloc<LinesBloc>()
                      ..untrackSelectedLines()
                      ..resetSelection();
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
                    context.bloc<LinesBloc>()
                      ..addSelectedLinesToFavourites()
                      ..resetSelection();
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
                    context.bloc<LinesBloc>()
                      ..removeSelectedLinesFromFavourites()
                      ..resetSelection();
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
    @required void Function() actionPressed,
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
            onPressed: actionPressed,
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
    @required AnimationController scrollAnimationController,
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
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) => _handleScrollNotification(
              notification,
              context: context,
              scrollAnimationController: scrollAnimationController,
            ),
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
          ),
        );
      },
    );
  }

  bool _handleScrollNotification(
    ScrollNotification notification, {
    @required BuildContext context,
    @required AnimationController scrollAnimationController,
  }) {
    if (notification.depth == 0 && notification is UserScrollNotification) {
      switch (notification.direction) {
        case ScrollDirection.forward:
          scrollAnimationController.reverse();
          break;
        case ScrollDirection.reverse:
          scrollAnimationController.forward();
          break;
        default:
          break;
      }
    } else if (notification is ScrollStartNotification) {
      FocusScope.of(context).unfocus();
    }
    return false;
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

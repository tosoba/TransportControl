import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/pages/lines/lines_bloc.dart';
import 'package:transport_control/pages/lines/lines_state.dart';
import 'package:transport_control/widgets/circular_icon_button.dart';
import 'package:transport_control/widgets/search_app_bar.dart';
import 'package:transport_control/util/collection_util.dart';
import 'package:transport_control/util/model_util.dart';
import 'package:transport_control/widgets/slide_transition_preferred_size_widget.dart';

class LinesPage extends StatefulWidget {
  const LinesPage({Key key}) : super(key: key);

  @override
  _LinesPageState createState() => _LinesPageState();
}

class _LinesPageState extends State<LinesPage>
    with TickerProviderStateMixin<LinesPage> {
  final ItemScrollController _linesListScrollController =
      ItemScrollController();

  AnimationController _scrollAnimController;
  Animation<double> _bottomNavSize;
  Animation<Offset> _appBarOffset;

  FocusNode _searchFieldFocusNode;
  TextEditingController _searchFieldController;

  @override
  void initState() {
    super.initState();

    _searchFieldController = TextEditingController()
      ..addListener(_searchTextChanged);
    _searchFieldFocusNode = FocusNode();

    _scrollAnimController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
    );
    _bottomNavSize = Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(_scrollAnimController);
    _appBarOffset = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0.0, -1.0),
    ).animate(_scrollAnimController);
  }

  @override
  void dispose() {
    _searchFieldFocusNode.dispose();
    _searchFieldController.dispose();

    _scrollAnimController.dispose();

    super.dispose();
  }

  void _searchTextChanged() {
    context
        .bloc<LinesBloc>()
        .symbolFilterChanged(_searchFieldController.value.text);
  }

  @override
  Widget build(BuildContext context) {
    final filter = context.bloc<LinesBloc>().state.symbolFilter;
    if (filter != null) {
      _searchFieldController.value = TextEditingValue(text: filter);
    }

    final appBar = SearchAppBar(
      searchFieldFocusNode: _searchFieldFocusNode,
      searchFieldController: _searchFieldController,
      hint: "Search lines...",
      leading: _backButton,
      trailing: _listFiltersMenu(context),
    );
    final topOffset =
        appBar.size.height + MediaQuery.of(context).padding.top + 10;
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: SlideTransitionPreferredSizeWidget(
        offset: _appBarOffset,
        child: appBar,
      ),
      body: _linesList(
        topOffset: topOffset,
        itemsStream: context.bloc<LinesBloc>().filteredItemsStream,
        selectionChanged: context.bloc<LinesBloc>().itemSelectionChanged,
      ),
      bottomNavigationBar: SizeTransition(
        axisAlignment: -1.0,
        sizeFactor: _bottomNavSize,
        child: _listGroupNavigationButtons(
          context.bloc<LinesBloc>().filteredItemsStream,
          topOffset,
        ),
      ),
      bottomSheet: _bottomSheet(context),
    );
  }

  Widget _listFiltersMenu(BuildContext context) {
    return StreamBuilder(
      stream: context.bloc<LinesBloc>().listFiltersStream,
      builder: (context, AsyncSnapshot<List<LineListFilter>> snapshot) {
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
    return StreamBuilder(
      stream: context.bloc<LinesBloc>().selectedLinesStream,
      builder: (
        BuildContext context,
        AsyncSnapshot<Iterable<MapEntry<Line, LineState>>> snapshot,
      ) {
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
                  actionLabel: 'Track all',
                  singularDescription:
                      '$numberOfUntracked line is not tracked.',
                  pluralDescription:
                      '$numberOfUntracked lines are not tracked.',
                  actionPressed: () {
                    context.bloc<LinesBloc>()
                      ..trackSelectedLines()
                      ..selectionReset();
                    Navigator.pop(context);
                  },
                  numberOfLines: numberOfUntracked,
                ),
              if (numberOfTracked > 0)
                _selectedLinesGroupBottomSheetRow(
                  actionLabel: 'Track all',
                  singularDescription: '$numberOfTracked line is tracked.',
                  pluralDescription: '$numberOfTracked lines are tracked.',
                  actionPressed: () {
                    context.bloc<LinesBloc>()
                      ..untrackSelectedLines()
                      ..selectionReset();
                  },
                  numberOfLines: numberOfTracked,
                ),
              if (numberOfNonFav > 0)
                _selectedLinesGroupBottomSheetRow(
                  actionLabel: 'Save all',
                  singularDescription:
                      '$numberOfNonFav line is not saved as favourite.',
                  pluralDescription:
                      '$numberOfNonFav lines are not saved as favourite.',
                  actionPressed: () {},
                  numberOfLines: numberOfNonFav,
                ),
              if (numberOfFav > 0)
                _selectedLinesGroupBottomSheetRow(
                  actionLabel: 'Remove all',
                  singularDescription:
                      '$numberOfFav line is saved as favourite.',
                  pluralDescription:
                      '$numberOfFav lines are saved as favourite.',
                  actionPressed: () {},
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
    Stream<List<MapEntry<Line, LineState>>> itemsStream,
    double topOffset,
  ) {
    return StreamBuilder(
      stream: itemsStream,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<MapEntry<Line, LineState>>> snapshot,
      ) {
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

  Widget get _backButton {
    return CircularButton(
      child: const Icon(
        Icons.arrow_back,
        color: Colors.black,
      ),
      onPressed: () {
        if (_searchFieldFocusNode.hasFocus) {
          _searchFieldFocusNode.unfocus();
        } else {
          Navigator.pop(context);
        }
      },
    );
  }

  Widget _linesList({
    @required double topOffset,
    @required Stream<List<MapEntry<Line, LineState>>> itemsStream,
    @required void Function(Line) selectionChanged,
  }) {
    return StreamBuilder(
      stream: itemsStream,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<MapEntry<Line, LineState>>> snapshot,
      ) {
        if (snapshot.data == null) return Container();

        final columnsCount =
            MediaQuery.of(context).orientation == Orientation.portrait ? 4 : 8;
        final lineGroups =
            snapshot.data.groupBy((entry) => entry.key.group).entries;
        return AnimationLimiter(
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
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

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0 && notification is UserScrollNotification) {
      switch (notification.direction) {
        case ScrollDirection.forward:
          _scrollAnimController.reverse();
          break;
        case ScrollDirection.reverse:
          _scrollAnimController.forward();
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
    void Function(Line) lineSelectionChanged,
  ) {
    final groupItems = group.value;
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
              groupItems.length,
              (index) => AnimationConfiguration.staggeredGrid(
                position: index,
                duration: const Duration(milliseconds: 250),
                columnCount: columnsCount,
                child: ScaleAnimation(
                  child: FadeInAnimation(
                    child: _lineListItem(
                      groupItems[index],
                      index,
                      lineSelectionChanged,
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
    MapEntry<Line, LineState> item,
    int index,
    void Function(Line) itemSelectionChanged,
  ) {
    final inkWell = InkWell(
      onTap: () => itemSelectionChanged(item.key),
      child: Center(
        child: Text(
          item.key.symbol,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
    );

    if (item.value.tracked) {
      return Container(child: inkWell, color: Colors.lightBlue);
    } else if (item.value.selected) {
      return Container(child: inkWell);
    } else {
      return Card(child: inkWell);
    }
  }
}

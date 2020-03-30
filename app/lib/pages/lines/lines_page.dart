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
import 'package:transport_control/util/iterable_ext.dart';
import 'package:transport_control/util/model_ext.dart';

class LinesPage extends StatefulWidget {
  const LinesPage({Key key}) : super(key: key);

  @override
  _LinesPageState createState() => _LinesPageState();
}

class _LinesPageState extends State<LinesPage>
    with TickerProviderStateMixin<LinesPage> {
  final ItemScrollController _linesListScrollController =
      ItemScrollController();
  TextEditingController _searchFieldController;

  AnimationController _bottomNavAnimController;
  Animation<double> _bottomNavSize;

  @override
  void initState() {
    super.initState();

    _searchFieldController = TextEditingController()
      ..addListener(_searchTextChanged);

    _bottomNavAnimController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
    );
    _bottomNavSize = Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(_bottomNavAnimController);
  }

  @override
  void dispose() {
    _searchFieldController.dispose();

    _bottomNavAnimController.dispose();

    super.dispose();
  }

  void _searchTextChanged() {
    context.bloc<LinesBloc>().filterChanged(_searchFieldController.value.text);
  }

  @override
  Widget build(BuildContext context) {
    final filter = context.bloc<LinesBloc>().state.symbolFilter;
    if (filter != null) {
      _searchFieldController.value = TextEditingValue(text: filter);
    }

    final appBar = SearchAppBar(
      searchFieldController: _searchFieldController,
      hint: "Search lines...",
      leading: _backButton,
    );
    final topOffset =
        appBar.size.height + MediaQuery.of(context).padding.top + 10;
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: appBar,
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

  Widget _bottomSheet(BuildContext context) {
    return StreamBuilder(
      stream: context.bloc<LinesBloc>().selectedLinesStream,
      builder: (context, AsyncSnapshot<Set<Line>> snapshot) {
        final selectedLines = snapshot.data;
        if (selectedLines == null || selectedLines.isEmpty) {
          return Container(width: 0, height: 0);
        } else {
          return Container(
            height: 50,
            width: double.infinity,
            child: Row(children: [
              Expanded(
                child: Container(
                  color: Theme.of(context).primaryColor,
                  child: Text(
                    '${selectedLines.length} ${selectedLines.length > 1 ? 'lines are' : 'line is'} selected.',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              InkWell(
                onTap: () => Navigator.pop(context, true),
                child: Text('Search'),
              )
            ]),
          );
        }
      },
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
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              const BoxShadow(
                color: Colors.grey,
                blurRadius: 4.0,
                spreadRadius: 1.0,
              )
            ],
            color: Colors.white,
          ),
          height: kBottomNavigationBarHeight,
          child: ListView.builder(
            itemCount: lineGroups.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => MaterialButton(
              onPressed: () => _linesListScrollController.jumpTo(
                index: index,
                alignment: topOffset / MediaQuery.of(context).size.height,
              ),
              child: Text(
                lineGroups.elementAt(index).key,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget get _backButton {
    return CircularButton(
      child: const Icon(
        Icons.arrow_back,
        color: Colors.black,
      ),
      onPressed: () => Navigator.pop(context),
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
          _bottomNavAnimController.reverse();
          break;
        case ScrollDirection.reverse:
          _bottomNavAnimController.forward();
          break;
        default:
          break;
      }
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

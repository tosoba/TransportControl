import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/pages/lines/lines_bloc.dart';
import 'package:transport_control/pages/lines/lines_state.dart';
import 'package:transport_control/widgets/search_app_bar.dart';
import 'package:transport_control/util/iterable_ext.dart';
import 'package:transport_control/util/model_ext.dart';

class LinesPage extends StatefulWidget {
  const LinesPage({Key key}) : super(key: key);

  @override
  _LinesPageState createState() => _LinesPageState();
}

class _LinesPageState extends State<LinesPage> {
  final ItemScrollController _linesListScrollController =
      ItemScrollController();
  TextEditingController _searchFieldController;

  @override
  void initState() {
    super.initState();
    _searchFieldController = TextEditingController()
      ..addListener(_searchTextChanged);
  }

  @override
  void dispose() {
    _searchFieldController.dispose();
    super.dispose();
  }

  _searchTextChanged() {
    context.bloc<LinesBloc>().filterChanged(_searchFieldController.value.text);
  }

  @override
  Widget build(BuildContext context) {
    final filter = context.bloc<LinesBloc>().state.filter;
    if (filter != null) {
      _searchFieldController.value = TextEditingValue(text: filter);
    }

    final appBar = SearchAppBar(
      searchFieldController: _searchFieldController,
      hint: "Search lines...",
      leading: _backButton,
    );
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: Column(
        children: [
          Expanded(
            child: _linesList(
              topOffset:
                  appBar.size.height + MediaQuery.of(context).padding.top,
              itemsStream: context.bloc<LinesBloc>().filteredItemsStream,
              selectionChanged: context.bloc<LinesBloc>().itemSelectionChanged,
            ),
          ),
          _selectedLinesText,
        ],
      ),
    );
  }

  Widget get _backButton {
    return IconButton(
      icon: Icon(
        Icons.arrow_back,
        color: Colors.black,
      ),
      onPressed: () => Navigator.pop(context),
    );
  }

  Widget get _selectedLinesText {
    return BlocBuilder<LinesBloc, LinesState>(
      builder: (context, state) {
        final numberOfSelectedLines = state.numberOfSelectedLines;
        return numberOfSelectedLines > 0
            ? Row(children: [
                Expanded(
                  child: Container(
                    color: Theme.of(context).primaryColor,
                    child: Text(
                      '$numberOfSelectedLines ${numberOfSelectedLines > 1 ? 'lines are' : 'line is'} selected.',
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
              ])
            : Container();
      },
    );
  }

  Widget _linesList({
    @required double topOffset,
    @required Stream<List<MapEntry<Line, LineState>>> itemsStream,
    @required Function(Line) selectionChanged,
  }) {
    return StreamBuilder(
      stream: itemsStream,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<MapEntry<Line, LineState>>> snapshot,
      ) {
        if (snapshot.data == null) return Container();

        final columnsCount =
            MediaQuery.of(context).orientation == Orientation.portrait ? 5 : 9;
        final lineGroups =
            snapshot.data.groupBy((entry) => entry.key.group).entries;
        return AnimationLimiter(
          child: ScrollablePositionedList.builder(
            itemScrollController: _linesListScrollController,
            itemCount: lineGroups.length + 1,
            itemBuilder: (context, index) {
              if (index < 0 || index > lineGroups.length) {
                return null;
              } else if (index == 0) {
                return Container(height: topOffset);
              } else {
                return _linesGroup(
                  lineGroups.elementAt(index - 1),
                  columnsCount,
                  selectionChanged,
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _linesGroup(
    MapEntry<String, List<MapEntry<Line, LineState>>> group,
    int columnsCount,
    Function(Line) lineSelectionChanged,
  ) {
    final groupItems = group.value;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
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
          transform: Matrix4.translationValues(0.0, -50.0, 0.0),
          child: GridView.count(
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
    Function(Line) itemSelectionChanged,
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

    switch (item.value) {
      case LineState.IDLE:
        return Card(child: inkWell);
      case LineState.SELECTED:
        return Container(child: inkWell);
      case LineState.TRACKED:
        return Container(child: inkWell, color: Colors.lightBlue);
      default:
        throw ArgumentError();
    }
  }
}

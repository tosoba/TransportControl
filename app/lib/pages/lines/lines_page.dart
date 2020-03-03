import 'package:animated_stream_list/animated_stream_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:search_app_bar/search_app_bar.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/pages/lines/lines_bloc.dart';

class LinesPage extends StatefulWidget {
  const LinesPage({Key key}) : super(key: key);

  @override
  _LinesPageState createState() => _LinesPageState();
}

class _LinesPageState extends State<LinesPage> {
  ScrollController _scrollViewController;

  @override
  void initState() {
    super.initState();
    _scrollViewController = ScrollController();
  }

  @override
  void dispose() {
    _scrollViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => NestedScrollView(
      controller: _scrollViewController,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [_searchLinesAppBar(context, innerBoxIsScrolled)];
      },
      body: Column(
        children: [
          Expanded(
            child: _linesList(
                itemsStream:
                    BlocProvider.of<LinesBloc>(context).filteredItemsStream,
                selectionChanged:
                    BlocProvider.of<LinesBloc>(context).itemSelectionChanged),
          ),
          _selectedLinesText,
        ],
      ));

  Widget _searchLinesAppBar(BuildContext context, bool innerBoxIsScrolled) =>
      SliverAppBar(
          titleSpacing: 0.0,
          title: SearchAppBar<MapEntry<Line, bool>>(
            iconTheme: IconThemeData(color: Colors.white),
            title: Text('Lines'),
            searcher: BlocProvider.of<LinesBloc>(context),
            filter: (MapEntry<Line, bool> item, String query) => item.key.symbol
                .toLowerCase()
                .contains(query.trim().toLowerCase()),
          ),
          pinned: false,
          floating: true,
          snap: true,
          forceElevated: innerBoxIsScrolled);

  Widget get _selectedLinesText => BlocBuilder<LinesBloc, LinesState>(
        builder: (context, state) {
          final numberOfSelectedLines = state.numberOfSelectedLines;
          return numberOfSelectedLines > 0
              ? Container(
                  width: double.infinity,
                  color: Theme.of(context).primaryColor,
                  child: Text(
                    '$numberOfSelectedLines ${numberOfSelectedLines > 1 ? 'lines are' : 'line is'} selected.',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
              : Container();
        },
      );

  Widget _linesList(
          {Stream<List<MapEntry<Line, bool>>> itemsStream,
          Function(Line, bool) selectionChanged}) =>
      AnimatedStreamList<MapEntry<Line, bool>>(
        streamList: itemsStream,
        itemBuilder: (MapEntry<Line, bool> lineState, int index,
                BuildContext context, Animation<double> animation) =>
            _lineListItem(lineState, index, animation, false, selectionChanged),
        itemRemovedBuilder: (MapEntry<Line, bool> item, int index,
                BuildContext context, Animation<double> animation) =>
            _lineListItem(item, index, animation, true, selectionChanged),
        equals: (ls1, ls2) => ls1.line.symbol == ls2.line.symbol,
      );

  Widget _lineListItem(
      MapEntry<Line, bool> item,
      int index,
      Animation<double> animation,
      bool removed,
      Function(Line, bool) itemSelectionChanged) {
    final card = Card(
      child: ListTile(
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                item.key.symbol,
                style:
                    const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  lineDestText(item.key.dest1),
                  const Divider(color: Colors.grey),
                  lineDestText(item.key.dest2),
                ],
              ),
            )
          ],
        ),
        trailing: Checkbox(
          value: item.value,
          onChanged: removed
              ? null
              : (newValue) {
                  itemSelectionChanged(item.key, newValue);
                },
        ),
      ),
    );
    return index < 20
        ? SizeTransition(
            axis: Axis.vertical,
            sizeFactor: animation,
            child: card,
          )
        : card;
  }

  Widget lineDestText(String text) => Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14),
      );
}

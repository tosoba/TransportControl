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
      body: _linesList(
          BlocProvider.of<LinesBloc>(context)
              .map((state) => state.filteredItems.entries.toList()),
          BlocProvider.of<LinesBloc>(context).itemSelectionChanged));

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

  Widget _linesList(Stream<List<MapEntry<Line, bool>>> lineStatesStream,
          Function(Line, bool) selectionChanged) =>
      AnimatedStreamList<MapEntry<Line, bool>>(
        streamList: lineStatesStream,
        itemBuilder: (MapEntry<Line, bool> lineState, int index,
                BuildContext context, Animation<double> animation) =>
            _lineListItem(lineState, index, animation, false, selectionChanged),
        itemRemovedBuilder: (MapEntry<Line, bool> lineState, int index,
                BuildContext context, Animation<double> animation) =>
            _lineListItem(lineState, index, animation, true, selectionChanged),
        equals: (ls1, ls2) => ls1.line.symbol == ls2.line.symbol,
      );

  Widget _lineListItem(
      MapEntry<Line, bool> lineState,
      int index,
      Animation<double> animation,
      bool removed,
      Function(Line, bool) selectionChanged) {
    final card = Card(
      child: ListTile(
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                lineState.key.symbol,
                style:
                    const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lineState.key.dest1,
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  lineState.key.dest2,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            )
          ],
        ),
        trailing: Checkbox(
          value: lineState.value,
          onChanged: removed
              ? null
              : (newValue) {
                  selectionChanged(lineState.key, newValue);
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
}

import 'package:animated_stream_list/animated_stream_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:search_app_bar/search_app_bar.dart';
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
  Widget build(BuildContext context) {
    return NestedScrollView(
        controller: _scrollViewController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
                titleSpacing: 0.0,
                title: SearchAppBar<LineListItemState>(
                  title: Text('Lines'),
                  searcher: BlocProvider.of<LinesBloc>(context),
                  filter: (LineListItemState item, String query) => item
                      .line.symbol
                      .toLowerCase()
                      .contains(query.trim().toLowerCase()),
                ),
                pinned: false,
                floating: true,
                snap: true,
                forceElevated: innerBoxIsScrolled)
          ];
        },
        body: _lineStatesList(BlocProvider.of<LinesBloc>(context)
            .map((state) => state.filteredItems)));
  }

  Widget _lineStatesList(Stream<List<LineListItemState>> lineStatesStream) {
    return AnimatedStreamList<LineListItemState>(
      streamList: lineStatesStream,
      itemBuilder: (LineListItemState lineState, int index,
              BuildContext context, Animation<double> animation) =>
          _tile(lineState, index, animation),
      itemRemovedBuilder: (LineListItemState lineState, int index,
              BuildContext context, Animation<double> animation) =>
          _removedTile(lineState, index, animation),
      equals: (ls1, ls2) => ls1.line.symbol == ls2.line.symbol,
    );
  }

  Widget _tile(
      LineListItemState lineState, int index, Animation<double> animation) {
    final textStyle = TextStyle();
    final card = Card(
      child: ListTile(
        leading: Checkbox(
          value: lineState.selected,
          onChanged: (newValue) => {},
        ),
        title: Text(
          lineState.line.symbol,
          style: textStyle,
        ),
        subtitle: Text(
          lineState.line.dest1 + ' : ' + lineState.line.dest2,
          style: textStyle,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => {},
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

  Widget _removedTile(
      LineListItemState lineState, int index, Animation<double> animation) {
    final textStyle = TextStyle();
    final card = Card(
      child: ListTile(
        leading: Checkbox(
          value: lineState.selected,
          onChanged: null,
        ),
        title: Text(
          lineState.line.symbol,
          style: textStyle,
        ),
        subtitle: Text(
          lineState.line.dest1 + ' : ' + lineState.line.dest2,
          style: textStyle,
        ),
        trailing: const Icon(Icons.delete),
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

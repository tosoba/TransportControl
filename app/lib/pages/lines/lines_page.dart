import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
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
                      BlocProvider.of<LinesBloc>(context).itemSelectionChanged,
                ),
              ),
              _selectedLinesText,
            ],
          )),
    );
  }

  Widget _searchLinesAppBar(BuildContext context, bool innerBoxIsScrolled) {
    return SliverAppBar(
      leading: null,
      automaticallyImplyLeading: false,
      titleSpacing: 0.0,
      title: SearchAppBar<MapEntry<Line, LineState>>(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Lines'),
        searcher: BlocProvider.of<LinesBloc>(context),
        filter: (MapEntry<Line, LineState> item, String query) =>
            item.key.symbol.toLowerCase().contains(query.trim().toLowerCase()),
      ),
      pinned: false,
      floating: true,
      snap: true,
      forceElevated: innerBoxIsScrolled,
    );
  }

  Widget get _selectedLinesText => BlocBuilder<LinesBloc, LinesState>(
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
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context, true);
                    },
                    child: Text('Search'),
                  )
                ])
              : Container();
        },
      );

  Widget _linesList({
    Stream<List<MapEntry<Line, LineState>>> itemsStream,
    Function(Line) selectionChanged,
  }) {
    return StreamBuilder(
        stream: itemsStream,
        builder: (
          BuildContext context,
          AsyncSnapshot<List<MapEntry<Line, LineState>>> snapshot,
        ) {
          if (snapshot.data == null) return Container();

          final columnsCount =
              MediaQuery.of(context).orientation == Orientation.portrait
                  ? 4
                  : 8;
          return AnimationLimiter(
              child: GridView.count(
            crossAxisCount: columnsCount,
            children: List.generate(
              snapshot.data.length,
              (int index) {
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 250),
                  columnCount: columnsCount,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: _lineListItem(
                        snapshot.data[index],
                        index,
                        selectionChanged,
                      ),
                    ),
                  ),
                );
              },
            ),
          ));
        });
  }

  Widget _lineListItem(
    MapEntry<Line, LineState> item,
    int index,
    Function(Line) itemSelectionChanged,
  ) {
    final inkWell = InkWell(
      onTap: () {
        itemSelectionChanged(item.key);
      },
      child: Center(
        child: Text(
          item.key.symbol,
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
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

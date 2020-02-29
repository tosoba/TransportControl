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
    return BlocBuilder<LinesBloc, LinesState>(
      builder: (context, state) {
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
            body: ListView.separated(
                separatorBuilder: (context, index) =>
                    Divider(color: Colors.black),
                itemCount: state.filteredItems.length,
                itemBuilder: (context, index) {
                  return LineListItem(
                      state: state.filteredItems.elementAt(index));
                }));
      },
    );
  }
}

class LineListItem extends StatelessWidget {
  final LineListItemState state;

  const LineListItem({Key key, this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(state.line.symbol),
        Column(
          children: [Text(state.line.dest1), Text(state.line.dest2)],
        )
      ],
    );
  }
}

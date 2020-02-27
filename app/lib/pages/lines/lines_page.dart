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
                    title: SearchAppBar<LineListItem>(
                      title: Text('Lines'),
                      searcher: BlocProvider.of<LinesBloc>(context),
                      filter: (LineListItem item, String query) => item
                          .line.symbol
                          .toLowerCase()
                          .contains(query.toLowerCase()),
                    ),
                    pinned: false,
                    floating: true,
                    snap: true,
                    forceElevated: innerBoxIsScrolled)
              ];
            },
            body: ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  return Text(state.items.elementAt(index).line.symbol);
                }));
      },
    );
  }
}

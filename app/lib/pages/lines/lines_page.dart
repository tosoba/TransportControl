import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transport_control/pages/lines/lines_bloc.dart';

class LinesPage extends StatelessWidget {
  const LinesPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: BlocBuilder<LinesBloc, LinesState>(
        builder: (context, state) {
          return ListView.builder(
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                return Text(state.items.elementAt(index).line.symbol);
              });
        },
      ),
    );
  }
}

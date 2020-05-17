import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:transport_control/pages/nearby/nearby_bloc.dart';
import 'package:transport_control/pages/nearby/nearby_state.dart';

class NearbyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<NearbyState>(
      stream: context.bloc<NearbyBloc>(),
      builder: (context, snapshot) {
        final state = snapshot.data;
        if (state == null) {
          return Center(child: CircularProgressIndicator());
        } else if (state.query == null || state.query.isEmpty) {
          if (state.latestQueries.isEmpty) {
            return Center(child: Text('No recent queries.'));
          } else {
            return ListView.builder(
              itemCount: state.latestQueries.length,
              itemBuilder: (context, index) => Text(state.latestQueries[index]),
            );
          }
        } else {
          if (state.suggestions.isEmpty) {
            return Center(child: Text('No results found.'));
          } else {
            return ListView.builder(
              itemCount: state.suggestions.length,
              itemBuilder: (context, index) => Text(
                state.suggestions[index].address.street,
              ),
            );
          }
        }
      },
    );
  }
}

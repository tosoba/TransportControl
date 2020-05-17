import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:transport_control/pages/nearby/nearby_bloc.dart';
import 'package:transport_control/pages/nearby/nearby_state.dart';

class NearbyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<NearbyState>(
      stream: context.bloc<NearbyBloc>(),
      builder: (context, snapshot) => Container(
        child: _nearbyWidget(state: snapshot.data),
        color: Colors.white,
      ),
    );
  }

  Widget _nearbyWidget({@required NearbyState state}) {
    if (state == null) {
      return Center(child: Text('No recent queries.'));
    } else if (state.query == null || state.query.isEmpty) {
      if (state.latestQueries.isEmpty) {
        return Center(child: Text('No recent queries.'));
      } else {
        return ListView.builder(
          itemCount: state.latestQueries.length,
          itemBuilder: (context, index) => Text(state.latestQueries[index]),
        );
      }
    }

    return state.suggestions.when(
      loading: (_) => Center(child: CircularProgressIndicator()),
      value: (suggestions) => ListView.builder(
        itemCount: state.suggestions.value.length,
        itemBuilder: (context, index) => Text(
          state.suggestions.value[index].address?.street ?? 'Unknown',
        ),
      ),
      error: (_) => Center(child: Text('Error loading places.')),
    );
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:transport_control/model/place_suggestion.dart';
import 'package:transport_control/pages/nearby/nearby_bloc.dart';
import 'package:transport_control/pages/nearby/nearby_state.dart';
import 'package:transport_control/util/model_util.dart';

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
      if (state.recentlySearchedSuggestions.isEmpty) {
        return Center(child: Text('No recent queries.'));
      } else {
        return _recentlySearchedSuggestionsList(
          state.recentlySearchedSuggestions,
        );
      }
    }

    return state.suggestions.when(
      loading: (_) => Center(child: CircularProgressIndicator()),
      value: (suggestions) => suggestions.value.isEmpty
          ? Center(child: Text('No places found.'))
          : _placeSuggestionsList(suggestions.value),
      error: (_) => Center(child: Text('Error loading places.')),
    );
  }

  Widget _recentlySearchedSuggestionsList(List<PlaceSuggestion> suggestions) {
    return ListView.builder(
      itemCount: suggestions.length + 1,
      itemBuilder: (context, index) => index == 0
          ? Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 0.0),
              child: Text(
                'Recent searches'.toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : Material(
              child: InkWell(
                onTap: () {
                  context.bloc<NearbyBloc>().suggestionSelected(
                        locationId: suggestions[index - 1].locationId,
                      );
                },
                child: ListTile(
                  title: Text(suggestions[index - 1].label),
                  subtitle: Text(
                    suggestions[index - 1].lastSearchedLabel,
                  ),
                ),
              ),
            ),
    );
  }

  Widget _placeSuggestionsList(List<PlaceSuggestion> suggestions) {
    return ListView.builder(
      itemCount: suggestions.length + 1,
      itemBuilder: (context, index) => index == 0
          ? Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 0.0),
              child: Text(
                'Suggestions'.toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : Material(
              child: InkWell(
                onTap: () {
                  context.bloc<NearbyBloc>().suggestionSelected(
                        locationId: suggestions[index - 1].locationId,
                      );
                },
                child: ListTile(
                  title: Text(suggestions[index - 1].label),
                  subtitle: Text(
                    suggestions[index - 1].address?.street ?? 'Unknown address',
                  ),
                ),
              ),
            ),
    );
  }
}

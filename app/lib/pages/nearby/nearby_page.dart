import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transport_control/model/place_suggestion.dart';
import 'package:transport_control/pages/nearby/nearby_bloc.dart';
import 'package:transport_control/pages/nearby/nearby_state.dart';
import 'package:transport_control/util/model_util.dart';

class NearbyPage extends StatelessWidget {
  final void Function() suggestionSelected;

  const NearbyPage({
    Key key,
    @required this.suggestionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NearbyBloc, NearbyState>(
      builder: (context, state) => Container(
        child: _nearbyWidget(state: state),
        color: Theme.of(context).primaryColor,
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
        return _suggestionsList(
          state.recentlySearchedSuggestions,
          headerText: 'Recent searches',
          title: (suggestion) => Text(suggestion.title),
          subtitle: (suggestion) => Text(suggestion.lastSearchedLabel),
        );
      }
    }

    return state.suggestions.when(
      loading: (_) => Center(child: CircularProgressIndicator()),
      value: (suggestions) => suggestions.value.isEmpty
          ? Center(child: Text('No places found.'))
          : _suggestionsList(
              suggestions.value,
              headerText: 'Suggestions',
              title: (suggestion) => Text(suggestion.title),
              subtitle: (suggestion) => Text(
                suggestion.address?.label ?? 'Unknown address',
              ),
            ),
      error: (_) => Center(child: Text('Error loading places.')),
    );
  }

  Widget _suggestionsList(
    List<PlaceSuggestion> suggestions, {
    @required String headerText,
    @required Widget Function(PlaceSuggestion) title,
    @required Widget Function(PlaceSuggestion) subtitle,
  }) {
    return ListView.builder(
      itemCount: suggestions.length + 1,
      itemBuilder: (context, index) => index == 0
          ? Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 0.0),
              child: Text(
                headerText.toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : Material(
              child: InkWell(
                onTap: () {
                  final suggestion = suggestions[index - 1];
                  context.read<NearbyBloc>().suggestionSelected(suggestion);
                  suggestionSelected();
                },
                child: ListTile(
                  title: title(suggestions[index - 1]),
                  subtitle: subtitle(suggestions[index - 1]),
                ),
              ),
            ),
    );
  }
}

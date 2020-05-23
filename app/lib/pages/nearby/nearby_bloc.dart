import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transport_control/model/loadable.dart';
import 'package:transport_control/model/place_suggestion.dart';
import 'package:transport_control/pages/nearby/nearby_event.dart';
import 'package:transport_control/pages/nearby/nearby_state.dart';
import 'package:transport_control/repo/place_suggestions_repo.dart';
import 'package:stream_transform/stream_transform.dart';

class NearbyBloc extends Bloc<NearbyEvent, NearbyState> {
  final PlaceSuggestionsRepo _repo;
  final _queries = StreamController<String>();
  final _submittedQueries = StreamController<String>();

  final List<StreamSubscription> subscriptions = [];

  NearbyBloc(this._repo) {
    subscriptions
      ..add(
        _submittedQueries.stream
            .merge(_queries.stream.debounce(const Duration(milliseconds: 1000)))
            .distinct()
            .tap(
              (_) => add(
                NearbyEvent.updateSuggestions(
                  suggestions: Loadable<List<PlaceSuggestion>>.loading(),
                ),
              ),
            )
            .switchMap(
              (query) => Stream.fromFuture(_repo.getSuggestions(query: query)),
            )
            .listen(
              (result) => result.when(
                success: (success) {
                  add(
                    NearbyEvent.updateSuggestions(
                      suggestions: Loadable<List<PlaceSuggestion>>.value(
                        value: success.data
                            .where((suggestion) => suggestion.label != null)
                            .toList(),
                      ),
                    ),
                  );
                },
                failure: (failure) {
                  add(
                    NearbyEvent.updateSuggestions(
                      suggestions: Loadable<List<PlaceSuggestion>>.error(
                        error: failure.error,
                      ),
                    ),
                  );
                  log(failure.error?.toString() ?? 'Unknown error');
                },
              ),
            ),
      )
      ..add(
        _repo.getLatestQueries(limit: 10).listen((queries) {
          add(NearbyEvent.updateLatestQueries(queries: queries));
        }),
      );
  }

  @override
  NearbyState get initialState => NearbyState.initial();

  @override
  Future<void> close() async {
    await Future.wait(
      subscriptions.map((subscription) => subscription.cancel()),
    );
    await Future.wait([_queries.close(), _submittedQueries.close()]);
    return super.close();
  }

  @override
  Stream<NearbyState> mapEventToState(NearbyEvent event) async* {
    yield event.when(
      updateQuery: (evt) => state.copyWith(query: evt.query),
      updateSuggestions: (evt) => state.copyWith(suggestions: evt.suggestions),
      updateLatestQueries: (evt) => state.copyWith(latestQueries: evt.queries),
    );
  }

  void queryUpdated(String query, {@required bool submitted}) {
    if (query == null) return;
    final processedQuery = query.trim().toLowerCase();
    if (processedQuery.isEmpty) return;

    add(NearbyEvent.updateQuery(query: query));

    if (submitted) {
      _submittedQueries.add(processedQuery.toLowerCase());
    } else {
      _queries.add(processedQuery.toLowerCase());
    }
  }
}

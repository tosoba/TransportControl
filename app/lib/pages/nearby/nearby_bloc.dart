import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:transport_control/model/loadable.dart';
import 'package:transport_control/model/place_suggestion.dart';
import 'package:transport_control/pages/nearby/nearby_event.dart';
import 'package:transport_control/pages/nearby/nearby_state.dart';
import 'package:transport_control/repo/place_suggestions_repo.dart';

class NearbyBloc extends Bloc<NearbyEvent, NearbyState> {
  final PlaceSuggestionsRepo _repo;
  final Sink<PlaceSuggestion> _loadVehiclesNearbyPlaceSink;
  final _queries = StreamController<String>();
  final _submittedQueries = StreamController<String>();

  final List<StreamSubscription> subscriptions = [];

  NearbyBloc(this._repo, this._loadVehiclesNearbyPlaceSink)
      : super(NearbyState.initial()) {
    on<UpdateQuery>((event, emit) => emit(state.copyWith(query: event.query)));
    on<UpdateSuggestions>(
      (event, emit) => emit(state.copyWith(suggestions: event.suggestions)),
    );
    on<UpdateRecentlySearchedSuggestions>(
      (event, emit) => emit(
        state.copyWith(
          recentlySearchedSuggestions: event.suggestions,
        ),
      ),
    );

    subscriptions
      ..add(
        _submittedQueries.stream
            .merge(_queries.stream.debounce(const Duration(seconds: 1)))
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
                        value: success.data,
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
        _repo.getRecentlySearchedSuggestions(limit: 20).listen((suggestions) {
          add(
            NearbyEvent.updateRecentlySearchedSuggestions(
              suggestions: suggestions,
            ),
          );
        }),
      );
  }

  @override
  Future<void> close() async {
    await Future.wait([
      ...subscriptions.map((subscription) => subscription.cancel()),
      _queries.close(),
      _submittedQueries.close()
    ]);
    return super.close();
  }

  void queryUpdated(String query, {@required bool submitted}) {
    if (query == null) {
      add(NearbyEvent.updateQuery(query: query));
      return;
    }

    final processedQuery = query.trim().toLowerCase();
    add(NearbyEvent.updateQuery(query: processedQuery));
    if (processedQuery.isEmpty) return;

    if (submitted) {
      _submittedQueries.add(processedQuery);
    } else {
      _queries.add(processedQuery);
    }
  }

  void suggestionSelected(PlaceSuggestion suggestion) {
    _repo.updateLastSearchedBy(locationId: suggestion.id);
    _loadVehiclesNearbyPlaceSink.add(suggestion);
  }
}

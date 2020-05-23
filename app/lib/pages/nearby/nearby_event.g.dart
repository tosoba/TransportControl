// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nearby_event.dart';

// **************************************************************************
// SuperEnumGenerator
// **************************************************************************

@immutable
abstract class NearbyEvent extends Equatable {
  const NearbyEvent(this._type);

  factory NearbyEvent.updateQuery({@required String query}) = UpdateQuery;

  factory NearbyEvent.updateSuggestions({@required dynamic suggestions}) =
      UpdateSuggestions;

  factory NearbyEvent.updateRecentlySearchedSuggestions(
          {@required List<PlaceSuggestion> suggestions}) =
      UpdateRecentlySearchedSuggestions;

  final _NearbyEvent _type;

//ignore: missing_return
  R when<R>(
      {@required
          R Function(UpdateQuery) updateQuery,
      @required
          R Function(UpdateSuggestions) updateSuggestions,
      @required
          R Function(UpdateRecentlySearchedSuggestions)
              updateRecentlySearchedSuggestions}) {
    assert(() {
      if (updateQuery == null ||
          updateSuggestions == null ||
          updateRecentlySearchedSuggestions == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _NearbyEvent.UpdateQuery:
        return updateQuery(this as UpdateQuery);
      case _NearbyEvent.UpdateSuggestions:
        return updateSuggestions(this as UpdateSuggestions);
      case _NearbyEvent.UpdateRecentlySearchedSuggestions:
        return updateRecentlySearchedSuggestions(
            this as UpdateRecentlySearchedSuggestions);
    }
  }

//ignore: missing_return
  Future<R> asyncWhen<R>(
      {@required
          FutureOr<R> Function(UpdateQuery) updateQuery,
      @required
          FutureOr<R> Function(UpdateSuggestions) updateSuggestions,
      @required
          FutureOr<R> Function(UpdateRecentlySearchedSuggestions)
              updateRecentlySearchedSuggestions}) {
    assert(() {
      if (updateQuery == null ||
          updateSuggestions == null ||
          updateRecentlySearchedSuggestions == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _NearbyEvent.UpdateQuery:
        return updateQuery(this as UpdateQuery);
      case _NearbyEvent.UpdateSuggestions:
        return updateSuggestions(this as UpdateSuggestions);
      case _NearbyEvent.UpdateRecentlySearchedSuggestions:
        return updateRecentlySearchedSuggestions(
            this as UpdateRecentlySearchedSuggestions);
    }
  }

  R whenOrElse<R>(
      {R Function(UpdateQuery) updateQuery,
      R Function(UpdateSuggestions) updateSuggestions,
      R Function(UpdateRecentlySearchedSuggestions)
          updateRecentlySearchedSuggestions,
      @required R Function(NearbyEvent) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _NearbyEvent.UpdateQuery:
        if (updateQuery == null) break;
        return updateQuery(this as UpdateQuery);
      case _NearbyEvent.UpdateSuggestions:
        if (updateSuggestions == null) break;
        return updateSuggestions(this as UpdateSuggestions);
      case _NearbyEvent.UpdateRecentlySearchedSuggestions:
        if (updateRecentlySearchedSuggestions == null) break;
        return updateRecentlySearchedSuggestions(
            this as UpdateRecentlySearchedSuggestions);
    }
    return orElse(this);
  }

  Future<R> asyncWhenOrElse<R>(
      {FutureOr<R> Function(UpdateQuery) updateQuery,
      FutureOr<R> Function(UpdateSuggestions) updateSuggestions,
      FutureOr<R> Function(UpdateRecentlySearchedSuggestions)
          updateRecentlySearchedSuggestions,
      @required FutureOr<R> Function(NearbyEvent) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _NearbyEvent.UpdateQuery:
        if (updateQuery == null) break;
        return updateQuery(this as UpdateQuery);
      case _NearbyEvent.UpdateSuggestions:
        if (updateSuggestions == null) break;
        return updateSuggestions(this as UpdateSuggestions);
      case _NearbyEvent.UpdateRecentlySearchedSuggestions:
        if (updateRecentlySearchedSuggestions == null) break;
        return updateRecentlySearchedSuggestions(
            this as UpdateRecentlySearchedSuggestions);
    }
    return orElse(this);
  }

//ignore: missing_return
  Future<void> whenPartial(
      {FutureOr<void> Function(UpdateQuery) updateQuery,
      FutureOr<void> Function(UpdateSuggestions) updateSuggestions,
      FutureOr<void> Function(UpdateRecentlySearchedSuggestions)
          updateRecentlySearchedSuggestions}) {
    assert(() {
      if (updateQuery == null &&
          updateSuggestions == null &&
          updateRecentlySearchedSuggestions == null) {
        throw 'provide at least one branch';
      }
      return true;
    }());
    switch (this._type) {
      case _NearbyEvent.UpdateQuery:
        if (updateQuery == null) break;
        return updateQuery(this as UpdateQuery);
      case _NearbyEvent.UpdateSuggestions:
        if (updateSuggestions == null) break;
        return updateSuggestions(this as UpdateSuggestions);
      case _NearbyEvent.UpdateRecentlySearchedSuggestions:
        if (updateRecentlySearchedSuggestions == null) break;
        return updateRecentlySearchedSuggestions(
            this as UpdateRecentlySearchedSuggestions);
    }
  }

  @override
  List get props => const [];
}

@immutable
class UpdateQuery extends NearbyEvent {
  const UpdateQuery({@required this.query}) : super(_NearbyEvent.UpdateQuery);

  final String query;

  @override
  String toString() => 'UpdateQuery(query:${this.query})';
  @override
  List get props => [query];
}

@immutable
class UpdateSuggestions extends NearbyEvent {
  const UpdateSuggestions({@required this.suggestions})
      : super(_NearbyEvent.UpdateSuggestions);

  final dynamic suggestions;

  @override
  String toString() => 'UpdateSuggestions(suggestions:${this.suggestions})';
  @override
  List get props => [suggestions];
}

@immutable
class UpdateRecentlySearchedSuggestions extends NearbyEvent {
  const UpdateRecentlySearchedSuggestions({@required this.suggestions})
      : super(_NearbyEvent.UpdateRecentlySearchedSuggestions);

  final List<PlaceSuggestion> suggestions;

  @override
  String toString() =>
      'UpdateRecentlySearchedSuggestions(suggestions:${this.suggestions})';
  @override
  List get props => [suggestions];
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nearby_event.dart';

// **************************************************************************
// SuperEnumGenerator
// **************************************************************************

@immutable
abstract class NearbyEvent extends Equatable {
  const NearbyEvent(this._type);

  factory NearbyEvent.updateSuggestions(
      {@required List<PlaceSuggestion> suggestions}) = UpdateSuggestions;

  factory NearbyEvent.updateLatestQueries({@required List<String> queries}) =
      UpdateLatestQueries;

  final _NearbyEvent _type;

//ignore: missing_return
  R when<R>(
      {@required R Function(UpdateSuggestions) updateSuggestions,
      @required R Function(UpdateLatestQueries) updateLatestQueries}) {
    assert(() {
      if (updateSuggestions == null || updateLatestQueries == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _NearbyEvent.UpdateSuggestions:
        return updateSuggestions(this as UpdateSuggestions);
      case _NearbyEvent.UpdateLatestQueries:
        return updateLatestQueries(this as UpdateLatestQueries);
    }
  }

//ignore: missing_return
  Future<R> asyncWhen<R>(
      {@required
          FutureOr<R> Function(UpdateSuggestions) updateSuggestions,
      @required
          FutureOr<R> Function(UpdateLatestQueries) updateLatestQueries}) {
    assert(() {
      if (updateSuggestions == null || updateLatestQueries == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _NearbyEvent.UpdateSuggestions:
        return updateSuggestions(this as UpdateSuggestions);
      case _NearbyEvent.UpdateLatestQueries:
        return updateLatestQueries(this as UpdateLatestQueries);
    }
  }

  R whenOrElse<R>(
      {R Function(UpdateSuggestions) updateSuggestions,
      R Function(UpdateLatestQueries) updateLatestQueries,
      @required R Function(NearbyEvent) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _NearbyEvent.UpdateSuggestions:
        if (updateSuggestions == null) break;
        return updateSuggestions(this as UpdateSuggestions);
      case _NearbyEvent.UpdateLatestQueries:
        if (updateLatestQueries == null) break;
        return updateLatestQueries(this as UpdateLatestQueries);
    }
    return orElse(this);
  }

  Future<R> asyncWhenOrElse<R>(
      {FutureOr<R> Function(UpdateSuggestions) updateSuggestions,
      FutureOr<R> Function(UpdateLatestQueries) updateLatestQueries,
      @required FutureOr<R> Function(NearbyEvent) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _NearbyEvent.UpdateSuggestions:
        if (updateSuggestions == null) break;
        return updateSuggestions(this as UpdateSuggestions);
      case _NearbyEvent.UpdateLatestQueries:
        if (updateLatestQueries == null) break;
        return updateLatestQueries(this as UpdateLatestQueries);
    }
    return orElse(this);
  }

//ignore: missing_return
  Future<void> whenPartial(
      {FutureOr<void> Function(UpdateSuggestions) updateSuggestions,
      FutureOr<void> Function(UpdateLatestQueries) updateLatestQueries}) {
    assert(() {
      if (updateSuggestions == null && updateLatestQueries == null) {
        throw 'provide at least one branch';
      }
      return true;
    }());
    switch (this._type) {
      case _NearbyEvent.UpdateSuggestions:
        if (updateSuggestions == null) break;
        return updateSuggestions(this as UpdateSuggestions);
      case _NearbyEvent.UpdateLatestQueries:
        if (updateLatestQueries == null) break;
        return updateLatestQueries(this as UpdateLatestQueries);
    }
  }

  @override
  List get props => const [];
}

@immutable
class UpdateSuggestions extends NearbyEvent {
  const UpdateSuggestions({@required this.suggestions})
      : super(_NearbyEvent.UpdateSuggestions);

  final List<PlaceSuggestion> suggestions;

  @override
  String toString() => 'UpdateSuggestions(suggestions:${this.suggestions})';
  @override
  List get props => [suggestions];
}

@immutable
class UpdateLatestQueries extends NearbyEvent {
  const UpdateLatestQueries({@required this.queries})
      : super(_NearbyEvent.UpdateLatestQueries);

  final List<String> queries;

  @override
  String toString() => 'UpdateLatestQueries(queries:${this.queries})';
  @override
  List get props => [queries];
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nearby_event.dart';

// **************************************************************************
// SuperEnumGenerator
// **************************************************************************

@immutable
abstract class NearbyEvent extends Equatable {
  const NearbyEvent(this._type);

  factory NearbyEvent.queryChanged({@required String query}) = QueryChanged;

  final _NearbyEvent _type;

//ignore: missing_return
  R when<R>({@required R Function(QueryChanged) queryChanged}) {
    assert(() {
      if (queryChanged == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _NearbyEvent.QueryChanged:
        return queryChanged(this as QueryChanged);
    }
  }

//ignore: missing_return
  Future<R> asyncWhen<R>(
      {@required FutureOr<R> Function(QueryChanged) queryChanged}) {
    assert(() {
      if (queryChanged == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _NearbyEvent.QueryChanged:
        return queryChanged(this as QueryChanged);
    }
  }

  R whenOrElse<R>(
      {R Function(QueryChanged) queryChanged,
      @required R Function(NearbyEvent) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _NearbyEvent.QueryChanged:
        if (queryChanged == null) break;
        return queryChanged(this as QueryChanged);
    }
    return orElse(this);
  }

  Future<R> asyncWhenOrElse<R>(
      {FutureOr<R> Function(QueryChanged) queryChanged,
      @required FutureOr<R> Function(NearbyEvent) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _NearbyEvent.QueryChanged:
        if (queryChanged == null) break;
        return queryChanged(this as QueryChanged);
    }
    return orElse(this);
  }

//ignore: missing_return
  Future<void> whenPartial(
      {FutureOr<void> Function(QueryChanged) queryChanged}) {
    assert(() {
      if (queryChanged == null) {
        throw 'provide at least one branch';
      }
      return true;
    }());
    switch (this._type) {
      case _NearbyEvent.QueryChanged:
        if (queryChanged == null) break;
        return queryChanged(this as QueryChanged);
    }
  }

  @override
  List get props => const [];
}

@immutable
class QueryChanged extends NearbyEvent {
  const QueryChanged({@required this.query}) : super(_NearbyEvent.QueryChanged);

  final String query;

  @override
  String toString() => 'QueryChanged(query:${this.query})';
  @override
  List get props => [query];
}

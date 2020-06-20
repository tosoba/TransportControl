// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'searched_item_identifier.dart';

// **************************************************************************
// SuperEnumGenerator
// **************************************************************************

@immutable
abstract class SearchedItemIdentifier extends Equatable {
  const SearchedItemIdentifier(this._type);

  factory SearchedItemIdentifier.line({@required String symbol}) = Line;

  factory SearchedItemIdentifier.location({@required int id}) = Location;

  final _SearchedItemIdentifier _type;

//ignore: missing_return
  R when<R>(
      {@required R Function(Line) line,
      @required R Function(Location) location}) {
    assert(() {
      if (line == null || location == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _SearchedItemIdentifier.Line:
        return line(this as Line);
      case _SearchedItemIdentifier.Location:
        return location(this as Location);
    }
  }

//ignore: missing_return
  Future<R> asyncWhen<R>(
      {@required FutureOr<R> Function(Line) line,
      @required FutureOr<R> Function(Location) location}) {
    assert(() {
      if (line == null || location == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _SearchedItemIdentifier.Line:
        return line(this as Line);
      case _SearchedItemIdentifier.Location:
        return location(this as Location);
    }
  }

  R whenOrElse<R>(
      {R Function(Line) line,
      R Function(Location) location,
      @required R Function(SearchedItemIdentifier) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _SearchedItemIdentifier.Line:
        if (line == null) break;
        return line(this as Line);
      case _SearchedItemIdentifier.Location:
        if (location == null) break;
        return location(this as Location);
    }
    return orElse(this);
  }

  Future<R> asyncWhenOrElse<R>(
      {FutureOr<R> Function(Line) line,
      FutureOr<R> Function(Location) location,
      @required FutureOr<R> Function(SearchedItemIdentifier) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _SearchedItemIdentifier.Line:
        if (line == null) break;
        return line(this as Line);
      case _SearchedItemIdentifier.Location:
        if (location == null) break;
        return location(this as Location);
    }
    return orElse(this);
  }

//ignore: missing_return
  Future<void> whenPartial(
      {FutureOr<void> Function(Line) line,
      FutureOr<void> Function(Location) location}) {
    assert(() {
      if (line == null && location == null) {
        throw 'provide at least one branch';
      }
      return true;
    }());
    switch (this._type) {
      case _SearchedItemIdentifier.Line:
        if (line == null) break;
        return line(this as Line);
      case _SearchedItemIdentifier.Location:
        if (location == null) break;
        return location(this as Location);
    }
  }

  @override
  List get props => const [];
}

@immutable
class Line extends SearchedItemIdentifier {
  const Line({@required this.symbol}) : super(_SearchedItemIdentifier.Line);

  final String symbol;

  @override
  String toString() => 'Line(symbol:${this.symbol})';
  @override
  List get props => [symbol];
}

@immutable
class Location extends SearchedItemIdentifier {
  const Location({@required this.id}) : super(_SearchedItemIdentifier.Location);

  final int id;

  @override
  String toString() => 'Location(id:${this.id})';
  @override
  List get props => [id];
}

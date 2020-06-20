// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'searched_item.dart';

// **************************************************************************
// SuperEnumGenerator
// **************************************************************************

@immutable
abstract class SearchedItem extends Equatable {
  const SearchedItem(this._type);

  factory SearchedItem.lineItem({@required Line line}) = LineItem;

  factory SearchedItem.locationItem({@required Location location}) =
      LocationItem;

  final _SearchedItem _type;

//ignore: missing_return
  R when<R>(
      {@required R Function(LineItem) lineItem,
      @required R Function(LocationItem) locationItem}) {
    assert(() {
      if (lineItem == null || locationItem == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _SearchedItem.LineItem:
        return lineItem(this as LineItem);
      case _SearchedItem.LocationItem:
        return locationItem(this as LocationItem);
    }
  }

//ignore: missing_return
  Future<R> asyncWhen<R>(
      {@required FutureOr<R> Function(LineItem) lineItem,
      @required FutureOr<R> Function(LocationItem) locationItem}) {
    assert(() {
      if (lineItem == null || locationItem == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _SearchedItem.LineItem:
        return lineItem(this as LineItem);
      case _SearchedItem.LocationItem:
        return locationItem(this as LocationItem);
    }
  }

  R whenOrElse<R>(
      {R Function(LineItem) lineItem,
      R Function(LocationItem) locationItem,
      @required R Function(SearchedItem) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _SearchedItem.LineItem:
        if (lineItem == null) break;
        return lineItem(this as LineItem);
      case _SearchedItem.LocationItem:
        if (locationItem == null) break;
        return locationItem(this as LocationItem);
    }
    return orElse(this);
  }

  Future<R> asyncWhenOrElse<R>(
      {FutureOr<R> Function(LineItem) lineItem,
      FutureOr<R> Function(LocationItem) locationItem,
      @required FutureOr<R> Function(SearchedItem) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _SearchedItem.LineItem:
        if (lineItem == null) break;
        return lineItem(this as LineItem);
      case _SearchedItem.LocationItem:
        if (locationItem == null) break;
        return locationItem(this as LocationItem);
    }
    return orElse(this);
  }

//ignore: missing_return
  Future<void> whenPartial(
      {FutureOr<void> Function(LineItem) lineItem,
      FutureOr<void> Function(LocationItem) locationItem}) {
    assert(() {
      if (lineItem == null && locationItem == null) {
        throw 'provide at least one branch';
      }
      return true;
    }());
    switch (this._type) {
      case _SearchedItem.LineItem:
        if (lineItem == null) break;
        return lineItem(this as LineItem);
      case _SearchedItem.LocationItem:
        if (locationItem == null) break;
        return locationItem(this as LocationItem);
    }
  }

  @override
  List get props => const [];
}

@immutable
class LineItem extends SearchedItem {
  const LineItem({@required this.line}) : super(_SearchedItem.LineItem);

  final Line line;

  @override
  String toString() => 'LineItem(line:${this.line})';
  @override
  List get props => [line];
}

@immutable
class LocationItem extends SearchedItem {
  const LocationItem({@required this.location})
      : super(_SearchedItem.LocationItem);

  final Location location;

  @override
  String toString() => 'LocationItem(location:${this.location})';
  @override
  List get props => [location];
}

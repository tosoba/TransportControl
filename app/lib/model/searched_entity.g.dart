// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'searched_entity.dart';

// **************************************************************************
// SuperEnumGenerator
// **************************************************************************

@immutable
abstract class SearchedEntity extends Equatable {
  const SearchedEntity(this._type);

  factory SearchedEntity.lineEntity({@required dynamic line}) = LineEntity;

  factory SearchedEntity.locationEntity({@required dynamic location}) =
      LocationEntity;

  final _SearchedEntity _type;

//ignore: missing_return
  R when<R>(
      {@required R Function(LineEntity) lineEntity,
      @required R Function(LocationEntity) locationEntity}) {
    assert(() {
      if (lineEntity == null || locationEntity == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _SearchedEntity.LineEntity:
        return lineEntity(this as LineEntity);
      case _SearchedEntity.LocationEntity:
        return locationEntity(this as LocationEntity);
    }
  }

//ignore: missing_return
  Future<R> asyncWhen<R>(
      {@required FutureOr<R> Function(LineEntity) lineEntity,
      @required FutureOr<R> Function(LocationEntity) locationEntity}) {
    assert(() {
      if (lineEntity == null || locationEntity == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _SearchedEntity.LineEntity:
        return lineEntity(this as LineEntity);
      case _SearchedEntity.LocationEntity:
        return locationEntity(this as LocationEntity);
    }
  }

  R whenOrElse<R>(
      {R Function(LineEntity) lineEntity,
      R Function(LocationEntity) locationEntity,
      @required R Function(SearchedEntity) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _SearchedEntity.LineEntity:
        if (lineEntity == null) break;
        return lineEntity(this as LineEntity);
      case _SearchedEntity.LocationEntity:
        if (locationEntity == null) break;
        return locationEntity(this as LocationEntity);
    }
    return orElse(this);
  }

  Future<R> asyncWhenOrElse<R>(
      {FutureOr<R> Function(LineEntity) lineEntity,
      FutureOr<R> Function(LocationEntity) locationEntity,
      @required FutureOr<R> Function(SearchedEntity) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _SearchedEntity.LineEntity:
        if (lineEntity == null) break;
        return lineEntity(this as LineEntity);
      case _SearchedEntity.LocationEntity:
        if (locationEntity == null) break;
        return locationEntity(this as LocationEntity);
    }
    return orElse(this);
  }

//ignore: missing_return
  Future<void> whenPartial(
      {FutureOr<void> Function(LineEntity) lineEntity,
      FutureOr<void> Function(LocationEntity) locationEntity}) {
    assert(() {
      if (lineEntity == null && locationEntity == null) {
        throw 'provide at least one branch';
      }
      return true;
    }());
    switch (this._type) {
      case _SearchedEntity.LineEntity:
        if (lineEntity == null) break;
        return lineEntity(this as LineEntity);
      case _SearchedEntity.LocationEntity:
        if (locationEntity == null) break;
        return locationEntity(this as LocationEntity);
    }
  }

  @override
  List get props => const [];
}

@immutable
class LineEntity extends SearchedEntity {
  const LineEntity({@required this.line}) : super(_SearchedEntity.LineEntity);

  final dynamic line;

  @override
  String toString() => 'LineEntity(line:${this.line})';
  @override
  List get props => [line];
}

@immutable
class LocationEntity extends SearchedEntity {
  const LocationEntity({@required this.location})
      : super(_SearchedEntity.LocationEntity);

  final dynamic location;

  @override
  String toString() => 'LocationEntity(location:${this.location})';
  @override
  List get props => [location];
}

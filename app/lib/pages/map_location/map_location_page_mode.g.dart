// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_location_page_mode.dart';

// **************************************************************************
// SuperEnumGenerator
// **************************************************************************

@immutable
abstract class MapLocationPageMode extends Equatable {
  const MapLocationPageMode(this._type);

  factory MapLocationPageMode.add() = Add;

  factory MapLocationPageMode.edit({@required Location location}) = Edit;

  factory MapLocationPageMode.view({@required Location location}) = View;

  final _MapLocationPageMode _type;

//ignore: missing_return
  R when<R>(
      {@required R Function(Add) add,
      @required R Function(Edit) edit,
      @required R Function(View) view}) {
    assert(() {
      if (add == null || edit == null || view == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _MapLocationPageMode.Add:
        return add(this as Add);
      case _MapLocationPageMode.Edit:
        return edit(this as Edit);
      case _MapLocationPageMode.View:
        return view(this as View);
    }
  }

//ignore: missing_return
  Future<R> asyncWhen<R>(
      {@required FutureOr<R> Function(Add) add,
      @required FutureOr<R> Function(Edit) edit,
      @required FutureOr<R> Function(View) view}) {
    assert(() {
      if (add == null || edit == null || view == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _MapLocationPageMode.Add:
        return add(this as Add);
      case _MapLocationPageMode.Edit:
        return edit(this as Edit);
      case _MapLocationPageMode.View:
        return view(this as View);
    }
  }

  R whenOrElse<R>(
      {R Function(Add) add,
      R Function(Edit) edit,
      R Function(View) view,
      @required R Function(MapLocationPageMode) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _MapLocationPageMode.Add:
        if (add == null) break;
        return add(this as Add);
      case _MapLocationPageMode.Edit:
        if (edit == null) break;
        return edit(this as Edit);
      case _MapLocationPageMode.View:
        if (view == null) break;
        return view(this as View);
    }
    return orElse(this);
  }

  Future<R> asyncWhenOrElse<R>(
      {FutureOr<R> Function(Add) add,
      FutureOr<R> Function(Edit) edit,
      FutureOr<R> Function(View) view,
      @required FutureOr<R> Function(MapLocationPageMode) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _MapLocationPageMode.Add:
        if (add == null) break;
        return add(this as Add);
      case _MapLocationPageMode.Edit:
        if (edit == null) break;
        return edit(this as Edit);
      case _MapLocationPageMode.View:
        if (view == null) break;
        return view(this as View);
    }
    return orElse(this);
  }

//ignore: missing_return
  Future<void> whenPartial(
      {FutureOr<void> Function(Add) add,
      FutureOr<void> Function(Edit) edit,
      FutureOr<void> Function(View) view}) {
    assert(() {
      if (add == null && edit == null && view == null) {
        throw 'provide at least one branch';
      }
      return true;
    }());
    switch (this._type) {
      case _MapLocationPageMode.Add:
        if (add == null) break;
        return add(this as Add);
      case _MapLocationPageMode.Edit:
        if (edit == null) break;
        return edit(this as Edit);
      case _MapLocationPageMode.View:
        if (view == null) break;
        return view(this as View);
    }
  }

  @override
  List get props => const [];
}

@immutable
class Add extends MapLocationPageMode {
  const Add._() : super(_MapLocationPageMode.Add);

  factory Add() {
    _instance ??= const Add._();
    return _instance;
  }

  static Add _instance;
}

@immutable
class Edit extends MapLocationPageMode {
  const Edit({@required this.location}) : super(_MapLocationPageMode.Edit);

  final Location location;

  @override
  String toString() => 'Edit(location:${this.location})';
  @override
  List get props => [location];
}

@immutable
class View extends MapLocationPageMode {
  const View({@required this.location}) : super(_MapLocationPageMode.View);

  final Location location;

  @override
  String toString() => 'View(location:${this.location})';
  @override
  List get props => [location];
}

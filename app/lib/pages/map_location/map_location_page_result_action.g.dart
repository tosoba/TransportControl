// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_location_page_result_action.dart';

// **************************************************************************
// SuperEnumGenerator
// **************************************************************************

@immutable
abstract class MapLocationPageResultAction extends Equatable {
  const MapLocationPageResultAction(this._type);

  factory MapLocationPageResultAction.save() = Save;

  factory MapLocationPageResultAction.load() = Load;

  factory MapLocationPageResultAction.saveAndLoad() = SaveAndLoad;

  final _MapLocationPageResultAction _type;

//ignore: missing_return
  R when<R>(
      {@required R Function(Save) save,
      @required R Function(Load) load,
      @required R Function(SaveAndLoad) saveAndLoad}) {
    assert(() {
      if (save == null || load == null || saveAndLoad == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _MapLocationPageResultAction.Save:
        return save(this as Save);
      case _MapLocationPageResultAction.Load:
        return load(this as Load);
      case _MapLocationPageResultAction.SaveAndLoad:
        return saveAndLoad(this as SaveAndLoad);
    }
  }

//ignore: missing_return
  Future<R> asyncWhen<R>(
      {@required FutureOr<R> Function(Save) save,
      @required FutureOr<R> Function(Load) load,
      @required FutureOr<R> Function(SaveAndLoad) saveAndLoad}) {
    assert(() {
      if (save == null || load == null || saveAndLoad == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _MapLocationPageResultAction.Save:
        return save(this as Save);
      case _MapLocationPageResultAction.Load:
        return load(this as Load);
      case _MapLocationPageResultAction.SaveAndLoad:
        return saveAndLoad(this as SaveAndLoad);
    }
  }

  R whenOrElse<R>(
      {R Function(Save) save,
      R Function(Load) load,
      R Function(SaveAndLoad) saveAndLoad,
      @required R Function(MapLocationPageResultAction) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _MapLocationPageResultAction.Save:
        if (save == null) break;
        return save(this as Save);
      case _MapLocationPageResultAction.Load:
        if (load == null) break;
        return load(this as Load);
      case _MapLocationPageResultAction.SaveAndLoad:
        if (saveAndLoad == null) break;
        return saveAndLoad(this as SaveAndLoad);
    }
    return orElse(this);
  }

  Future<R> asyncWhenOrElse<R>(
      {FutureOr<R> Function(Save) save,
      FutureOr<R> Function(Load) load,
      FutureOr<R> Function(SaveAndLoad) saveAndLoad,
      @required FutureOr<R> Function(MapLocationPageResultAction) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _MapLocationPageResultAction.Save:
        if (save == null) break;
        return save(this as Save);
      case _MapLocationPageResultAction.Load:
        if (load == null) break;
        return load(this as Load);
      case _MapLocationPageResultAction.SaveAndLoad:
        if (saveAndLoad == null) break;
        return saveAndLoad(this as SaveAndLoad);
    }
    return orElse(this);
  }

//ignore: missing_return
  Future<void> whenPartial(
      {FutureOr<void> Function(Save) save,
      FutureOr<void> Function(Load) load,
      FutureOr<void> Function(SaveAndLoad) saveAndLoad}) {
    assert(() {
      if (save == null && load == null && saveAndLoad == null) {
        throw 'provide at least one branch';
      }
      return true;
    }());
    switch (this._type) {
      case _MapLocationPageResultAction.Save:
        if (save == null) break;
        return save(this as Save);
      case _MapLocationPageResultAction.Load:
        if (load == null) break;
        return load(this as Load);
      case _MapLocationPageResultAction.SaveAndLoad:
        if (saveAndLoad == null) break;
        return saveAndLoad(this as SaveAndLoad);
    }
  }

  @override
  List get props => const [];
}

@immutable
class Save extends MapLocationPageResultAction {
  const Save._() : super(_MapLocationPageResultAction.Save);

  factory Save() {
    _instance ??= const Save._();
    return _instance;
  }

  static Save _instance;
}

@immutable
class Load extends MapLocationPageResultAction {
  const Load._() : super(_MapLocationPageResultAction.Load);

  factory Load() {
    _instance ??= const Load._();
    return _instance;
  }

  static Load _instance;
}

@immutable
class SaveAndLoad extends MapLocationPageResultAction {
  const SaveAndLoad._() : super(_MapLocationPageResultAction.SaveAndLoad);

  factory SaveAndLoad() {
    _instance ??= const SaveAndLoad._();
    return _instance;
  }

  static SaveAndLoad _instance;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'last_searched_event.dart';

// **************************************************************************
// SuperEnumGenerator
// **************************************************************************

@immutable
abstract class LastSearchedEvent extends Equatable {
  const LastSearchedEvent(this._type);

  factory LastSearchedEvent.updateItems({@required List<dynamic> items}) =
      UpdateItems;

  final _LastSearchedEvent _type;

//ignore: missing_return
  R when<R>({@required R Function(UpdateItems) updateItems}) {
    assert(() {
      if (updateItems == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _LastSearchedEvent.UpdateItems:
        return updateItems(this as UpdateItems);
    }
  }

//ignore: missing_return
  Future<R> asyncWhen<R>(
      {@required FutureOr<R> Function(UpdateItems) updateItems}) {
    assert(() {
      if (updateItems == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _LastSearchedEvent.UpdateItems:
        return updateItems(this as UpdateItems);
    }
  }

  R whenOrElse<R>(
      {R Function(UpdateItems) updateItems,
      @required R Function(LastSearchedEvent) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _LastSearchedEvent.UpdateItems:
        if (updateItems == null) break;
        return updateItems(this as UpdateItems);
    }
    return orElse(this);
  }

  Future<R> asyncWhenOrElse<R>(
      {FutureOr<R> Function(UpdateItems) updateItems,
      @required FutureOr<R> Function(LastSearchedEvent) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _LastSearchedEvent.UpdateItems:
        if (updateItems == null) break;
        return updateItems(this as UpdateItems);
    }
    return orElse(this);
  }

//ignore: missing_return
  Future<void> whenPartial({FutureOr<void> Function(UpdateItems) updateItems}) {
    assert(() {
      if (updateItems == null) {
        throw 'provide at least one branch';
      }
      return true;
    }());
    switch (this._type) {
      case _LastSearchedEvent.UpdateItems:
        if (updateItems == null) break;
        return updateItems(this as UpdateItems);
    }
  }

  @override
  List get props => const [];
}

@immutable
class UpdateItems extends LastSearchedEvent {
  const UpdateItems({@required this.items})
      : super(_LastSearchedEvent.UpdateItems);

  final List<dynamic> items;

  @override
  String toString() => 'UpdateItems(items:${this.items})';
  @override
  List get props => [items];
}

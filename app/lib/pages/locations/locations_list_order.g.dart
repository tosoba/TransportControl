// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locations_list_order.dart';

// **************************************************************************
// SuperEnumGenerator
// **************************************************************************

@immutable
abstract class LocationsListOrder extends Equatable {
  const LocationsListOrder(this._type);

  factory LocationsListOrder.savedTimestamp(BySavedTimestamp bySavedTimestamp) =
      BySavedTimestampWrapper;

  factory LocationsListOrder.lastSearched(ByLastSearched byLastSearched) =
      ByLastSearchedWrapper;

  factory LocationsListOrder.timesSearched(ByTimesSearched byTimesSearched) =
      ByTimesSearchedWrapper;

  final _LocationsListOrder _type;

//ignore: missing_return
  R when<R>(
      {@required R Function(BySavedTimestamp) savedTimestamp,
      @required R Function(ByLastSearched) lastSearched,
      @required R Function(ByTimesSearched) timesSearched}) {
    assert(() {
      if (savedTimestamp == null ||
          lastSearched == null ||
          timesSearched == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _LocationsListOrder.SavedTimestamp:
        return savedTimestamp(
            (this as BySavedTimestampWrapper).bySavedTimestamp);
      case _LocationsListOrder.LastSearched:
        return lastSearched((this as ByLastSearchedWrapper).byLastSearched);
      case _LocationsListOrder.TimesSearched:
        return timesSearched((this as ByTimesSearchedWrapper).byTimesSearched);
    }
  }

//ignore: missing_return
  Future<R> asyncWhen<R>(
      {@required FutureOr<R> Function(BySavedTimestamp) savedTimestamp,
      @required FutureOr<R> Function(ByLastSearched) lastSearched,
      @required FutureOr<R> Function(ByTimesSearched) timesSearched}) {
    assert(() {
      if (savedTimestamp == null ||
          lastSearched == null ||
          timesSearched == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _LocationsListOrder.SavedTimestamp:
        return savedTimestamp(
            (this as BySavedTimestampWrapper).bySavedTimestamp);
      case _LocationsListOrder.LastSearched:
        return lastSearched((this as ByLastSearchedWrapper).byLastSearched);
      case _LocationsListOrder.TimesSearched:
        return timesSearched((this as ByTimesSearchedWrapper).byTimesSearched);
    }
  }

  R whenOrElse<R>(
      {R Function(BySavedTimestamp) savedTimestamp,
      R Function(ByLastSearched) lastSearched,
      R Function(ByTimesSearched) timesSearched,
      @required R Function(LocationsListOrder) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _LocationsListOrder.SavedTimestamp:
        if (savedTimestamp == null) break;
        return savedTimestamp(
            (this as BySavedTimestampWrapper).bySavedTimestamp);
      case _LocationsListOrder.LastSearched:
        if (lastSearched == null) break;
        return lastSearched((this as ByLastSearchedWrapper).byLastSearched);
      case _LocationsListOrder.TimesSearched:
        if (timesSearched == null) break;
        return timesSearched((this as ByTimesSearchedWrapper).byTimesSearched);
    }
    return orElse(this);
  }

  Future<R> asyncWhenOrElse<R>(
      {FutureOr<R> Function(BySavedTimestamp) savedTimestamp,
      FutureOr<R> Function(ByLastSearched) lastSearched,
      FutureOr<R> Function(ByTimesSearched) timesSearched,
      @required FutureOr<R> Function(LocationsListOrder) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _LocationsListOrder.SavedTimestamp:
        if (savedTimestamp == null) break;
        return savedTimestamp(
            (this as BySavedTimestampWrapper).bySavedTimestamp);
      case _LocationsListOrder.LastSearched:
        if (lastSearched == null) break;
        return lastSearched((this as ByLastSearchedWrapper).byLastSearched);
      case _LocationsListOrder.TimesSearched:
        if (timesSearched == null) break;
        return timesSearched((this as ByTimesSearchedWrapper).byTimesSearched);
    }
    return orElse(this);
  }

//ignore: missing_return
  Future<void> whenPartial(
      {FutureOr<void> Function(BySavedTimestamp) savedTimestamp,
      FutureOr<void> Function(ByLastSearched) lastSearched,
      FutureOr<void> Function(ByTimesSearched) timesSearched}) {
    assert(() {
      if (savedTimestamp == null &&
          lastSearched == null &&
          timesSearched == null) {
        throw 'provide at least one branch';
      }
      return true;
    }());
    switch (this._type) {
      case _LocationsListOrder.SavedTimestamp:
        if (savedTimestamp == null) break;
        return savedTimestamp(
            (this as BySavedTimestampWrapper).bySavedTimestamp);
      case _LocationsListOrder.LastSearched:
        if (lastSearched == null) break;
        return lastSearched((this as ByLastSearchedWrapper).byLastSearched);
      case _LocationsListOrder.TimesSearched:
        if (timesSearched == null) break;
        return timesSearched((this as ByTimesSearchedWrapper).byTimesSearched);
    }
  }

  @override
  List get props => const [];
}

@immutable
class BySavedTimestampWrapper extends LocationsListOrder {
  const BySavedTimestampWrapper(this.bySavedTimestamp)
      : super(_LocationsListOrder.SavedTimestamp);

  final BySavedTimestamp bySavedTimestamp;

  @override
  String toString() => 'BySavedTimestampWrapper($bySavedTimestamp)';
  @override
  List get props => [bySavedTimestamp];
}

@immutable
class ByLastSearchedWrapper extends LocationsListOrder {
  const ByLastSearchedWrapper(this.byLastSearched)
      : super(_LocationsListOrder.LastSearched);

  final ByLastSearched byLastSearched;

  @override
  String toString() => 'ByLastSearchedWrapper($byLastSearched)';
  @override
  List get props => [byLastSearched];
}

@immutable
class ByTimesSearchedWrapper extends LocationsListOrder {
  const ByTimesSearchedWrapper(this.byTimesSearched)
      : super(_LocationsListOrder.TimesSearched);

  final ByTimesSearched byTimesSearched;

  @override
  String toString() => 'ByTimesSearchedWrapper($byTimesSearched)';
  @override
  List get props => [byTimesSearched];
}

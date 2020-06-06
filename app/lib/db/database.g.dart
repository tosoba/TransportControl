// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class Line extends DataClass implements Insertable<Line> {
  final String symbol;
  final String dest1;
  final String dest2;
  final int type;
  Line(
      {@required this.symbol,
      @required this.dest1,
      @required this.dest2,
      @required this.type});
  factory Line.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final stringType = db.typeSystem.forDartType<String>();
    final intType = db.typeSystem.forDartType<int>();
    return Line(
      symbol:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}symbol']),
      dest1:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}dest1']),
      dest2:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}dest2']),
      type: intType.mapFromDatabaseResponse(data['${effectivePrefix}type']),
    );
  }
  factory Line.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Line(
      symbol: serializer.fromJson<String>(json['symbol']),
      dest1: serializer.fromJson<String>(json['dest1']),
      dest2: serializer.fromJson<String>(json['dest2']),
      type: serializer.fromJson<int>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'symbol': serializer.toJson<String>(symbol),
      'dest1': serializer.toJson<String>(dest1),
      'dest2': serializer.toJson<String>(dest2),
      'type': serializer.toJson<int>(type),
    };
  }

  @override
  LinesCompanion createCompanion(bool nullToAbsent) {
    return LinesCompanion(
      symbol:
          symbol == null && nullToAbsent ? const Value.absent() : Value(symbol),
      dest1:
          dest1 == null && nullToAbsent ? const Value.absent() : Value(dest1),
      dest2:
          dest2 == null && nullToAbsent ? const Value.absent() : Value(dest2),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
    );
  }

  Line copyWith({String symbol, String dest1, String dest2, int type}) => Line(
        symbol: symbol ?? this.symbol,
        dest1: dest1 ?? this.dest1,
        dest2: dest2 ?? this.dest2,
        type: type ?? this.type,
      );
  @override
  String toString() {
    return (StringBuffer('Line(')
          ..write('symbol: $symbol, ')
          ..write('dest1: $dest1, ')
          ..write('dest2: $dest2, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(symbol.hashCode,
      $mrjc(dest1.hashCode, $mrjc(dest2.hashCode, type.hashCode))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Line &&
          other.symbol == this.symbol &&
          other.dest1 == this.dest1 &&
          other.dest2 == this.dest2 &&
          other.type == this.type);
}

class LinesCompanion extends UpdateCompanion<Line> {
  final Value<String> symbol;
  final Value<String> dest1;
  final Value<String> dest2;
  final Value<int> type;
  const LinesCompanion({
    this.symbol = const Value.absent(),
    this.dest1 = const Value.absent(),
    this.dest2 = const Value.absent(),
    this.type = const Value.absent(),
  });
  LinesCompanion.insert({
    @required String symbol,
    @required String dest1,
    @required String dest2,
    @required int type,
  })  : symbol = Value(symbol),
        dest1 = Value(dest1),
        dest2 = Value(dest2),
        type = Value(type);
  LinesCompanion copyWith(
      {Value<String> symbol,
      Value<String> dest1,
      Value<String> dest2,
      Value<int> type}) {
    return LinesCompanion(
      symbol: symbol ?? this.symbol,
      dest1: dest1 ?? this.dest1,
      dest2: dest2 ?? this.dest2,
      type: type ?? this.type,
    );
  }
}

class $LinesTable extends Lines with TableInfo<$LinesTable, Line> {
  final GeneratedDatabase _db;
  final String _alias;
  $LinesTable(this._db, [this._alias]);
  final VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  GeneratedTextColumn _symbol;
  @override
  GeneratedTextColumn get symbol => _symbol ??= _constructSymbol();
  GeneratedTextColumn _constructSymbol() {
    return GeneratedTextColumn(
      'symbol',
      $tableName,
      false,
    );
  }

  final VerificationMeta _dest1Meta = const VerificationMeta('dest1');
  GeneratedTextColumn _dest1;
  @override
  GeneratedTextColumn get dest1 => _dest1 ??= _constructDest1();
  GeneratedTextColumn _constructDest1() {
    return GeneratedTextColumn(
      'dest1',
      $tableName,
      false,
    );
  }

  final VerificationMeta _dest2Meta = const VerificationMeta('dest2');
  GeneratedTextColumn _dest2;
  @override
  GeneratedTextColumn get dest2 => _dest2 ??= _constructDest2();
  GeneratedTextColumn _constructDest2() {
    return GeneratedTextColumn(
      'dest2',
      $tableName,
      false,
    );
  }

  final VerificationMeta _typeMeta = const VerificationMeta('type');
  GeneratedIntColumn _type;
  @override
  GeneratedIntColumn get type => _type ??= _constructType();
  GeneratedIntColumn _constructType() {
    return GeneratedIntColumn(
      'type',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [symbol, dest1, dest2, type];
  @override
  $LinesTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'lines';
  @override
  final String actualTableName = 'lines';
  @override
  VerificationContext validateIntegrity(LinesCompanion d,
      {bool isInserting = false}) {
    final context = VerificationContext();
    if (d.symbol.present) {
      context.handle(
          _symbolMeta, symbol.isAcceptableValue(d.symbol.value, _symbolMeta));
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (d.dest1.present) {
      context.handle(
          _dest1Meta, dest1.isAcceptableValue(d.dest1.value, _dest1Meta));
    } else if (isInserting) {
      context.missing(_dest1Meta);
    }
    if (d.dest2.present) {
      context.handle(
          _dest2Meta, dest2.isAcceptableValue(d.dest2.value, _dest2Meta));
    } else if (isInserting) {
      context.missing(_dest2Meta);
    }
    if (d.type.present) {
      context.handle(
          _typeMeta, type.isAcceptableValue(d.type.value, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {symbol};
  @override
  Line map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return Line.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  Map<String, Variable> entityToSql(LinesCompanion d) {
    final map = <String, Variable>{};
    if (d.symbol.present) {
      map['symbol'] = Variable<String, StringType>(d.symbol.value);
    }
    if (d.dest1.present) {
      map['dest1'] = Variable<String, StringType>(d.dest1.value);
    }
    if (d.dest2.present) {
      map['dest2'] = Variable<String, StringType>(d.dest2.value);
    }
    if (d.type.present) {
      map['type'] = Variable<int, IntType>(d.type.value);
    }
    return map;
  }

  @override
  $LinesTable createAlias(String alias) {
    return $LinesTable(_db, alias);
  }
}

class Location extends DataClass implements Insertable<Location> {
  final int id;
  final String name;
  final double southWestLat;
  final double southWestLng;
  final double northEastLat;
  final double northEastLng;
  final bool isFavourite;
  final DateTime lastSearched;
  final int timesSearched;
  final DateTime savedAt;
  Location(
      {@required this.id,
      @required this.name,
      @required this.southWestLat,
      @required this.southWestLng,
      @required this.northEastLat,
      @required this.northEastLng,
      @required this.isFavourite,
      this.lastSearched,
      @required this.timesSearched,
      @required this.savedAt});
  factory Location.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    final doubleType = db.typeSystem.forDartType<double>();
    final boolType = db.typeSystem.forDartType<bool>();
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    return Location(
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      name: stringType.mapFromDatabaseResponse(data['${effectivePrefix}name']),
      southWestLat: doubleType
          .mapFromDatabaseResponse(data['${effectivePrefix}south_west_lat']),
      southWestLng: doubleType
          .mapFromDatabaseResponse(data['${effectivePrefix}south_west_lng']),
      northEastLat: doubleType
          .mapFromDatabaseResponse(data['${effectivePrefix}north_east_lat']),
      northEastLng: doubleType
          .mapFromDatabaseResponse(data['${effectivePrefix}north_east_lng']),
      isFavourite: boolType
          .mapFromDatabaseResponse(data['${effectivePrefix}is_favourite']),
      lastSearched: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}last_searched']),
      timesSearched: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}times_searched']),
      savedAt: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}saved_at']),
    );
  }
  factory Location.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Location(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      southWestLat: serializer.fromJson<double>(json['southWestLat']),
      southWestLng: serializer.fromJson<double>(json['southWestLng']),
      northEastLat: serializer.fromJson<double>(json['northEastLat']),
      northEastLng: serializer.fromJson<double>(json['northEastLng']),
      isFavourite: serializer.fromJson<bool>(json['isFavourite']),
      lastSearched: serializer.fromJson<DateTime>(json['lastSearched']),
      timesSearched: serializer.fromJson<int>(json['timesSearched']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'southWestLat': serializer.toJson<double>(southWestLat),
      'southWestLng': serializer.toJson<double>(southWestLng),
      'northEastLat': serializer.toJson<double>(northEastLat),
      'northEastLng': serializer.toJson<double>(northEastLng),
      'isFavourite': serializer.toJson<bool>(isFavourite),
      'lastSearched': serializer.toJson<DateTime>(lastSearched),
      'timesSearched': serializer.toJson<int>(timesSearched),
      'savedAt': serializer.toJson<DateTime>(savedAt),
    };
  }

  @override
  LocationsCompanion createCompanion(bool nullToAbsent) {
    return LocationsCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      southWestLat: southWestLat == null && nullToAbsent
          ? const Value.absent()
          : Value(southWestLat),
      southWestLng: southWestLng == null && nullToAbsent
          ? const Value.absent()
          : Value(southWestLng),
      northEastLat: northEastLat == null && nullToAbsent
          ? const Value.absent()
          : Value(northEastLat),
      northEastLng: northEastLng == null && nullToAbsent
          ? const Value.absent()
          : Value(northEastLng),
      isFavourite: isFavourite == null && nullToAbsent
          ? const Value.absent()
          : Value(isFavourite),
      lastSearched: lastSearched == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSearched),
      timesSearched: timesSearched == null && nullToAbsent
          ? const Value.absent()
          : Value(timesSearched),
      savedAt: savedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(savedAt),
    );
  }

  Location copyWith(
          {int id,
          String name,
          double southWestLat,
          double southWestLng,
          double northEastLat,
          double northEastLng,
          bool isFavourite,
          DateTime lastSearched,
          int timesSearched,
          DateTime savedAt}) =>
      Location(
        id: id ?? this.id,
        name: name ?? this.name,
        southWestLat: southWestLat ?? this.southWestLat,
        southWestLng: southWestLng ?? this.southWestLng,
        northEastLat: northEastLat ?? this.northEastLat,
        northEastLng: northEastLng ?? this.northEastLng,
        isFavourite: isFavourite ?? this.isFavourite,
        lastSearched: lastSearched ?? this.lastSearched,
        timesSearched: timesSearched ?? this.timesSearched,
        savedAt: savedAt ?? this.savedAt,
      );
  @override
  String toString() {
    return (StringBuffer('Location(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('southWestLat: $southWestLat, ')
          ..write('southWestLng: $southWestLng, ')
          ..write('northEastLat: $northEastLat, ')
          ..write('northEastLng: $northEastLng, ')
          ..write('isFavourite: $isFavourite, ')
          ..write('lastSearched: $lastSearched, ')
          ..write('timesSearched: $timesSearched, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      id.hashCode,
      $mrjc(
          name.hashCode,
          $mrjc(
              southWestLat.hashCode,
              $mrjc(
                  southWestLng.hashCode,
                  $mrjc(
                      northEastLat.hashCode,
                      $mrjc(
                          northEastLng.hashCode,
                          $mrjc(
                              isFavourite.hashCode,
                              $mrjc(
                                  lastSearched.hashCode,
                                  $mrjc(timesSearched.hashCode,
                                      savedAt.hashCode))))))))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Location &&
          other.id == this.id &&
          other.name == this.name &&
          other.southWestLat == this.southWestLat &&
          other.southWestLng == this.southWestLng &&
          other.northEastLat == this.northEastLat &&
          other.northEastLng == this.northEastLng &&
          other.isFavourite == this.isFavourite &&
          other.lastSearched == this.lastSearched &&
          other.timesSearched == this.timesSearched &&
          other.savedAt == this.savedAt);
}

class LocationsCompanion extends UpdateCompanion<Location> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> southWestLat;
  final Value<double> southWestLng;
  final Value<double> northEastLat;
  final Value<double> northEastLng;
  final Value<bool> isFavourite;
  final Value<DateTime> lastSearched;
  final Value<int> timesSearched;
  final Value<DateTime> savedAt;
  const LocationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.southWestLat = const Value.absent(),
    this.southWestLng = const Value.absent(),
    this.northEastLat = const Value.absent(),
    this.northEastLng = const Value.absent(),
    this.isFavourite = const Value.absent(),
    this.lastSearched = const Value.absent(),
    this.timesSearched = const Value.absent(),
    this.savedAt = const Value.absent(),
  });
  LocationsCompanion.insert({
    this.id = const Value.absent(),
    @required String name,
    @required double southWestLat,
    @required double southWestLng,
    @required double northEastLat,
    @required double northEastLng,
    this.isFavourite = const Value.absent(),
    this.lastSearched = const Value.absent(),
    this.timesSearched = const Value.absent(),
    @required DateTime savedAt,
  })  : name = Value(name),
        southWestLat = Value(southWestLat),
        southWestLng = Value(southWestLng),
        northEastLat = Value(northEastLat),
        northEastLng = Value(northEastLng),
        savedAt = Value(savedAt);
  LocationsCompanion copyWith(
      {Value<int> id,
      Value<String> name,
      Value<double> southWestLat,
      Value<double> southWestLng,
      Value<double> northEastLat,
      Value<double> northEastLng,
      Value<bool> isFavourite,
      Value<DateTime> lastSearched,
      Value<int> timesSearched,
      Value<DateTime> savedAt}) {
    return LocationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      southWestLat: southWestLat ?? this.southWestLat,
      southWestLng: southWestLng ?? this.southWestLng,
      northEastLat: northEastLat ?? this.northEastLat,
      northEastLng: northEastLng ?? this.northEastLng,
      isFavourite: isFavourite ?? this.isFavourite,
      lastSearched: lastSearched ?? this.lastSearched,
      timesSearched: timesSearched ?? this.timesSearched,
      savedAt: savedAt ?? this.savedAt,
    );
  }
}

class $LocationsTable extends Locations
    with TableInfo<$LocationsTable, Location> {
  final GeneratedDatabase _db;
  final String _alias;
  $LocationsTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  GeneratedIntColumn _id;
  @override
  GeneratedIntColumn get id => _id ??= _constructId();
  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn('id', $tableName, false,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
  }

  final VerificationMeta _nameMeta = const VerificationMeta('name');
  GeneratedTextColumn _name;
  @override
  GeneratedTextColumn get name => _name ??= _constructName();
  GeneratedTextColumn _constructName() {
    return GeneratedTextColumn(
      'name',
      $tableName,
      false,
    );
  }

  final VerificationMeta _southWestLatMeta =
      const VerificationMeta('southWestLat');
  GeneratedRealColumn _southWestLat;
  @override
  GeneratedRealColumn get southWestLat =>
      _southWestLat ??= _constructSouthWestLat();
  GeneratedRealColumn _constructSouthWestLat() {
    return GeneratedRealColumn(
      'south_west_lat',
      $tableName,
      false,
    );
  }

  final VerificationMeta _southWestLngMeta =
      const VerificationMeta('southWestLng');
  GeneratedRealColumn _southWestLng;
  @override
  GeneratedRealColumn get southWestLng =>
      _southWestLng ??= _constructSouthWestLng();
  GeneratedRealColumn _constructSouthWestLng() {
    return GeneratedRealColumn(
      'south_west_lng',
      $tableName,
      false,
    );
  }

  final VerificationMeta _northEastLatMeta =
      const VerificationMeta('northEastLat');
  GeneratedRealColumn _northEastLat;
  @override
  GeneratedRealColumn get northEastLat =>
      _northEastLat ??= _constructNorthEastLat();
  GeneratedRealColumn _constructNorthEastLat() {
    return GeneratedRealColumn(
      'north_east_lat',
      $tableName,
      false,
    );
  }

  final VerificationMeta _northEastLngMeta =
      const VerificationMeta('northEastLng');
  GeneratedRealColumn _northEastLng;
  @override
  GeneratedRealColumn get northEastLng =>
      _northEastLng ??= _constructNorthEastLng();
  GeneratedRealColumn _constructNorthEastLng() {
    return GeneratedRealColumn(
      'north_east_lng',
      $tableName,
      false,
    );
  }

  final VerificationMeta _isFavouriteMeta =
      const VerificationMeta('isFavourite');
  GeneratedBoolColumn _isFavourite;
  @override
  GeneratedBoolColumn get isFavourite =>
      _isFavourite ??= _constructIsFavourite();
  GeneratedBoolColumn _constructIsFavourite() {
    return GeneratedBoolColumn('is_favourite', $tableName, false,
        defaultValue: const Constant(false));
  }

  final VerificationMeta _lastSearchedMeta =
      const VerificationMeta('lastSearched');
  GeneratedDateTimeColumn _lastSearched;
  @override
  GeneratedDateTimeColumn get lastSearched =>
      _lastSearched ??= _constructLastSearched();
  GeneratedDateTimeColumn _constructLastSearched() {
    return GeneratedDateTimeColumn(
      'last_searched',
      $tableName,
      true,
    );
  }

  final VerificationMeta _timesSearchedMeta =
      const VerificationMeta('timesSearched');
  GeneratedIntColumn _timesSearched;
  @override
  GeneratedIntColumn get timesSearched =>
      _timesSearched ??= _constructTimesSearched();
  GeneratedIntColumn _constructTimesSearched() {
    return GeneratedIntColumn('times_searched', $tableName, false,
        defaultValue: const Constant(1));
  }

  final VerificationMeta _savedAtMeta = const VerificationMeta('savedAt');
  GeneratedDateTimeColumn _savedAt;
  @override
  GeneratedDateTimeColumn get savedAt => _savedAt ??= _constructSavedAt();
  GeneratedDateTimeColumn _constructSavedAt() {
    return GeneratedDateTimeColumn(
      'saved_at',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        southWestLat,
        southWestLng,
        northEastLat,
        northEastLng,
        isFavourite,
        lastSearched,
        timesSearched,
        savedAt
      ];
  @override
  $LocationsTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'locations';
  @override
  final String actualTableName = 'locations';
  @override
  VerificationContext validateIntegrity(LocationsCompanion d,
      {bool isInserting = false}) {
    final context = VerificationContext();
    if (d.id.present) {
      context.handle(_idMeta, id.isAcceptableValue(d.id.value, _idMeta));
    }
    if (d.name.present) {
      context.handle(
          _nameMeta, name.isAcceptableValue(d.name.value, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (d.southWestLat.present) {
      context.handle(
          _southWestLatMeta,
          southWestLat.isAcceptableValue(
              d.southWestLat.value, _southWestLatMeta));
    } else if (isInserting) {
      context.missing(_southWestLatMeta);
    }
    if (d.southWestLng.present) {
      context.handle(
          _southWestLngMeta,
          southWestLng.isAcceptableValue(
              d.southWestLng.value, _southWestLngMeta));
    } else if (isInserting) {
      context.missing(_southWestLngMeta);
    }
    if (d.northEastLat.present) {
      context.handle(
          _northEastLatMeta,
          northEastLat.isAcceptableValue(
              d.northEastLat.value, _northEastLatMeta));
    } else if (isInserting) {
      context.missing(_northEastLatMeta);
    }
    if (d.northEastLng.present) {
      context.handle(
          _northEastLngMeta,
          northEastLng.isAcceptableValue(
              d.northEastLng.value, _northEastLngMeta));
    } else if (isInserting) {
      context.missing(_northEastLngMeta);
    }
    if (d.isFavourite.present) {
      context.handle(_isFavouriteMeta,
          isFavourite.isAcceptableValue(d.isFavourite.value, _isFavouriteMeta));
    }
    if (d.lastSearched.present) {
      context.handle(
          _lastSearchedMeta,
          lastSearched.isAcceptableValue(
              d.lastSearched.value, _lastSearchedMeta));
    }
    if (d.timesSearched.present) {
      context.handle(
          _timesSearchedMeta,
          timesSearched.isAcceptableValue(
              d.timesSearched.value, _timesSearchedMeta));
    }
    if (d.savedAt.present) {
      context.handle(_savedAtMeta,
          savedAt.isAcceptableValue(d.savedAt.value, _savedAtMeta));
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Location map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return Location.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  Map<String, Variable> entityToSql(LocationsCompanion d) {
    final map = <String, Variable>{};
    if (d.id.present) {
      map['id'] = Variable<int, IntType>(d.id.value);
    }
    if (d.name.present) {
      map['name'] = Variable<String, StringType>(d.name.value);
    }
    if (d.southWestLat.present) {
      map['south_west_lat'] = Variable<double, RealType>(d.southWestLat.value);
    }
    if (d.southWestLng.present) {
      map['south_west_lng'] = Variable<double, RealType>(d.southWestLng.value);
    }
    if (d.northEastLat.present) {
      map['north_east_lat'] = Variable<double, RealType>(d.northEastLat.value);
    }
    if (d.northEastLng.present) {
      map['north_east_lng'] = Variable<double, RealType>(d.northEastLng.value);
    }
    if (d.isFavourite.present) {
      map['is_favourite'] = Variable<bool, BoolType>(d.isFavourite.value);
    }
    if (d.lastSearched.present) {
      map['last_searched'] =
          Variable<DateTime, DateTimeType>(d.lastSearched.value);
    }
    if (d.timesSearched.present) {
      map['times_searched'] = Variable<int, IntType>(d.timesSearched.value);
    }
    if (d.savedAt.present) {
      map['saved_at'] = Variable<DateTime, DateTimeType>(d.savedAt.value);
    }
    return map;
  }

  @override
  $LocationsTable createAlias(String alias) {
    return $LocationsTable(_db, alias);
  }
}

class PlaceQuery extends DataClass implements Insertable<PlaceQuery> {
  final String query;
  PlaceQuery({@required this.query});
  factory PlaceQuery.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final stringType = db.typeSystem.forDartType<String>();
    return PlaceQuery(
      query:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}query']),
    );
  }
  factory PlaceQuery.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return PlaceQuery(
      query: serializer.fromJson<String>(json['query']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'query': serializer.toJson<String>(query),
    };
  }

  @override
  PlaceQueriesCompanion createCompanion(bool nullToAbsent) {
    return PlaceQueriesCompanion(
      query:
          query == null && nullToAbsent ? const Value.absent() : Value(query),
    );
  }

  PlaceQuery copyWith({String query}) => PlaceQuery(
        query: query ?? this.query,
      );
  @override
  String toString() {
    return (StringBuffer('PlaceQuery(')..write('query: $query')..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf(query.hashCode);
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is PlaceQuery && other.query == this.query);
}

class PlaceQueriesCompanion extends UpdateCompanion<PlaceQuery> {
  final Value<String> query;
  const PlaceQueriesCompanion({
    this.query = const Value.absent(),
  });
  PlaceQueriesCompanion.insert({
    @required String query,
  }) : query = Value(query);
  PlaceQueriesCompanion copyWith({Value<String> query}) {
    return PlaceQueriesCompanion(
      query: query ?? this.query,
    );
  }
}

class $PlaceQueriesTable extends PlaceQueries
    with TableInfo<$PlaceQueriesTable, PlaceQuery> {
  final GeneratedDatabase _db;
  final String _alias;
  $PlaceQueriesTable(this._db, [this._alias]);
  final VerificationMeta _queryMeta = const VerificationMeta('query');
  GeneratedTextColumn _query;
  @override
  GeneratedTextColumn get query => _query ??= _constructQuery();
  GeneratedTextColumn _constructQuery() {
    return GeneratedTextColumn(
      'query',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [query];
  @override
  $PlaceQueriesTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'place_queries';
  @override
  final String actualTableName = 'place_queries';
  @override
  VerificationContext validateIntegrity(PlaceQueriesCompanion d,
      {bool isInserting = false}) {
    final context = VerificationContext();
    if (d.query.present) {
      context.handle(
          _queryMeta, query.isAcceptableValue(d.query.value, _queryMeta));
    } else if (isInserting) {
      context.missing(_queryMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {query};
  @override
  PlaceQuery map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return PlaceQuery.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  Map<String, Variable> entityToSql(PlaceQueriesCompanion d) {
    final map = <String, Variable>{};
    if (d.query.present) {
      map['query'] = Variable<String, StringType>(d.query.value);
    }
    return map;
  }

  @override
  $PlaceQueriesTable createAlias(String alias) {
    return $PlaceQueriesTable(_db, alias);
  }
}

class PlaceSuggestion extends DataClass implements Insertable<PlaceSuggestion> {
  final String id;
  final String title;
  final String address;
  final DateTime lastSearched;
  PlaceSuggestion(
      {@required this.id,
      @required this.title,
      this.address,
      this.lastSearched});
  factory PlaceSuggestion.fromData(
      Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final stringType = db.typeSystem.forDartType<String>();
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    return PlaceSuggestion(
      id: stringType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      title:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}title']),
      address:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}address']),
      lastSearched: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}last_searched']),
    );
  }
  factory PlaceSuggestion.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return PlaceSuggestion(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      address: serializer.fromJson<String>(json['address']),
      lastSearched: serializer.fromJson<DateTime>(json['lastSearched']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'address': serializer.toJson<String>(address),
      'lastSearched': serializer.toJson<DateTime>(lastSearched),
    };
  }

  @override
  PlaceSuggestionsCompanion createCompanion(bool nullToAbsent) {
    return PlaceSuggestionsCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      lastSearched: lastSearched == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSearched),
    );
  }

  PlaceSuggestion copyWith(
          {String id, String title, String address, DateTime lastSearched}) =>
      PlaceSuggestion(
        id: id ?? this.id,
        title: title ?? this.title,
        address: address ?? this.address,
        lastSearched: lastSearched ?? this.lastSearched,
      );
  @override
  String toString() {
    return (StringBuffer('PlaceSuggestion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('address: $address, ')
          ..write('lastSearched: $lastSearched')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(id.hashCode,
      $mrjc(title.hashCode, $mrjc(address.hashCode, lastSearched.hashCode))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is PlaceSuggestion &&
          other.id == this.id &&
          other.title == this.title &&
          other.address == this.address &&
          other.lastSearched == this.lastSearched);
}

class PlaceSuggestionsCompanion extends UpdateCompanion<PlaceSuggestion> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> address;
  final Value<DateTime> lastSearched;
  const PlaceSuggestionsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.address = const Value.absent(),
    this.lastSearched = const Value.absent(),
  });
  PlaceSuggestionsCompanion.insert({
    @required String id,
    @required String title,
    this.address = const Value.absent(),
    this.lastSearched = const Value.absent(),
  })  : id = Value(id),
        title = Value(title);
  PlaceSuggestionsCompanion copyWith(
      {Value<String> id,
      Value<String> title,
      Value<String> address,
      Value<DateTime> lastSearched}) {
    return PlaceSuggestionsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      address: address ?? this.address,
      lastSearched: lastSearched ?? this.lastSearched,
    );
  }
}

class $PlaceSuggestionsTable extends PlaceSuggestions
    with TableInfo<$PlaceSuggestionsTable, PlaceSuggestion> {
  final GeneratedDatabase _db;
  final String _alias;
  $PlaceSuggestionsTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  GeneratedTextColumn _id;
  @override
  GeneratedTextColumn get id => _id ??= _constructId();
  GeneratedTextColumn _constructId() {
    return GeneratedTextColumn(
      'id',
      $tableName,
      false,
    );
  }

  final VerificationMeta _titleMeta = const VerificationMeta('title');
  GeneratedTextColumn _title;
  @override
  GeneratedTextColumn get title => _title ??= _constructTitle();
  GeneratedTextColumn _constructTitle() {
    return GeneratedTextColumn(
      'title',
      $tableName,
      false,
    );
  }

  final VerificationMeta _addressMeta = const VerificationMeta('address');
  GeneratedTextColumn _address;
  @override
  GeneratedTextColumn get address => _address ??= _constructAddress();
  GeneratedTextColumn _constructAddress() {
    return GeneratedTextColumn(
      'address',
      $tableName,
      true,
    );
  }

  final VerificationMeta _lastSearchedMeta =
      const VerificationMeta('lastSearched');
  GeneratedDateTimeColumn _lastSearched;
  @override
  GeneratedDateTimeColumn get lastSearched =>
      _lastSearched ??= _constructLastSearched();
  GeneratedDateTimeColumn _constructLastSearched() {
    return GeneratedDateTimeColumn(
      'last_searched',
      $tableName,
      true,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [id, title, address, lastSearched];
  @override
  $PlaceSuggestionsTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'place_suggestions';
  @override
  final String actualTableName = 'place_suggestions';
  @override
  VerificationContext validateIntegrity(PlaceSuggestionsCompanion d,
      {bool isInserting = false}) {
    final context = VerificationContext();
    if (d.id.present) {
      context.handle(_idMeta, id.isAcceptableValue(d.id.value, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (d.title.present) {
      context.handle(
          _titleMeta, title.isAcceptableValue(d.title.value, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (d.address.present) {
      context.handle(_addressMeta,
          address.isAcceptableValue(d.address.value, _addressMeta));
    }
    if (d.lastSearched.present) {
      context.handle(
          _lastSearchedMeta,
          lastSearched.isAcceptableValue(
              d.lastSearched.value, _lastSearchedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaceSuggestion map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return PlaceSuggestion.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  Map<String, Variable> entityToSql(PlaceSuggestionsCompanion d) {
    final map = <String, Variable>{};
    if (d.id.present) {
      map['id'] = Variable<String, StringType>(d.id.value);
    }
    if (d.title.present) {
      map['title'] = Variable<String, StringType>(d.title.value);
    }
    if (d.address.present) {
      map['address'] = Variable<String, StringType>(d.address.value);
    }
    if (d.lastSearched.present) {
      map['last_searched'] =
          Variable<DateTime, DateTimeType>(d.lastSearched.value);
    }
    return map;
  }

  @override
  $PlaceSuggestionsTable createAlias(String alias) {
    return $PlaceSuggestionsTable(_db, alias);
  }
}

class PlaceQuerySuggestion extends DataClass
    implements Insertable<PlaceQuerySuggestion> {
  final String query;
  final String locationId;
  PlaceQuerySuggestion({@required this.query, @required this.locationId});
  factory PlaceQuerySuggestion.fromData(
      Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final stringType = db.typeSystem.forDartType<String>();
    return PlaceQuerySuggestion(
      query:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}query']),
      locationId: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}location_id']),
    );
  }
  factory PlaceQuerySuggestion.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return PlaceQuerySuggestion(
      query: serializer.fromJson<String>(json['query']),
      locationId: serializer.fromJson<String>(json['locationId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'query': serializer.toJson<String>(query),
      'locationId': serializer.toJson<String>(locationId),
    };
  }

  @override
  PlaceQuerySuggestionsCompanion createCompanion(bool nullToAbsent) {
    return PlaceQuerySuggestionsCompanion(
      query:
          query == null && nullToAbsent ? const Value.absent() : Value(query),
      locationId: locationId == null && nullToAbsent
          ? const Value.absent()
          : Value(locationId),
    );
  }

  PlaceQuerySuggestion copyWith({String query, String locationId}) =>
      PlaceQuerySuggestion(
        query: query ?? this.query,
        locationId: locationId ?? this.locationId,
      );
  @override
  String toString() {
    return (StringBuffer('PlaceQuerySuggestion(')
          ..write('query: $query, ')
          ..write('locationId: $locationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(query.hashCode, locationId.hashCode));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is PlaceQuerySuggestion &&
          other.query == this.query &&
          other.locationId == this.locationId);
}

class PlaceQuerySuggestionsCompanion
    extends UpdateCompanion<PlaceQuerySuggestion> {
  final Value<String> query;
  final Value<String> locationId;
  const PlaceQuerySuggestionsCompanion({
    this.query = const Value.absent(),
    this.locationId = const Value.absent(),
  });
  PlaceQuerySuggestionsCompanion.insert({
    @required String query,
    @required String locationId,
  })  : query = Value(query),
        locationId = Value(locationId);
  PlaceQuerySuggestionsCompanion copyWith(
      {Value<String> query, Value<String> locationId}) {
    return PlaceQuerySuggestionsCompanion(
      query: query ?? this.query,
      locationId: locationId ?? this.locationId,
    );
  }
}

class $PlaceQuerySuggestionsTable extends PlaceQuerySuggestions
    with TableInfo<$PlaceQuerySuggestionsTable, PlaceQuerySuggestion> {
  final GeneratedDatabase _db;
  final String _alias;
  $PlaceQuerySuggestionsTable(this._db, [this._alias]);
  final VerificationMeta _queryMeta = const VerificationMeta('query');
  GeneratedTextColumn _query;
  @override
  GeneratedTextColumn get query => _query ??= _constructQuery();
  GeneratedTextColumn _constructQuery() {
    return GeneratedTextColumn(
      'query',
      $tableName,
      false,
    );
  }

  final VerificationMeta _locationIdMeta = const VerificationMeta('locationId');
  GeneratedTextColumn _locationId;
  @override
  GeneratedTextColumn get locationId => _locationId ??= _constructLocationId();
  GeneratedTextColumn _constructLocationId() {
    return GeneratedTextColumn(
      'location_id',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [query, locationId];
  @override
  $PlaceQuerySuggestionsTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'place_query_suggestions';
  @override
  final String actualTableName = 'place_query_suggestions';
  @override
  VerificationContext validateIntegrity(PlaceQuerySuggestionsCompanion d,
      {bool isInserting = false}) {
    final context = VerificationContext();
    if (d.query.present) {
      context.handle(
          _queryMeta, query.isAcceptableValue(d.query.value, _queryMeta));
    } else if (isInserting) {
      context.missing(_queryMeta);
    }
    if (d.locationId.present) {
      context.handle(_locationIdMeta,
          locationId.isAcceptableValue(d.locationId.value, _locationIdMeta));
    } else if (isInserting) {
      context.missing(_locationIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {query, locationId};
  @override
  PlaceQuerySuggestion map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return PlaceQuerySuggestion.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  Map<String, Variable> entityToSql(PlaceQuerySuggestionsCompanion d) {
    final map = <String, Variable>{};
    if (d.query.present) {
      map['query'] = Variable<String, StringType>(d.query.value);
    }
    if (d.locationId.present) {
      map['location_id'] = Variable<String, StringType>(d.locationId.value);
    }
    return map;
  }

  @override
  $PlaceQuerySuggestionsTable createAlias(String alias) {
    return $PlaceQuerySuggestionsTable(_db, alias);
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  $LinesTable _lines;
  $LinesTable get lines => _lines ??= $LinesTable(this);
  $LocationsTable _locations;
  $LocationsTable get locations => _locations ??= $LocationsTable(this);
  $PlaceQueriesTable _placeQueries;
  $PlaceQueriesTable get placeQueries =>
      _placeQueries ??= $PlaceQueriesTable(this);
  $PlaceSuggestionsTable _placeSuggestions;
  $PlaceSuggestionsTable get placeSuggestions =>
      _placeSuggestions ??= $PlaceSuggestionsTable(this);
  $PlaceQuerySuggestionsTable _placeQuerySuggestions;
  $PlaceQuerySuggestionsTable get placeQuerySuggestions =>
      _placeQuerySuggestions ??= $PlaceQuerySuggestionsTable(this);
  LinesDao _linesDao;
  LinesDao get linesDao => _linesDao ??= LinesDao(this as Database);
  LocationsDao _locationsDao;
  LocationsDao get locationsDao =>
      _locationsDao ??= LocationsDao(this as Database);
  PlacesDao _placesDao;
  PlacesDao get placesDao => _placesDao ??= PlacesDao(this as Database);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [lines, locations, placeQueries, placeSuggestions, placeQuerySuggestions];
}

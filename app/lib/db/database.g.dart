// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class FavouriteLine extends DataClass implements Insertable<FavouriteLine> {
  final String symbol;
  FavouriteLine({@required this.symbol});
  factory FavouriteLine.fromData(
      Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final stringType = db.typeSystem.forDartType<String>();
    return FavouriteLine(
      symbol:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}symbol']),
    );
  }
  factory FavouriteLine.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return FavouriteLine(
      symbol: serializer.fromJson<String>(json['symbol']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'symbol': serializer.toJson<String>(symbol),
    };
  }

  @override
  FavouriteLinesCompanion createCompanion(bool nullToAbsent) {
    return FavouriteLinesCompanion(
      symbol:
          symbol == null && nullToAbsent ? const Value.absent() : Value(symbol),
    );
  }

  FavouriteLine copyWith({String symbol}) => FavouriteLine(
        symbol: symbol ?? this.symbol,
      );
  @override
  String toString() {
    return (StringBuffer('FavouriteLine(')
          ..write('symbol: $symbol')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf(symbol.hashCode);
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is FavouriteLine && other.symbol == this.symbol);
}

class FavouriteLinesCompanion extends UpdateCompanion<FavouriteLine> {
  final Value<String> symbol;
  const FavouriteLinesCompanion({
    this.symbol = const Value.absent(),
  });
  FavouriteLinesCompanion.insert({
    @required String symbol,
  }) : symbol = Value(symbol);
  FavouriteLinesCompanion copyWith({Value<String> symbol}) {
    return FavouriteLinesCompanion(
      symbol: symbol ?? this.symbol,
    );
  }
}

class $FavouriteLinesTable extends FavouriteLines
    with TableInfo<$FavouriteLinesTable, FavouriteLine> {
  final GeneratedDatabase _db;
  final String _alias;
  $FavouriteLinesTable(this._db, [this._alias]);
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

  @override
  List<GeneratedColumn> get $columns => [symbol];
  @override
  $FavouriteLinesTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'favourite_lines';
  @override
  final String actualTableName = 'favourite_lines';
  @override
  VerificationContext validateIntegrity(FavouriteLinesCompanion d,
      {bool isInserting = false}) {
    final context = VerificationContext();
    if (d.symbol.present) {
      context.handle(
          _symbolMeta, symbol.isAcceptableValue(d.symbol.value, _symbolMeta));
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => <GeneratedColumn>{};
  @override
  FavouriteLine map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return FavouriteLine.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  Map<String, Variable> entityToSql(FavouriteLinesCompanion d) {
    final map = <String, Variable>{};
    if (d.symbol.present) {
      map['symbol'] = Variable<String, StringType>(d.symbol.value);
    }
    return map;
  }

  @override
  $FavouriteLinesTable createAlias(String alias) {
    return $FavouriteLinesTable(_db, alias);
  }
}

class FavouriteLocation extends DataClass
    implements Insertable<FavouriteLocation> {
  final int id;
  final String name;
  final double southWestLat;
  final double southWestLng;
  final double northEastLat;
  final double northEastLng;
  FavouriteLocation(
      {@required this.id,
      @required this.name,
      @required this.southWestLat,
      @required this.southWestLng,
      @required this.northEastLat,
      @required this.northEastLng});
  factory FavouriteLocation.fromData(
      Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    final doubleType = db.typeSystem.forDartType<double>();
    return FavouriteLocation(
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
    );
  }
  factory FavouriteLocation.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return FavouriteLocation(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      southWestLat: serializer.fromJson<double>(json['southWestLat']),
      southWestLng: serializer.fromJson<double>(json['southWestLng']),
      northEastLat: serializer.fromJson<double>(json['northEastLat']),
      northEastLng: serializer.fromJson<double>(json['northEastLng']),
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
    };
  }

  @override
  FavouriteLocationsCompanion createCompanion(bool nullToAbsent) {
    return FavouriteLocationsCompanion(
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
    );
  }

  FavouriteLocation copyWith(
          {int id,
          String name,
          double southWestLat,
          double southWestLng,
          double northEastLat,
          double northEastLng}) =>
      FavouriteLocation(
        id: id ?? this.id,
        name: name ?? this.name,
        southWestLat: southWestLat ?? this.southWestLat,
        southWestLng: southWestLng ?? this.southWestLng,
        northEastLat: northEastLat ?? this.northEastLat,
        northEastLng: northEastLng ?? this.northEastLng,
      );
  @override
  String toString() {
    return (StringBuffer('FavouriteLocation(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('southWestLat: $southWestLat, ')
          ..write('southWestLng: $southWestLng, ')
          ..write('northEastLat: $northEastLat, ')
          ..write('northEastLng: $northEastLng')
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
              $mrjc(southWestLng.hashCode,
                  $mrjc(northEastLat.hashCode, northEastLng.hashCode))))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is FavouriteLocation &&
          other.id == this.id &&
          other.name == this.name &&
          other.southWestLat == this.southWestLat &&
          other.southWestLng == this.southWestLng &&
          other.northEastLat == this.northEastLat &&
          other.northEastLng == this.northEastLng);
}

class FavouriteLocationsCompanion extends UpdateCompanion<FavouriteLocation> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> southWestLat;
  final Value<double> southWestLng;
  final Value<double> northEastLat;
  final Value<double> northEastLng;
  const FavouriteLocationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.southWestLat = const Value.absent(),
    this.southWestLng = const Value.absent(),
    this.northEastLat = const Value.absent(),
    this.northEastLng = const Value.absent(),
  });
  FavouriteLocationsCompanion.insert({
    this.id = const Value.absent(),
    @required String name,
    @required double southWestLat,
    @required double southWestLng,
    @required double northEastLat,
    @required double northEastLng,
  })  : name = Value(name),
        southWestLat = Value(southWestLat),
        southWestLng = Value(southWestLng),
        northEastLat = Value(northEastLat),
        northEastLng = Value(northEastLng);
  FavouriteLocationsCompanion copyWith(
      {Value<int> id,
      Value<String> name,
      Value<double> southWestLat,
      Value<double> southWestLng,
      Value<double> northEastLat,
      Value<double> northEastLng}) {
    return FavouriteLocationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      southWestLat: southWestLat ?? this.southWestLat,
      southWestLng: southWestLng ?? this.southWestLng,
      northEastLat: northEastLat ?? this.northEastLat,
      northEastLng: northEastLng ?? this.northEastLng,
    );
  }
}

class $FavouriteLocationsTable extends FavouriteLocations
    with TableInfo<$FavouriteLocationsTable, FavouriteLocation> {
  final GeneratedDatabase _db;
  final String _alias;
  $FavouriteLocationsTable(this._db, [this._alias]);
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

  @override
  List<GeneratedColumn> get $columns =>
      [id, name, southWestLat, southWestLng, northEastLat, northEastLng];
  @override
  $FavouriteLocationsTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'favourite_locations';
  @override
  final String actualTableName = 'favourite_locations';
  @override
  VerificationContext validateIntegrity(FavouriteLocationsCompanion d,
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FavouriteLocation map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return FavouriteLocation.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  Map<String, Variable> entityToSql(FavouriteLocationsCompanion d) {
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
    return map;
  }

  @override
  $FavouriteLocationsTable createAlias(String alias) {
    return $FavouriteLocationsTable(_db, alias);
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  $FavouriteLinesTable _favouriteLines;
  $FavouriteLinesTable get favouriteLines =>
      _favouriteLines ??= $FavouriteLinesTable(this);
  $FavouriteLocationsTable _favouriteLocations;
  $FavouriteLocationsTable get favouriteLocations =>
      _favouriteLocations ??= $FavouriteLocationsTable(this);
  FavouriteLinesDao _favouriteLinesDao;
  FavouriteLinesDao get favouriteLinesDao =>
      _favouriteLinesDao ??= FavouriteLinesDao(this as Database);
  FavouriteLocationsDao _favouriteLocationsDao;
  FavouriteLocationsDao get favouriteLocationsDao =>
      _favouriteLocationsDao ??= FavouriteLocationsDao(this as Database);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [favouriteLines, favouriteLocations];
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class FavouriteLine extends DataClass implements Insertable<FavouriteLine> {
  final String symbol;
  final String dest1;
  final String dest2;
  final int type;
  FavouriteLine(
      {@required this.symbol,
      @required this.dest1,
      @required this.dest2,
      @required this.type});
  factory FavouriteLine.fromData(
      Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final stringType = db.typeSystem.forDartType<String>();
    final intType = db.typeSystem.forDartType<int>();
    return FavouriteLine(
      symbol:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}symbol']),
      dest1:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}dest1']),
      dest2:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}dest2']),
      type: intType.mapFromDatabaseResponse(data['${effectivePrefix}type']),
    );
  }
  factory FavouriteLine.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return FavouriteLine(
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
  FavouriteLinesCompanion createCompanion(bool nullToAbsent) {
    return FavouriteLinesCompanion(
      symbol:
          symbol == null && nullToAbsent ? const Value.absent() : Value(symbol),
      dest1:
          dest1 == null && nullToAbsent ? const Value.absent() : Value(dest1),
      dest2:
          dest2 == null && nullToAbsent ? const Value.absent() : Value(dest2),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
    );
  }

  FavouriteLine copyWith(
          {String symbol, String dest1, String dest2, int type}) =>
      FavouriteLine(
        symbol: symbol ?? this.symbol,
        dest1: dest1 ?? this.dest1,
        dest2: dest2 ?? this.dest2,
        type: type ?? this.type,
      );
  @override
  String toString() {
    return (StringBuffer('FavouriteLine(')
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
      (other is FavouriteLine &&
          other.symbol == this.symbol &&
          other.dest1 == this.dest1 &&
          other.dest2 == this.dest2 &&
          other.type == this.type);
}

class FavouriteLinesCompanion extends UpdateCompanion<FavouriteLine> {
  final Value<String> symbol;
  final Value<String> dest1;
  final Value<String> dest2;
  final Value<int> type;
  const FavouriteLinesCompanion({
    this.symbol = const Value.absent(),
    this.dest1 = const Value.absent(),
    this.dest2 = const Value.absent(),
    this.type = const Value.absent(),
  });
  FavouriteLinesCompanion.insert({
    @required String symbol,
    @required String dest1,
    @required String dest2,
    @required int type,
  })  : symbol = Value(symbol),
        dest1 = Value(dest1),
        dest2 = Value(dest2),
        type = Value(type);
  FavouriteLinesCompanion copyWith(
      {Value<String> symbol,
      Value<String> dest1,
      Value<String> dest2,
      Value<int> type}) {
    return FavouriteLinesCompanion(
      symbol: symbol ?? this.symbol,
      dest1: dest1 ?? this.dest1,
      dest2: dest2 ?? this.dest2,
      type: type ?? this.type,
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

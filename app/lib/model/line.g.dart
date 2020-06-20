// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Line _$LineFromJson(Map<String, dynamic> json) {
  return Line(
    json['symbol'] as String,
    json['dest1'] as String,
    json['dest2'] as String,
    json['type'] as int,
    json['lastSearched'] == null
        ? null
        : DateTime.parse(json['lastSearched'] as String),
  );
}

Map<String, dynamic> _$LineToJson(Line instance) => <String, dynamic>{
      'symbol': instance.symbol,
      'dest1': instance.dest1,
      'dest2': instance.dest2,
      'type': instance.type,
      'lastSearched': instance.lastSearched?.toIso8601String(),
    };

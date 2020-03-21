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
  );
}

Map<String, dynamic> _$LineToJson(Line instance) => <String, dynamic>{
      'symbol': instance.symbol,
      'dest1': instance.dest1,
      'dest2': instance.dest2,
      'type': instance.type,
    };

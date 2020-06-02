// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapView _$MapViewFromJson(Map<String, dynamic> json) {
  return MapView(
    topLeft: json['TopLeft'] == null
        ? null
        : LatLng.fromJson(json['TopLeft'] as Map<String, dynamic>),
    bottomRight: json['BottomRight'] == null
        ? null
        : LatLng.fromJson(json['BottomRight'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$MapViewToJson(MapView instance) => <String, dynamic>{
      'TopLeft': instance.topLeft,
      'BottomRight': instance.bottomRight,
    };

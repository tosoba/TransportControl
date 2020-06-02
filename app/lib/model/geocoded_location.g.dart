// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geocoded_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeocodedLocation _$GeocodedLocationFromJson(Map<String, dynamic> json) {
  return GeocodedLocation(
    locationId: json['LocationId'] as String,
    locationType: json['LocationType'] as String,
    displayPosition: json['DisplayPosition'] == null
        ? null
        : LatLng.fromJson(json['DisplayPosition'] as Map<String, dynamic>),
    mapView: json['MapView'] == null
        ? null
        : MapView.fromJson(json['MapView'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$GeocodedLocationToJson(GeocodedLocation instance) =>
    <String, dynamic>{
      'LocationId': instance.locationId,
      'LocationType': instance.locationType,
      'DisplayPosition': instance.displayPosition,
      'MapView': instance.mapView,
    };

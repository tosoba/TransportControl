// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Address _$AddressFromJson(Map<String, dynamic> json) {
  return Address(
    label: json['label'] as String,
    countryCode: json['countryCode'] as String,
    countryName: json['countryName'] as String,
    state: json['state'] as String,
    county: json['county'] as String,
    city: json['city'] as String,
    district: json['district'] as String,
    street: json['street'] as String,
    houseNumber: json['houseNumber'] as String,
    postalCode: json['postalCode'] as String,
  );
}

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
      'label': instance.label,
      'countryCode': instance.countryCode,
      'countryName': instance.countryName,
      'state': instance.state,
      'county': instance.county,
      'city': instance.city,
      'district': instance.district,
      'street': instance.street,
      'postalCode': instance.postalCode,
      'houseNumber': instance.houseNumber,
    };

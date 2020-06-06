import 'package:json_annotation/json_annotation.dart';

part 'address.g.dart';

@JsonSerializable()
class Address {
  final String label;
  final String countryCode;
  final String countryName;
  final String state;
  final String county;
  final String city;
  final String district;
  final String street;
  final String postalCode;
  final String houseNumber;

  Address({
    this.label,
    this.countryCode,
    this.countryName,
    this.state,
    this.county,
    this.city,
    this.district,
    this.street,
    this.houseNumber,
    this.postalCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return _$AddressFromJson(json);
  }

  Map<String, dynamic> toJson() => _$AddressToJson(this);
}

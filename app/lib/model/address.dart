import 'package:json_annotation/json_annotation.dart';

part 'address.g.dart';

@JsonSerializable()
class Address {
  final String country;
  final String state;
  final String county;
  final String city;
  final String district;
  final String street;
  final String houseNumber;
  final String postalCode;

  Address({
    this.country,
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

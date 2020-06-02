import 'package:json_annotation/json_annotation.dart';
import 'package:transport_control/model/geocoding_response.dart';

part 'geocoding_response_wrapper.g.dart';

@JsonSerializable()
class GeocodingResponseWrapper {
  final GeocodingResponse response;

  GeocodingResponseWrapper({this.response});

  factory GeocodingResponseWrapper.fromJson(Map<String, dynamic> json) {
    return _$GeocodingResponseWrapperFromJson(json);
  }

  Map<String, dynamic> toJson() => _$GeocodingResponseWrapperToJson(this);
}

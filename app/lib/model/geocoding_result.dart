import 'package:json_annotation/json_annotation.dart';
import 'package:transport_control/model/geocoded_location.dart';

part 'geocoding_result.g.dart';

@JsonSerializable()
class GeocodingResult {
  @JsonKey(name: 'Location')
  final GeocodedLocation location;

  GeocodingResult({this.location});

  factory GeocodingResult.fromJson(Map<String, dynamic> json) {
    return _$GeocodingResultFromJson(json);
  }

  Map<String, dynamic> toJson() => _$GeocodingResultToJson(this);
}

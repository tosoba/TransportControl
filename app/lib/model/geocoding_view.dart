import 'package:json_annotation/json_annotation.dart';
import 'package:transport_control/model/geocoding_result.dart';

part 'geocoding_view.g.dart';

@JsonSerializable()
class GeocodingView {
  @JsonKey(name: 'Result')
  final List<GeocodingResult> results;

  GeocodingView({this.results});

  factory GeocodingView.fromJson(Map<String, dynamic> json) {
    return _$GeocodingViewFromJson(json);
  }

  Map<String, dynamic> toJson() => _$GeocodingViewToJson(this);
}

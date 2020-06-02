import 'package:json_annotation/json_annotation.dart';
import 'package:transport_control/model/lat_lng.dart';

part 'map_view.g.dart';

@JsonSerializable()
class MapView {
  @JsonKey(name: 'TopLeft')
  final LatLng topLeft;
  @JsonKey(name: 'BottomRight')
  final LatLng bottomRight;

  MapView({this.topLeft, this.bottomRight});

  factory MapView.fromJson(Map<String, dynamic> json) {
    return _$MapViewFromJson(json);
  }

  Map<String, dynamic> toJson() => _$MapViewToJson(this);
}

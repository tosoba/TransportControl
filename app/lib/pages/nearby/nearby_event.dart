import 'package:super_enum/super_enum.dart';
import 'package:transport_control/model/place_suggestion.dart';

part "nearby_event.g.dart";

@superEnum
enum _NearbyEvent {
  @Data(fields: [DataField<List<PlaceSuggestion>>('suggestions')])
  UpdateSuggestions,

  @Data(fields: [DataField<List<String>>('queries')])
  UpdateLatestQueries,
}

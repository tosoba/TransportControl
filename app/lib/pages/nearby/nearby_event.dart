import 'package:super_enum/super_enum.dart';
import 'package:transport_control/model/loadable.dart';
import 'package:transport_control/model/place_suggestion.dart';

part "nearby_event.g.dart";

@superEnum
enum _NearbyEvent {
  @Data(fields: [DataField<String>('query')])
  UpdateQuery,

  @Data(fields: [DataField<Loadable<List<PlaceSuggestion>>>('suggestions')])
  UpdateSuggestions,

  @Data(fields: [DataField<List<PlaceSuggestion>>('suggestions')])
  UpdateRecentlySearchedSuggestions,
}

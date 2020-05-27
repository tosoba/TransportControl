import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:super_enum/super_enum.dart';

part "map_signal.g.dart";

@superEnum
enum _MapSignal {
  @Data(fields: [DataField<String>('message')])
  Loading,

  @object
  LoadedSuccessfully,

  @Data(fields: [DataField<LatLngBounds>('bounds')])
  ZoomToBoundsAfterLoadedSuccessfully,

  @Data(fields: [
    DataField<String>('message'),
    DataField<void Function()>('retry')
  ])
  LoadingError,
}

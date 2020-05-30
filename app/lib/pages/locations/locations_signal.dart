import 'package:super_enum/super_enum.dart';

part "locations_signal.g.dart";

@superEnum
enum _LocationsSignal {
  @Data(fields: [DataField<String>('message')])
  Loading,

  @Data(fields: [DataField<String>('message')])
  LoadingError,

  @object
  LoadedSuccessfully,
}

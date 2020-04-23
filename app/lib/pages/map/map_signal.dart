import 'package:super_enum/super_enum.dart';

part "map_signal.g.dart";

@superEnum
enum _MapSignal {
  @Data(fields: [DataField<String>('message')])
  Loading,

  @object
  LoadedSuccessfully,

  @Data(fields: [DataField<String>('message')])
  LoadingError,
}

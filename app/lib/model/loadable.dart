import 'dart:developer';

import 'package:super_enum/super_enum.dart';

part "loadable.g.dart";

@superEnum
enum _Loadable {
  @object
  Loading,

  @generic
  @Data(fields: [DataField<Generic>('value')])
  Value,

  @Data(fields: [DataField<dynamic>('error')])
  Error,
}

extension ErrorExt<T> on Error<T> {
  void logError() => log(error?.toString() ?? 'Unknown error');
}

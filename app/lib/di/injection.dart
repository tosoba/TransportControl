import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:transport_control/di/injection.iconfig.dart';

@injectableInit
void configureInjection(String environment) =>
    $initGetIt(GetIt.instance, environment: environment);

abstract class Env {
  static const test = 'test';
  static const dev = 'dev';
  static const prod = 'prod';
}

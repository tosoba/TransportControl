// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:dio/dio.dart';
import 'package:transport_control/di/module/api_module.dart';
import 'package:transport_control/api/vehicles_api.dart';
import 'package:transport_control/repo/impl/vehicles_repo_impl.dart';
import 'package:transport_control/repo/vehicles_repo.dart';
import 'package:get_it/get_it.dart';

void $initGetIt(GetIt g, {String environment}) {
  final apiModule = _$ApiModule();

  //Eager singletons must be registered in the right order
  g.registerSingleton<Dio>(apiModule.client);
  g.registerSingleton<VehiclesApi>(VehiclesApi.create(
    g<Dio>(),
  ));
  if (environment == 'dev') {
    g.registerSingleton<VehiclesRepo>(VehiclesRepoImpl(
      g<VehiclesApi>(),
    ));
  }
}

class _$ApiModule extends ApiModule {}

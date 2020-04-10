// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:transport_control/db/database.dart';
import 'package:dio/dio.dart';
import 'package:transport_control/di/module/api_module.dart';
import 'package:transport_control/api/vehicles_api.dart';
import 'package:transport_control/db/dao/favourite_lines_dao.dart';
import 'package:transport_control/db/dao/favourite_locations_dao.dart';
import 'package:transport_control/repo/impl/lines_repo_impl.dart';
import 'package:transport_control/repo/lines_repo.dart';
import 'package:transport_control/repo/impl/vehicles_repo_impl.dart';
import 'package:transport_control/repo/vehicles_repo.dart';
import 'package:get_it/get_it.dart';

void $initGetIt(GetIt g, {String environment}) {
  final apiModule = _$ApiModule();
  g.registerFactory<FavouriteLinesDao>(() => FavouriteLinesDao.of(
        g<Database>(),
      ));
  g.registerFactory<FavouriteLocationsDao>(() => FavouriteLocationsDao.of(
        g<Database>(),
      ));

  //Eager singletons must be registered in the right order
  g.registerSingleton<Database>(Database());
  g.registerSingleton<Dio>(apiModule.client);
  g.registerSingleton<VehiclesApi>(VehiclesApi.create(
    g<Dio>(),
  ));
  if (environment == 'dev') {
    g.registerSingleton<LinesRepo>(LinesRepoImpl(
      g<FavouriteLinesDao>(),
    ));
    g.registerSingleton<VehiclesRepo>(VehiclesRepoImpl(
      g<VehiclesApi>(),
    ));
  }
}

class _$ApiModule extends ApiModule {}

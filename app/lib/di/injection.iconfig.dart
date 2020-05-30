// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:transport_control/db/database.dart';
import 'package:dio/dio.dart';
import 'package:transport_control/di/module/api_module.dart';
import 'package:transport_control/di/module/controllers_module.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:transport_control/di/module/settings_module.dart';
import 'package:transport_control/api/places_api.dart';
import 'package:transport_control/api/vehicles_api.dart';
import 'package:transport_control/db/dao/lines_dao.dart';
import 'package:transport_control/db/dao/locations_dao.dart';
import 'package:transport_control/db/dao/places_dao.dart';
import 'package:transport_control/repo/impl/lines_repo_impl.dart';
import 'package:transport_control/repo/lines_repo.dart';
import 'package:transport_control/repo/impl/locations_repo_impl.dart';
import 'package:transport_control/repo/locations_repo.dart';
import 'package:transport_control/repo/impl/place_suggestions_repo_impl.dart';
import 'package:transport_control/repo/place_suggestions_repo.dart';
import 'package:transport_control/repo/impl/vehicles_repo_impl.dart';
import 'package:transport_control/repo/vehicles_repo.dart';
import 'package:get_it/get_it.dart';

void $initGetIt(GetIt g, {String environment}) {
  final apiModule = _$ApiModule();
  final controllersModule = _$ControllersModule();
  final settingsModule = _$SettingsModule();
  g.registerFactory<LinesDao>(() => LinesDao.of(
        g<Database>(),
      ));
  g.registerFactory<LocationsDao>(() => LocationsDao.of(
        g<Database>(),
      ));
  g.registerFactory<PlacesDao>(() => PlacesDao.of(
        g<Database>(),
      ));

  //Eager singletons must be registered in the right order
  g.registerSingleton<Database>(Database());
  g.registerSingleton<Dio>(apiModule.client);
  g.registerSingleton<LoadVehiclesInLocation>(
      controllersModule.loadVehiclesInLocation);
  g.registerSingleton<LoadVehiclesNearby>(controllersModule.loadVehiclesNearby);
  g.registerSingleton<TrackedLinesAdded>(controllersModule.trackedLinesAdded);
  g.registerSingleton<TrackedLinesRemoved>(
      controllersModule.trackedLinesRemoved);
  g.registerSingleton<UntrackLines>(controllersModule.untrackLines);
  g.registerSingleton<UntrackAllLines>(controllersModule.mapCleared);
  g.registerSingleton<RxSharedPreferences>(settingsModule.client);
  g.registerSingleton<PlacesApi>(PlacesApi.create(
    g<Dio>(),
  ));
  g.registerSingleton<VehiclesApi>(VehiclesApi.create(
    g<Dio>(),
  ));
  if (environment == 'dev') {
    g.registerSingleton<LinesRepo>(LinesRepoImpl(
      g<LinesDao>(),
    ));
    g.registerSingleton<LocationsRepo>(LocationsRepoImpl(
      g<LocationsDao>(),
    ));
    g.registerSingleton<PlaceSuggestionsRepo>(PlaceSuggestionsRepoImpl(
      g<PlacesDao>(),
      g<PlacesApi>(),
    ));
    g.registerSingleton<VehiclesRepo>(VehiclesRepoImpl(
      g<VehiclesApi>(),
    ));
  }
}

class _$ApiModule extends ApiModule {}

class _$ControllersModule extends ControllersModule {}

class _$SettingsModule extends SettingsModule {}

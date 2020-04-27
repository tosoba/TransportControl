import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:transport_control/di/injection.dart';
import 'package:transport_control/pages/home/home_bloc.dart';
import 'package:transport_control/pages/home/home_page.dart';
import 'package:transport_control/pages/lines/lines_bloc.dart';
import 'package:transport_control/pages/map/map_bloc.dart';
import 'package:transport_control/repo/lines_repo.dart';
import 'package:transport_control/repo/locations_repo.dart';
import 'package:transport_control/repo/vehicles_repo.dart';
import 'package:transport_control/util/preferences_util.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureInjection(Env.dev);
  _initSettings();
  runApp(TransportControlApp());
}

void _initSettings() async {
  final settings = GetIt.instance<RxSharedPreferences>();
  if (!(await settings.containsKey(
    Preferences.zoomToLoadedMarkersBounds.key,
  ))) {
    await settings.setBool(
      Preferences.zoomToLoadedMarkersBounds.key,
      Preferences.zoomToLoadedMarkersBounds.defaultValue,
    );
  }
}

class TransportControlApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Transport Control',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<HomeBloc>(
            create: (context) => HomeBloc(
              GetIt.instance<VehiclesRepo>(),
              GetIt.instance<LinesRepo>(),
              GetIt.instance<LocationsRepo>(),
            ),
          ),
          BlocProvider<MapBloc>(
            create: (context) => context.bloc<HomeBloc>().mapBloc,
          ),
          BlocProvider<LinesBloc>(
            create: (context) => context.bloc<HomeBloc>().linesBloc,
          ),
        ],
        child: HomePage(),
      ),
    );
  }
}

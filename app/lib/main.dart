import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:transport_control/di/injection.dart';
import 'package:transport_control/di/module/controllers_module.dart';
import 'package:transport_control/pages/home/home_page.dart';
import 'package:transport_control/pages/lines/lines_bloc.dart';
import 'package:transport_control/pages/map/map_bloc.dart';
import 'package:transport_control/pages/nearby/nearby_bloc.dart';
import 'package:transport_control/repo/lines_repo.dart';
import 'package:transport_control/repo/place_suggestions_repo.dart';
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

class TransportControlApp extends StatefulWidget {
  @override
  _TransportControlAppState createState() => _TransportControlAppState();
}

class _TransportControlAppState extends State<TransportControlApp> {
  @override
  void dispose() {
    final getIt = GetIt.instance;
    getIt<RxSharedPreferences>().dispose();
    getIt<LoadVehiclesInLocation>().injected.close();
    getIt<LoadVehiclesNearby>().injected.close();
    getIt<TrackedLinesAdded>().injected.close();
    getIt<TrackedLinesRemoved>().injected.close();
    getIt<UntrackLines>().injected.close();
    getIt<UntrackAllLines>().injected.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final getIt = GetIt.instance;
    final loadVehiclesInBounds = getIt<LoadVehiclesInLocation>().injected;
    final loadVehiclesNearby = getIt<LoadVehiclesNearby>().injected;
    final trackedLinesAdded = getIt<TrackedLinesAdded>().injected;
    final trackedLinesRemoved = getIt<TrackedLinesRemoved>().injected;
    final untrackLines = getIt<UntrackLines>().injected;
    final untrackAllLines = getIt<UntrackAllLines>().injected;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Transport Control',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<MapBloc>(
            create: (context) => MapBloc(
              getIt<VehiclesRepo>(),
              getIt<RxSharedPreferences>(),
              untrackLines.sink,
              untrackAllLines.sink,
              loadVehiclesInBounds.stream,
              loadVehiclesNearby.stream,
              trackedLinesAdded.stream,
              trackedLinesRemoved.stream,
            ),
          ),
          BlocProvider<LinesBloc>(
            create: (context) => LinesBloc(
              getIt<LinesRepo>(),
              trackedLinesAdded.sink,
              trackedLinesRemoved.sink,
              untrackLines.stream,
              untrackAllLines.stream,
            ),
          ),
          BlocProvider<NearbyBloc>(
            create: (context) => NearbyBloc(getIt<PlaceSuggestionsRepo>()),
          )
        ],
        child: HomePage(),
      ),
    );
  }
}

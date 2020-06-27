import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:transport_control/di/injection.dart';
import 'package:transport_control/di/module/controllers_module.dart';
import 'package:transport_control/pages/home/home_page.dart';
import 'package:transport_control/pages/last_searched/last_searched_bloc.dart';
import 'package:transport_control/pages/lines/lines_bloc.dart';
import 'package:transport_control/pages/locations/locations_bloc.dart';
import 'package:transport_control/pages/map/map_bloc.dart';
import 'package:transport_control/pages/nearby/nearby_bloc.dart';
import 'package:transport_control/repo/last_searched_repo.dart';
import 'package:transport_control/repo/lines_repo.dart';
import 'package:transport_control/repo/locations_repo.dart';
import 'package:transport_control/repo/place_suggestions_repo.dart';
import 'package:transport_control/repo/vehicles_repo.dart';
import 'package:transport_control/util/preferences_util.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureInjection(Env.dev);
  GetIt.instance<RxSharedPreferences>().initDefaults();
  runApp(TransportControlApp());
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
    getIt<LoadVehiclesNearbyUserLocation>().injected.close();
    getIt<TrackedLinesAdded>().injected.close();
    getIt<TrackedLinesRemoved>().injected.close();
    getIt<UntrackLines>().injected.close();
    getIt<UntrackAllLines>().injected.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final getIt = GetIt.instance;
    final loadVehiclesInLocation = getIt<LoadVehiclesInLocation>().injected;
    final loadVehiclesNearbyUserLocation =
        getIt<LoadVehiclesNearbyUserLocation>().injected;
    final loadVehiclesNearbyPlace = getIt<LoadVehiclesNearbyPlace>().injected;
    final trackedLinesAdded = getIt<TrackedLinesAdded>().injected;
    final trackedLinesRemoved = getIt<TrackedLinesRemoved>().injected;
    final untrackLines = getIt<UntrackLines>().injected;
    final untrackAllLines = getIt<UntrackAllLines>().injected;
    final preferences = getIt<RxSharedPreferences>();

    return StreamBuilder<ThemeMode>(
      stream: preferences
          .getStringStream(Preferences.theme.key)
          .where((themeString) => themeString != null)
          .map(
            (themeString) => ThemeMode.values.firstWhere(
              (themeMode) => describeEnum(themeMode) == themeString,
            ),
          )
          .distinct(),
      builder: (context, snapshot) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Transport Control',
        theme: ThemeData.light().copyWith(primaryColor: Colors.white),
        darkTheme: ThemeData.dark(),
        themeMode: snapshot.data ?? ThemeMode.system,
        home: MultiBlocProvider(
          providers: [
            BlocProvider<MapBloc>(
              create: (context) => MapBloc(
                getIt<VehiclesRepo>(),
                preferences,
                untrackLines.sink,
                untrackAllLines.sink,
                loadVehiclesInLocation.stream,
                loadVehiclesNearbyUserLocation.stream,
                loadVehiclesNearbyPlace.stream,
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
            BlocProvider<LocationsBloc>(
              create: (context) => LocationsBloc(
                getIt<LocationsRepo>(),
                loadVehiclesInLocation.sink,
                loadVehiclesNearbyUserLocation.sink,
              ),
            ),
            BlocProvider<NearbyBloc>(
              create: (context) => NearbyBloc(
                getIt<PlaceSuggestionsRepo>(),
                loadVehiclesNearbyPlace.sink,
              ),
            ),
            BlocProvider<LastSearchedBloc>(
              create: (context) => LastSearchedBloc(getIt<LastSearchedRepo>()),
            )
          ],
          child: HomePage(),
        ),
      ),
    );
  }
}

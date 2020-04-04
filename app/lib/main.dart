import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:transport_control/di/injection.dart';
import 'package:transport_control/pages/home/home_page.dart';
import 'package:transport_control/pages/lines/lines_bloc.dart';
import 'package:transport_control/pages/map/map_bloc.dart';
import 'package:transport_control/repo/vehicles_repo.dart';

void main() {
  configureInjection(Env.dev);
  runApp(TransportControlApp());
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
          BlocProvider<MapBloc>(
            create: (context) => MapBloc(
              GetIt.instance<VehiclesRepo>(),
              (lines) {
                context.bloc<LinesBloc>().loadingVehiclesOfLinesFailed(lines);
              },
            ),
          ),
          BlocProvider<LinesBloc>(
            create: (context) => LinesBloc(
              (lines) => context.bloc<MapBloc>().trackedLinesAdded(lines),
              (lines) => context.bloc<MapBloc>().trackedLinesRemoved(lines),
            ),
          ),
        ],
        child: HomePage(),
      ),
    );
  }
}

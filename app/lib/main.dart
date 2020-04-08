import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:transport_control/di/injection.dart';
import 'package:transport_control/pages/home/home_bloc.dart';
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
          BlocProvider<HomeBloc>(
            create: (context) => HomeBloc(GetIt.instance<VehiclesRepo>()),
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

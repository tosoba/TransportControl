import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:transport_control/pages/map/map_bloc.dart';

class TrackedPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    //TODO: appbar with filter that can be used in useStream transforming state from MapBloc
    return Scaffold(
      body: Container(),
      floatingActionButton: _floatingActionButton(context),
    );
  }

  Widget _floatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => context.bloc<MapBloc>().clearMap(),
      label: Text('Clear all'),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Navigation {
  Future<T> pushRouteWithMultiProvider<T>(
    BuildContext context, {
    @required List<BlocProvider> providers,
    @required Widget Function() child,
  }) {
    assert(providers != null && providers.isNotEmpty);
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(providers: providers, child: child()),
      ),
    );
  }
}

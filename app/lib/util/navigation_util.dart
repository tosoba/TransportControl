import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transport_control/pages/last_searched/last_searched_bloc.dart';
import 'package:transport_control/pages/last_searched/last_searched_page.dart';
import 'package:transport_control/pages/lines/lines_bloc.dart';
import 'package:transport_control/pages/locations/locations_bloc.dart';

extension NavigationExt on BuildContext {
  Future<T> pushRouteWithMultiProvider<T>({
    @required List<BlocProvider> providers,
    @required Widget Function() child,
  }) {
    assert(providers != null && providers.isNotEmpty);
    return Navigator.push(
      this,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(providers: providers, child: child()),
      ),
    );
  }

  void showLastSearchedPage({
    @required LastSearchedPageFilterMode filterMode,
  }) async {
    await pushRouteWithMultiProvider(
      providers: [
        BlocProvider.value(value: bloc<LinesBloc>()),
        BlocProvider.value(value: bloc<LocationsBloc>()),
        BlocProvider.value(value: bloc<LastSearchedBloc>())
      ],
      child: () => LastSearchedPage(filterMode: filterMode),
    );
  }
}

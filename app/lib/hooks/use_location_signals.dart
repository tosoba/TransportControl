import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:transport_control/pages/locations/locations_bloc.dart';

void useLocationsSignals({
  @required BuildContext context,
  @required GlobalKey<ScaffoldState> scaffoldKey,
}) {
  useEffect(() {
    final subscription = context.bloc<LocationsBloc>().signals.listen((signal) {
      signal.when(
        loading: (loading) {
          scaffoldKey.currentState
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(loading.message),
                duration: const Duration(days: 1),
              ),
            );
        },
        loadingError: (loadingError) {
          scaffoldKey.currentState
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(loadingError.message)));
        },
      );
    });
    return subscription.cancel;
  });
}

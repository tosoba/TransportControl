import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:transport_control/pages/map/map_bloc.dart';
import 'package:transport_control/pages/map/map_signal.dart';

void useMapSignals({
  @required GlobalKey<ScaffoldState> scaffoldKey,
  @required BuildContext context,
  @required ValueNotifier<Object> listenTrigger,
}) {
  useEffect(() {
    StreamSubscription<MapSignal> subscription;
    listenTrigger.addListener(() {
      if (listenTrigger.value == null) return;
      subscription?.cancel();
      subscription = context.bloc<MapBloc>().signals.listen((signal) {
        signal.whenPartial(
          loading: (loading) {
            scaffoldKey.currentState
              ..removeCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(loading.message),
                  duration: const Duration(days: 1),
                ),
              );
          },
          loadedSuccessfully: (_) {
            Navigator.pop(context);
          },
          loadingError: (loadingError) {
            scaffoldKey.currentState
              ..removeCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(loadingError.message),
                action: SnackBarAction(
                  label: 'Retry',
                  onPressed: () {
                    scaffoldKey.currentState.removeCurrentSnackBar();
                    loadingError.retry();
                  },
                ),
              ));
          },
        );
      });
    });
    return () {
      subscription?.cancel();
    };
  });
}

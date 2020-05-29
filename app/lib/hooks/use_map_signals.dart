import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:transport_control/pages/map/map_bloc.dart';
import 'package:transport_control/pages/map/map_signal.dart';
import 'package:transport_control/util/model_util.dart';
import 'package:transport_control/util/snack_bar_util.dart';

void useMapSignals({
  @required GlobalKey<ScaffoldState> scaffoldKey,
  @required BuildContext context,
  @required ValueNotifier<Object> listenTrigger,
}) {
  useEffect(() {
    StreamSubscription<LoadingSignalTracker<MapSignal, Loading>> subscription;
    listenTrigger.addListener(
      () {
        if (listenTrigger.value == null || subscription != null) return;
        subscription = context
            .bloc<MapBloc>()
            .signals
            .loadingSignalTrackerStream<Loading>()
            .listen(
              (tracker) => tracker.signal.whenPartial(
                loading: (loading) {
                  scaffoldKey.currentState.hideCurrentAndShowLoadingSnackBar(
                    text: loading.message,
                    currentlyLoading: tracker.currentlyLoading,
                  );
                },
                loadedSuccessfully: (_) {
                  if (tracker.currentlyLoading == 0) {
                    Navigator.pop(context);
                  } else {
                    scaffoldKey.currentState
                        .hideCurrentAndShowSnackBar(
                          signalSnackBar(
                            text:
                                'Loading finished successfully. ${tracker.currentlyLoading} request${tracker.currentlyLoading > 1 ? 's' : ''} left.',
                            action: SnackBarAction(
                              label: 'Map',
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        )
                        .showLoadingSnackBarOnClose(
                          text: 'Loading in progress',
                          currentlyLoading: tracker.currentlyLoading,
                          getScaffoldState: () => scaffoldKey.currentState,
                        );
                  }
                },
                loadingError: (loadingError) {
                  final snackBarController =
                      scaffoldKey.currentState.hideCurrentAndShowSnackBar(
                    signalSnackBar(
                      text: loadingError.message,
                      action: SnackBarAction(
                        label: 'Retry',
                        onPressed: () {
                          scaffoldKey.currentState.hideCurrentSnackBar();
                          loadingError.retry();
                        },
                      ),
                    ),
                  );
                  if (tracker.currentlyLoading == 0) return;
                  snackBarController.showLoadingSnackBarOnClose(
                    text: 'Loading in progress',
                    currentlyLoading: tracker.currentlyLoading,
                    getScaffoldState: () => scaffoldKey.currentState,
                  );
                },
              ),
            );
      },
    );
    return () {
      subscription?.cancel();
    };
  });
}

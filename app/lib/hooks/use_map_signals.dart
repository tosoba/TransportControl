import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:transport_control/pages/map/map_bloc.dart';
import 'package:transport_control/pages/map/map_signal.dart';
import 'package:transport_control/util/model_util.dart';

void useMapSignals({
  @required GlobalKey<ScaffoldState> scaffoldKey,
  @required BuildContext context,
  @required ValueNotifier<Object> listenTrigger,
}) {
  useEffect(() {
    StreamSubscription<LoadingSignalTracker<MapSignal, Loading>> subscription;
    listenTrigger.addListener(() {
      if (listenTrigger.value == null || subscription != null) return;
      subscription = context
          .bloc<MapBloc>()
          .signals
          .scan<
              Pair<LoadingSignalTracker<MapSignal, Loading>,
                  LoadingSignalTracker<MapSignal, Loading>>>(
            Pair(null, null),
            (latest2Trackers, signal) => Pair(
              latest2Trackers.second,
              latest2Trackers.second?.next(signal) ??
                  LoadingSignalTracker.first(signal),
            ),
          )
          .map((pair) => pair.second)
          .listen(
            (tracker) => tracker.signal.whenPartial(
              loading: (loading) {
                scaffoldKey.currentState
                  ..removeCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        tracker.currentlyLoading == 1
                            ? loading.message
                            : 'Processing ${tracker.currentlyLoading} loading requests...',
                      ),
                      behavior: SnackBarBehavior.floating,
                      elevation: 4,
                      duration: const Duration(days: 1),
                    ),
                  );
              },
              loadedSuccessfully: (_) {
                //TODO: pop or show a success snackbar if more requests are loading - after that is dissmissed show another loading snackbar with (currentlyLoading - 1); same in on error
                Navigator.pop(context);
              },
              loadingError: (loadingError) {
                scaffoldKey.currentState
                  ..removeCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(loadingError.message),
                      behavior: SnackBarBehavior.floating,
                      elevation: 4,
                      action: SnackBarAction(
                        label: 'Retry',
                        onPressed: () {
                          scaffoldKey.currentState.removeCurrentSnackBar();
                          loadingError.retry();
                        },
                      ),
                    ),
                  );
              },
            ),
          );
    });
    return () {
      subscription?.cancel();
    };
  });
}

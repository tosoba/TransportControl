import 'dart:async';
import 'dart:developer';

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
    StreamSubscription<ConsecutiveTypesCounted<MapSignal>> subscription;
    listenTrigger.addListener(() {
      if (listenTrigger.value == null || subscription != null) return;
      subscription = context
          .bloc<MapBloc>()
          .signals
          .scan<
              Pair<ConsecutiveTypesCounted<MapSignal>,
                  ConsecutiveTypesCounted<MapSignal>>>(
            Pair(null, null),
            (last2Signals, signal) => Pair(
              last2Signals.second,
              last2Signals.second?.nextWith(signal) ??
                  ConsecutiveTypesCounted.first(signal),
            ),
          )
          .map((pair) => pair.second)
          .listen(
            (signal) => signal.item.whenPartial(
              loading: (loading) {
                scaffoldKey.currentState
                  ..removeCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        signal.timesConsecutiveType == 0
                            ? loading.message
                            : 'Processing ${signal.timesConsecutiveType + 1} loading requests...',
                      ),
                      behavior: SnackBarBehavior.floating,
                      elevation: 4,
                      duration: const Duration(days: 1),
                    ),
                  );
              },
              loadedSuccessfully: (_) => Navigator.pop(context),
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

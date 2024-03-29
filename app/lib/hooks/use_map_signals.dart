import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:transport_control/pages/map/map_bloc.dart';
import 'package:transport_control/util/model_util.dart';
import 'package:transport_control/util/snack_bar_util.dart';

void useMapSignals({
  @required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
  @required BuildContext context,
}) {
  useEffect(() {
    final subscription = context.read<MapBloc>().listenToLoadingSignalTrackers(
      (tracker) {
        return tracker.signal.whenPartial(
          loading: (loading) {
            scaffoldMessengerKey.currentState.showNewLoadingSnackBar(
              text: loading.message,
              currentlyLoading: tracker.currentlyLoading,
            );
          },
          loadedSuccessfully: (_) {
            if (tracker.currentlyLoading == 0) {
              Navigator.pop(context);
            } else {
              scaffoldMessengerKey.currentState.showNewLoadedSuccessfullySnackBar(
                tracker: tracker,
                getScaffoldMessengerState: () => scaffoldMessengerKey.currentState,
                action: SnackBarAction(
                  label: 'Map',
                  onPressed: () => Navigator.pop(context),
                ),
              );
            }
          },
          loadingError: (loadingError) {
            scaffoldMessengerKey.currentState.showNewLoadingErrorSnackBar(
              tracker: tracker,
              getScaffoldMessengerState: () => scaffoldMessengerKey.currentState,
              errorMessage: loadingError.message,
              retry: loadingError.retry,
            );
          },
        );
      },
    );
    return subscription.cancel;
  });
}

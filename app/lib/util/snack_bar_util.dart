import 'package:flutter/material.dart';
import 'package:transport_control/util/model_util.dart';

SnackBar _signalSnackBar({
  @required String text,
  Duration duration = const Duration(seconds: 4),
  SnackBarAction action,
}) {
  return SnackBar(
    content: Text(text),
    behavior: SnackBarBehavior.floating,
    elevation: 4,
    duration: duration,
    action: action,
  );
}

extension ScaffoldStateExt on ScaffoldMessengerState {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
      _hideCurrentAndShowSnackBar(SnackBar snackBar) {
    hideCurrentSnackBar();
    return showSnackBar(snackBar);
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
      showNewLoadingSnackBar({
    @required String text,
    @required int currentlyLoading,
  }) {
    hideCurrentSnackBar();
    return _showLoadingSnackBar(text: text, currentlyLoading: currentlyLoading);
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
      _showLoadingSnackBar({
    @required String text,
    @required int currentlyLoading,
  }) {
    return showSnackBar(
      _signalSnackBar(
        text: currentlyLoading == 1
            ? text
            : 'Processing ${currentlyLoading} loading requests...',
        duration: const Duration(days: 1),
      ),
    );
  }

  void showNewLoadedSuccessfullySnackBar<Signal, Loading extends Signal>({
    @required LoadingSignalTracker<Signal, Loading> tracker,
    @required ScaffoldMessengerState Function() getScaffoldMessengerState,
    SnackBarAction action,
  }) {
    _hideCurrentAndShowSnackBar(
      _signalSnackBar(
        text:
            'Loading finished successfully. ${tracker.currentlyLoading} request${tracker.currentlyLoading > 1 ? 's' : ''} left.',
        action: action,
      ),
    )._showLoadingSnackBarOnClose(
      text:
          'Processing remaining ${tracker.currentlyLoading} loading request${tracker.currentlyLoading > 1 ? 's' : ''}.',
      currentlyLoading: tracker.currentlyLoading,
      getScaffoldMessengerState: getScaffoldMessengerState,
    );
  }

  void showNewLoadingErrorSnackBar<Signal, Loading extends Signal>({
    @required LoadingSignalTracker<Signal, Loading> tracker,
    @required ScaffoldMessengerState Function() getScaffoldMessengerState,
    @required String errorMessage,
    void Function() retry,
    bool autoHide = false,
  }) {
    final duration = const Duration(seconds: 4);
    bool retryPressed = false;

    final snackBarController = _hideCurrentAndShowSnackBar(
      _signalSnackBar(
        duration: duration,
        text: errorMessage,
        action: retry != null
            ? SnackBarAction(
                label: 'Retry',
                onPressed: () {
                  hideCurrentSnackBar();
                  retryPressed = true;
                  retry();
                },
              )
            : null,
      ),
    );

    if (tracker.currentlyLoading == 0) {
      if (!retryPressed && autoHide) {
        Future.delayed(duration, () {
          getScaffoldMessengerState()?.removeCurrentSnackBar();
        });
      }
      return;
    }

    snackBarController._showLoadingSnackBarOnClose(
      text:
          'Processing remaining ${tracker.currentlyLoading} loading request${tracker.currentlyLoading > 1 ? 's' : ''}.',
      currentlyLoading: tracker.currentlyLoading,
      getScaffoldMessengerState: getScaffoldMessengerState,
    );
  }
}

extension _ScaffoldFeatureControllerExt
    on ScaffoldFeatureController<SnackBar, SnackBarClosedReason> {
  void _showLoadingSnackBarOnClose({
    @required String text,
    @required int currentlyLoading,
    @required ScaffoldMessengerState Function() getScaffoldMessengerState,
  }) {
    closed.then((reason) {
      if (reason == SnackBarClosedReason.action ||
          reason == SnackBarClosedReason.hide ||
          reason == SnackBarClosedReason.remove) return;
      getScaffoldMessengerState()?._showLoadingSnackBar(
        text: text,
        currentlyLoading: currentlyLoading,
      );
    });
  }
}

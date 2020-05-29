import 'package:flutter/material.dart';

SnackBar signalSnackBar({
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

extension ScaffoldStateExt on ScaffoldState {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
      hideCurrentAndShowSnackBar(SnackBar snackBar) {
    hideCurrentSnackBar();
    return showSnackBar(snackBar);
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
      hideCurrentAndShowLoadingSnackBar({
    @required String text,
    @required int currentlyLoading,
  }) {
    hideCurrentSnackBar();
    return showLoadingSnackBar(text: text, currentlyLoading: currentlyLoading);
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
      showLoadingSnackBar({
    @required String text,
    @required int currentlyLoading,
  }) {
    return showSnackBar(
      signalSnackBar(
        text: currentlyLoading == 1
            ? text
            : 'Processing ${currentlyLoading} loading requests...',
        duration: const Duration(days: 1),
      ),
    );
  }
}

extension ScaffoldFeatureControllerExt
    on ScaffoldFeatureController<SnackBar, SnackBarClosedReason> {
  void showLoadingSnackBarOnClose({
    @required String text,
    @required int currentlyLoading,
    @required ScaffoldState Function() getScaffoldState,
  }) {
    closed.then((reason) {
      if (reason == SnackBarClosedReason.action ||
          reason == SnackBarClosedReason.hide ||
          reason == SnackBarClosedReason.remove) return;
      getScaffoldState().showLoadingSnackBar(
        text: text,
        currentlyLoading: currentlyLoading,
      );
    });
  }
}

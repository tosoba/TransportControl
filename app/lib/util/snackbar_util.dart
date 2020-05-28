import 'package:flutter/material.dart';

class SnackbarArgs {
  final Widget content;
  final Duration duration;
  final SnackBarAction action;

  SnackbarArgs.withText(
    String text, {
    this.duration = const Duration(seconds: 4),
    this.action = null,
  }) : content = Text(text);
}

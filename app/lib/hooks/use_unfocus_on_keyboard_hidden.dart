import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:transport_control/hooks/use_keyboard_visibility.dart';

void useUnfocusOnKeyboardHidden({@required FocusNode focusNode}) {
  useKeyboardVisibility(onChange: (visible) {
    if (!visible && focusNode.hasFocus) focusNode.unfocus();
  });
}

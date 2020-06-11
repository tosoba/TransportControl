import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

void useKeyboardVisibility({
  @required dynamic Function(bool) onChange,
}) {
  useEffect(() {
    final keyboardVisibility = KeyboardVisibilityNotification();
    final subscribingId = keyboardVisibility.addNewListener(onChange: onChange);
    return () {
      keyboardVisibility.removeListener(subscribingId);
      keyboardVisibility.dispose();
    };
  });
}

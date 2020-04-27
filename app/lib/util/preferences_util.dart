import 'package:flutter/material.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

class Preferences {
  static final _Preference<bool> zoomToLoadedMarkersBounds = _Preference(
    key: 'zoomToLoadedMarkersBounds',
    defaultValue: false,
  );
}

class _Preference<T> {
  final String key;
  final T defaultValue;

  _Preference({@required this.key, @required this.defaultValue});
}

class SilentPreferencesLogger extends LoggerAdapter {
  const SilentPreferencesLogger();

  @override
  void readValue(Type type, String key, value) {}
}

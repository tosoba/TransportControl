import 'package:flutter/material.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

class Preferences {
  Preferences._();

  static final Preference<bool> zoomToLoadedMarkersBounds = const Preference(
    key: 'zoomToLoadedMarkersBounds',
    defaultValue: false,
    title: "Zoom to loaded markers' bounds",
  );
}

class Preference<T> {
  final String key;
  final T defaultValue;
  final String title;

  const Preference({
    @required this.key,
    @required this.defaultValue,
    @required this.title,
  });
}

class ListPreference<T> extends Preference<T> {
  final List<T> values;

  const ListPreference(
    this.values, {
    @required T defaultValue,
    @required String key,
    @required String title,
  }) : super(title: title, key: key, defaultValue: defaultValue);
}

class SilentPreferencesLogger extends LoggerAdapter {
  const SilentPreferencesLogger();

  @override
  void readValue(Type type, String key, value) {}
}

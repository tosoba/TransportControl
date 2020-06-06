import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

class Preferences {
  Preferences._();

  static const Preference<bool> zoomToLoadedMarkersBounds = const Preference(
    key: 'zoomToLoadedMarkersBounds',
    defaultValue: false,
    title: "Zoom to loaded markers' bounds",
  );

  static const List<Preference> list = const [zoomToLoadedMarkersBounds];
}

class Preference<T> {
  final String key;
  final T defaultValue;
  final String title;

  Type get type => defaultValue.runtimeType;

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

class PreferenceWithValue<T> {
  final Preference<T> preference;
  final AsyncSnapshot<T> value;

  PreferenceWithValue({@required this.preference, @required this.value});
}

extension RxSharedPreferencesExt on RxSharedPreferences {
  void initDefaults() async {
    final keys = await getKeys();
    Preferences.list.forEach((preference) {
      if (keys.contains(preference.key)) return;
      _setDefault(preference);
    });
  }

  void _setDefault(Preference preference) {
    switch (preference.type) {
      case bool:
        setBool(preference.key, preference.defaultValue);
        break;
      case double:
        setDouble(preference.key, preference.defaultValue);
        break;
      case int:
        setInt(preference.key, preference.defaultValue);
        break;
      case String:
        setString(preference.key, preference.defaultValue);
        break;
      case List:
        setStringList(preference.key, preference.defaultValue);
        break;
      default:
        throw ArgumentError('Invalid preference type.');
    }
  }

  PreferenceWithValue use(Preference preference) {
    switch (preference.type) {
      case bool:
        return PreferenceWithValue<bool>(
          preference: preference,
          value: useStream(getBoolStream(preference.key).distinct()),
        );
      case double:
        return PreferenceWithValue<double>(
          preference: preference,
          value: useStream(getDoubleStream(preference.key).distinct()),
        );
      case int:
        return PreferenceWithValue<int>(
          preference: preference,
          value: useStream(getIntStream(preference.key).distinct()),
        );
      case String:
        return PreferenceWithValue<String>(
          preference: preference,
          value: useStream(getStringStream(preference.key).distinct()),
        );
      case List:
        return PreferenceWithValue<List<String>>(
          preference: preference,
          value: useStream(getStringListStream(preference.key).distinct()),
        );
      default:
        throw ArgumentError('Invalid preference type.');
    }
  }
}

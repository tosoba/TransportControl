import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:quiver/core.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';

class Preferences {
  Preferences._();

  static const Preference<bool> trafficEnabled = const Preference(
    key: 'trafficEnabled',
    defaultValue: false,
    title: 'Traffic enabled',
  );

  static const Preference<bool> buildingsEnabled = const Preference(
    key: 'buildingsEnabled',
    defaultValue: false,
    title: 'Buildings enabled',
  );

  static const Preference<bool> zoomToLoadedMarkersBounds = const Preference(
    key: 'zoomToLoadedMarkersBounds',
    defaultValue: false,
    title: "Zoom to loaded markers' bounds",
  );

  static final EnumeratedPreference<int> nearbySearchRadius =
      EnumeratedPreference(
    [100, 500, 1000, 2000, 5000],
    defaultValue: 1000,
    key: 'nearbySearchRadius',
    title: 'Vehicles nearby location search radius',
    valueLabel: (radius) =>
        radius < 1000 ? '$radius m' : '${radius ~/ 1000} km',
  );

  static EnumeratedPreference<String> theme = EnumeratedPreference(
    ThemeMode.values.map(describeEnum).toList(),
    defaultValue: describeEnum(ThemeMode.system),
    key: 'theme',
    title: 'Theme',
    valueLabel: (theme) =>
        '${theme.substring(0, 1).toUpperCase()}${theme.substring(1)}',
  );

  static List<Preference> list = [
    trafficEnabled,
    buildingsEnabled,
    zoomToLoadedMarkersBounds,
    nearbySearchRadius,
    theme,
  ];
}

class Preference<T> {
  final String key;
  final T defaultValue;
  final String title;

  Type get type => defaultValue.runtimeType;

  EnumeratedPreference<T> get enumerated {
    return this is EnumeratedPreference<T> ? this : throw TypeError();
  }

  const Preference({
    @required this.key,
    @required this.defaultValue,
    @required this.title,
  });
}

class EnumeratedPreference<T> extends Preference<T> {
  final List<T> values;
  final String Function(T) valueLabel;

  const EnumeratedPreference(
    this.values, {
    @required T defaultValue,
    @required String key,
    @required String title,
    @required this.valueLabel,
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

  T get valueOrDefault => value.data ?? preference.defaultValue;

  PreferenceWithValue({@required this.preference, @required this.value});
}

extension RxSharedPreferencesExt on RxSharedPreferences {
  void initDefaults() async {
    final keys = await getKeys();
    Preferences.list.forEach((preference) {
      if (keys.contains(preference.key)) return;
      setDefault(preference);
    });
  }

  Future<bool> set(Preference preference, {@required dynamic value}) {
    switch (preference.type) {
      case bool:
        return setBool(preference.key, value);
      case double:
        return setDouble(preference.key, value);
      case int:
        return setInt(preference.key, value);
      case String:
        return setString(preference.key, value);
      case List:
        return setStringList(preference.key, value);
      default:
        throw ArgumentError('Invalid preference type.');
    }
  }

  Future<bool> setDefault(Preference preference) {
    return set(preference, value: preference.defaultValue);
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

  Stream<Brightness> themeBrightnessStream({
    @required BuildContext Function() context,
  }) {
    return getStringStream(Preferences.theme.key)
        .where((themeString) => themeString != null)
        .map((_) {
          final ctx = context();
          return ctx == null ? null : Theme.of(ctx)?.brightness;
        })
        .where((brightness) => brightness != null)
        .distinct();
  }

  void useThemeBrightness({
    @required BuildContext Function() context,
    @required void Function(Brightness) onChanged,
  }) {
    useEffect(() {
      final subscription =
          themeBrightnessStream(context: context).listen(onChanged);
      return subscription.cancel;
    });
  }

  Stream<MapPreferences> get mapPreferencesStream {
    return getBoolStream(Preferences.trafficEnabled.key)
        .where((enabled) => enabled != null)
        .combineLatest(
          getBoolStream(Preferences.buildingsEnabled.key)
              .where((enabled) => enabled != null),
          (bool trafficEnabled, bool buildingsEnabled) => MapPreferences(
            trafficEnabled: trafficEnabled,
            buildingsEnabled: buildingsEnabled,
          ),
        )
        .distinct();
  }
}

class MapPreferences {
  final bool trafficEnabled;
  final bool buildingsEnabled;

  MapPreferences({
    @required this.trafficEnabled,
    @required this.buildingsEnabled,
  });

  bool operator ==(other) {
    return other is MapPreferences &&
        trafficEnabled == other.trafficEnabled &&
        buildingsEnabled == other.buildingsEnabled;
  }

  int get hashCode => hashObjects([trafficEnabled, buildingsEnabled]);
}

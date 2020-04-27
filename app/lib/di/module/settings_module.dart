import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:transport_control/util/preferences_util.dart';

@registerModule
abstract class SettingsModule {
  @singleton
  RxSharedPreferences get client {
    return RxSharedPreferences(
      SharedPreferences.getInstance(),
      const SilentPreferencesLogger(),
    );
  }
}

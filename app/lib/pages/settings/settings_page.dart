import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:transport_control/util/preferences_util.dart';
import 'package:transport_control/widgets/text_field_app_bar.dart';
import 'package:transport_control/widgets/text_field_app_bar_back_button.dart';

class SettingsPage extends HookWidget {
  final settings = GetIt.instance<RxSharedPreferences>();

  @override
  Widget build(BuildContext context) {
    final searchFieldFocusNode = useFocusNode();
    final searchFieldController = useTextEditingController();
    final searchFieldTextController = useStreamController<String>();
    searchFieldController.addListener(() {
      searchFieldTextController
          .add(searchFieldController.text?.trim()?.toLowerCase());
    });

    final preferencesWithValues = <_PreferenceWithValue>[
      _PreferenceWithValue<bool>(
        preference: Preferences.zoomToLoadedMarkersBounds,
        value: useStream(
          settings
              .getBoolStream(Preferences.zoomToLoadedMarkersBounds.key)
              .distinct(),
        ),
      ),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: TextFieldAppBar(
        textFieldFocusNode: searchFieldFocusNode,
        textFieldController: searchFieldController,
        hint: "Search settings...",
        leading: TextFieldAppBarBackButton(searchFieldFocusNode),
      ),
      body: StreamBuilder<String>(
        stream: searchFieldTextController.stream,
        builder: (context, snapshot) {
          final preferences = snapshot.data == null || snapshot.data.isEmpty
              ? preferencesWithValues
              : preferencesWithValues.where(
                  (pwv) => pwv.preference.title.contains(snapshot.data),
                );
          return ListView.builder(
            itemCount: preferences.length,
            itemBuilder: (context, index) => _preferenceListItem(
              preferences.elementAt(index),
            ),
          );
        },
      ),
    );
  }

  Widget _preferenceListItem(_PreferenceWithValue preferenceWithValue) {
    if (preferenceWithValue.preference is ListPreference) {
      //TODO:
      throw UnimplementedError();
    } else {
      switch (preferenceWithValue.type) {
        case bool:
          return _boolPreferenceListItem(preferenceWithValue);
        default:
          throw ArgumentError();
      }
    }
  }

  Widget _boolPreferenceListItem(
    _PreferenceWithValue<bool> preferenceWithValue,
  ) {
    final preference = preferenceWithValue.preference;
    return SwitchListTile(
      value: preferenceWithValue.value.data ?? preference.defaultValue,
      title: Text(preference.title),
      onChanged: (value) {
        settings.setBool(preference.key, value);
      },
    );
  }
}

class _PreferenceWithValue<T> {
  final Preference<T> preference;
  final AsyncSnapshot<T> value;

  Type get type => preference.defaultValue.runtimeType;

  _PreferenceWithValue({@required this.preference, @required this.value});
}

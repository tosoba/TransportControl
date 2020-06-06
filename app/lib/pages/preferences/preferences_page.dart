import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:transport_control/util/preferences_util.dart';
import 'package:transport_control/widgets/text_field_app_bar.dart';
import 'package:transport_control/widgets/text_field_app_bar_back_button.dart';

class PreferencesPage extends HookWidget {
  final _preferences = GetIt.instance<RxSharedPreferences>();

  @override
  Widget build(BuildContext context) {
    final searchFieldFocusNode = useFocusNode();
    final searchFieldController = useTextEditingController();
    final searchFieldTextController = useStreamController<String>();
    searchFieldController.addListener(() {
      searchFieldTextController
          .add(searchFieldController.text?.trim()?.toLowerCase());
    });

    final preferencesWithValues =
        Preferences.list.map(_preferences.use).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: TextFieldAppBar(
        textFieldFocusNode: searchFieldFocusNode,
        textFieldController: searchFieldController,
        hint: "Search preferences...",
        leading: TextFieldAppBarBackButton(searchFieldFocusNode),
      ),
      body: StreamBuilder<String>(
        stream: searchFieldTextController.stream,
        builder: (context, snapshot) {
          final filteredPreferencesWithValues =
              snapshot.data == null || snapshot.data.isEmpty
                  ? preferencesWithValues
                  : preferencesWithValues.where(
                      (pwv) => pwv.preference.title.contains(snapshot.data),
                    );
          return ListView.builder(
            itemCount: filteredPreferencesWithValues.length,
            itemBuilder: (context, index) => _preferenceListItem(
              filteredPreferencesWithValues.elementAt(index),
            ),
          );
        },
      ),
    );
  }

  Widget _preferenceListItem(PreferenceWithValue preferenceWithValue) {
    final preference = preferenceWithValue.preference;
    if (preference is ListPreference) {
      //TODO:
      throw UnimplementedError();
    } else {
      switch (preference.type) {
        case bool:
          return _boolPreferenceListItem(preferenceWithValue);
        default:
          throw ArgumentError('Invalid preference type.');
      }
    }
  }

  Widget _boolPreferenceListItem(
    PreferenceWithValue<bool> preferenceWithValue,
  ) {
    final preference = preferenceWithValue.preference;
    return SwitchListTile(
      value: preferenceWithValue.value.data ?? preference.defaultValue,
      title: Text(preference.title),
      onChanged: (value) {
        _preferences.setBool(preference.key, value);
      },
    );
  }
}

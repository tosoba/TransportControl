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
              context: context,
            ),
          );
        },
      ),
    );
  }

  Widget _preferenceListItem(
    PreferenceWithValue preferenceWithValue, {
    @required BuildContext context,
  }) {
    final preference = preferenceWithValue.preference;
    if (preference is EnumeratedPreference) {
      switch (preference.type) {
        case int:
          return _intEnumeratedPreferenceItem(
            preferenceWithValue,
            context: context,
          );
        default:
          throw ArgumentError('Invalid preference type.');
      }
    } else {
      switch (preference.type) {
        case bool:
          return _boolPreferenceItem(preferenceWithValue);
        default:
          throw ArgumentError('Invalid preference type.');
      }
    }
  }

  Widget _boolPreferenceItem(
    PreferenceWithValue<bool> preferenceWithValue,
  ) {
    final preference = preferenceWithValue.preference;
    return SwitchListTile(
      value: preferenceWithValue.valueOrDefault,
      title: Text(preference.title),
      onChanged: (value) {
        _preferences.setBool(preference.key, value);
      },
    );
  }

  Widget _intEnumeratedPreferenceItem(
    PreferenceWithValue<int> preferenceWithValue, {
    @required BuildContext context,
  }) {
    final preference = preferenceWithValue.preference.enumerated;
    return Material(
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => SimpleDialog(
              title: const Text('Select radius'),
              children: preference.values
                  .map(
                    (value) => _EnumeratedPreferenceListTile(
                      value: value,
                      preference: preference,
                      onChanged: (_) {
                        _preferences.setInt(preference.key, value);
                      },
                    ),
                  )
                  .toList(),
            ),
          );
        },
        child: ListTile(
          title: Text(preference.title),
          subtitle: Text(
            preference.valueLabel(preferenceWithValue.valueOrDefault),
          ),
        ),
      ),
    );
  }
}

class _EnumeratedPreferenceListTile<T> extends HookWidget {
  final T value;
  final EnumeratedPreference<T> preference;
  final void Function(bool) onChanged;

  final _preferences = GetIt.instance<RxSharedPreferences>();

  _EnumeratedPreferenceListTile({
    Key key,
    @required this.value,
    @required this.preference,
    @required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final preferenceWithValue = _preferences.use(preference);
    return CheckboxListTile(
      title: Text(preference.valueLabel(value)),
      value: preferenceWithValue.valueOrDefault == value,
      onChanged: onChanged,
    );
  }
}

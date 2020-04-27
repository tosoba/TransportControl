import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:transport_control/util/preferences_util.dart';
import 'package:transport_control/widgets/text_field_app_bar.dart';
import 'package:transport_control/widgets/text_field_app_bar_back_button.dart';

class SettingsPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final searchFieldFocusNode = useFocusNode();
    final searchFieldController = useTextEditingController();
    searchFieldController.addListener(() {});

    final settings = GetIt.instance<RxSharedPreferences>();
    final zoomToLoadedMarkersBounds = useStream(
      settings
          .getBoolStream(Preferences.zoomToLoadedMarkersBounds.key)
          .distinct(),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: TextFieldAppBar(
        textFieldFocusNode: searchFieldFocusNode,
        textFieldController: searchFieldController,
        hint: "Search settings...",
        leading: TextFieldAppBarBackButton(searchFieldFocusNode),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            value: zoomToLoadedMarkersBounds.data ??
                Preferences.zoomToLoadedMarkersBounds.defaultValue,
            title: Text("Zoom to loaded markers' bounds"),
            onChanged: (value) {
              settings.setBool(
                Preferences.zoomToLoadedMarkersBounds.key,
                value,
              );
            },
          )
        ],
      ),
    );
  }
}

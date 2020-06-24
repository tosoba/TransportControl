import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:transport_control/widgets/text_field_app_bar.dart';
import 'package:transport_control/widgets/text_field_app_bar_back_button.dart';

enum LastSearchedPageFilterMode { ALL, LINES, LOCATIONS }

class LastSearchedPage extends HookWidget {
  final LastSearchedPageFilterMode filterMode;

  LastSearchedPage({Key key, @required this.filterMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchFieldFocusNode = useFocusNode();
    final searchFieldController = useTextEditingController();
    searchFieldController.addListener(() {});

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: TextFieldAppBar(
        textFieldFocusNode: searchFieldFocusNode,
        textFieldController: searchFieldController,
        hint: "Search items...",
        leading: TextFieldAppBarBackButton(searchFieldFocusNode),
      ),
      body: Center(child: Text('Last searched')),
    );
  }
}

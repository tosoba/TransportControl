import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

enum LastSearchedPageFilterMode { ALL, LINES, LOCATIONS }

class LastSearchedPage extends HookWidget {
  final LastSearchedPageFilterMode filterMode;

  LastSearchedPage({Key key, @required this.filterMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Center(child: Text('Last searched')),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:transport_control/widgets/circular_icon_button.dart';

class SearchAppBarBackButton extends StatelessWidget {
  final FocusNode _searchFieldFocusNode;

  const SearchAppBarBackButton(
    this._searchFieldFocusNode, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircularButton(
      child: const Icon(
        Icons.arrow_back,
        color: Colors.black,
      ),
      onPressed: () {
        if (_searchFieldFocusNode.hasFocus) {
          _searchFieldFocusNode.unfocus();
        } else {
          Navigator.pop(context);
        }
      },
    );
  }
}

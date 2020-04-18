import 'package:flutter/material.dart';
import 'package:transport_control/widgets/circular_icon_button.dart';

class TextFieldAppBarBackButton extends StatelessWidget {
  final FocusNode _textFieldFocusNode;

  const TextFieldAppBarBackButton(
    this._textFieldFocusNode, {
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
        if (_textFieldFocusNode.hasFocus) {
          _textFieldFocusNode.unfocus();
        } else {
          Navigator.pop(context);
        }
      },
    );
  }
}

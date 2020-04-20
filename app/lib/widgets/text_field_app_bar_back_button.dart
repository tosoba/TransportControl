import 'package:flutter/material.dart';
import 'package:transport_control/widgets/circular_icon_button.dart';

class TextFieldAppBarBackButton extends StatelessWidget {
  final FocusNode _textFieldFocusNode;
  final bool textFieldDisabled;

  const TextFieldAppBarBackButton(
    this._textFieldFocusNode, {
    Key key,
    this.textFieldDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircularButton(
      child: const Icon(
        Icons.arrow_back,
        color: Colors.black,
      ),
      onPressed: () {
        if (_textFieldFocusNode.hasFocus && !textFieldDisabled) {
          _textFieldFocusNode.unfocus();
        } else {
          Navigator.pop(context);
        }
      },
    );
  }
}

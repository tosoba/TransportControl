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
      child: Icon(
        Icons.arrow_back,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
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

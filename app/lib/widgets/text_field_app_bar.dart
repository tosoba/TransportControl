import 'package:flutter/material.dart';

class TextFieldAppBar extends StatefulWidget implements PreferredSizeWidget {
  final TextEditingController textFieldController;
  final FocusNode textFieldFocusNode;
  final Widget leading;
  final Widget trailing;
  final String hint;
  final Function(String) onChanged;

  final Size size = Size.fromHeight(kToolbarHeight + 10.0);

  TextFieldAppBar({
    Key key,
    this.textFieldFocusNode,
    this.leading,
    this.trailing,
    this.hint,
    this.onChanged,
    this.textFieldController,
  }) : super(key: key);

  @override
  _TextFieldAppBarState createState() => _TextFieldAppBarState();

  @override
  Size get preferredSize => size;
}

class _TextFieldAppBarState extends State<TextFieldAppBar> {
  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: widget.size,
      child: Padding(
        padding: EdgeInsets.only(
          left: 15.0,
          right: 15.0,
          top: MediaQuery.of(context).padding.top + 10.0,
        ),
        child: Container(
          child: Row(children: [
            if (widget.leading != null) widget.leading,
            Flexible(child: _textField),
            if (widget.trailing != null) widget.trailing,
          ]),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomRight: const Radius.circular(15.0),
              topRight: const Radius.circular(15.0),
              topLeft: const Radius.circular(15.0),
              bottomLeft: const Radius.circular(15.0),
            ),
            boxShadow: [
              const BoxShadow(
                color: Colors.grey,
                blurRadius: 4.0,
                spreadRadius: 1.0,
              )
            ],
            color: Colors.white,
          ),
          width: double.infinity,
          height: kToolbarHeight,
        ),
      ),
    );
  }

  Widget get _textField {
    return TextField(
      controller: widget.textFieldController,
      focusNode: widget.textFieldFocusNode,
      autofocus: false,
      decoration: InputDecoration(
        hintText: widget.hint,
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey),
      ),
      style: TextStyle(color: Colors.black, fontSize: 16.0),
      onChanged: widget.onChanged,
    );
  }
}

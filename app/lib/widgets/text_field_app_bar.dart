import 'package:flutter/material.dart';

class TextFieldAppBar extends StatefulWidget implements PreferredSizeWidget {
  final TextEditingController textFieldController;
  final FocusNode textFieldFocusNode;
  final Widget leading;
  final Widget trailing;
  final String hint;
  final Function(String) onChanged;
  final bool enabled;
  final bool readOnly;

  final Size size = Size.fromHeight(kToolbarHeight + 10.0);

  TextFieldAppBar({
    Key key,
    this.textFieldFocusNode,
    this.leading,
    this.trailing,
    this.hint,
    this.onChanged,
    this.textFieldController,
    this.enabled = true,
    this.readOnly = false,
  }) : super(key: key);

  @override
  _TextFieldAppBarState createState() => _TextFieldAppBarState();

  @override
  Size get preferredSize => size;

  double heightWithPadding(BuildContext context) {
    return size.height + paddingTop(context);
  }

  double paddingTop(BuildContext context) {
    return MediaQuery.of(context).padding.top + 10.0;
  }
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
          top: widget.paddingTop(context),
        ),
        child: Container(
          child: Row(children: [
            if (widget.leading != null) widget.leading,
            Flexible(child: _textField),
            if (widget.trailing != null) widget.trailing,
          ]),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(const Radius.circular(15.0)),
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
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      decoration: InputDecoration(
        hintText: widget.hint,
        border: InputBorder.none,
        hintStyle: const TextStyle(color: Colors.grey),
      ),
      style: const TextStyle(color: Colors.black, fontSize: 16.0),
      onChanged: widget.onChanged,
    );
  }
}

class SliverTextFieldAppBarDelegate extends SliverPersistentHeaderDelegate {
  final BuildContext context;
  final TextFieldAppBar appBar;

  SliverTextFieldAppBarDelegate(this.context, {@required this.appBar});

  @override
  double get minExtent => appBar.heightWithPadding(context);
  @override
  double get maxExtent => appBar.heightWithPadding(context);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return appBar;
  }

  @override
  bool shouldRebuild(SliverTextFieldAppBarDelegate oldDelegate) {
    return appBar != oldDelegate.appBar;
  }
}

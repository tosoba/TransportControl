import 'package:flutter/material.dart';

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final TextEditingController searchFieldController;
  final FocusNode searchFieldFocusNode;
  final Widget leading;
  final Widget trailing;
  final String hint;
  final Function(String) onChanged;

  final Size size = Size.fromHeight(kToolbarHeight + 10.0);

  SearchAppBar({
    Key key,
    this.searchFieldFocusNode,
    this.leading,
    this.trailing,
    this.hint,
    this.onChanged,
    this.searchFieldController,
  }) : super(key: key);

  @override
  _SearchAppBarState createState() => _SearchAppBarState();

  @override
  Size get preferredSize => size;
}

class _SearchAppBarState extends State<SearchAppBar> {
  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[];
    if (widget.leading != null) {
      widgets.add(widget.leading);
    }
    widgets.add(Flexible(child: _placesSearchField));
    if (widget.trailing != null) {
      widgets.add(widget.trailing);
    }

    return PreferredSize(
      preferredSize: widget.size,
      child: Padding(
        padding: EdgeInsets.only(
          left: 15.0,
          right: 15.0,
          top: MediaQuery.of(context).padding.top + 10.0,
        ),
        child: Container(
          child: Row(children: widgets),
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

  Widget get _placesSearchField {
    return TextField(
      controller: widget.searchFieldController,
      focusNode: widget.searchFieldFocusNode,
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

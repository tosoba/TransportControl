import 'package:flutter/material.dart';

class PreferredSizeWrapped extends StatelessWidget
    implements PreferredSizeWidget {
  final Widget child;
  final Size size;

  const PreferredSizeWrapped({
    Key key,
    @required this.size,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => child;

  @override
  Size get preferredSize => size;
}

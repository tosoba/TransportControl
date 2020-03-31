import 'package:flutter/material.dart';

class SlideTransitionPreferredSizeWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final Animation<Offset> offset;
  final PreferredSizeWidget child;

  const SlideTransitionPreferredSizeWidget({
    Key key,
    @required this.offset,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: offset, child: child);
  }

  @override
  Size get preferredSize => child.preferredSize;
}

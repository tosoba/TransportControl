import 'package:flutter/material.dart';

class PreferredSizeColumn extends Column implements PreferredSizeWidget {
  final List<PreferredSizeWidget> children;

  PreferredSizeColumn({
    Key key,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline textBaseline,
    this.children = const <PreferredSizeWidget>[],
  }) : super(
          children: children,
          key: key,
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          crossAxisAlignment: crossAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
        );

  @override
  Size get preferredSize {
    return Size.fromHeight(
      children
          .map((widget) => widget.preferredSize.height)
          .fold(0, (heightSum, height) => heightSum + height),
    );
  }
}

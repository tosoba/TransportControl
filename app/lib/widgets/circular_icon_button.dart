import 'package:flutter/material.dart';

class CircularButton extends StatelessWidget {
  final void Function() onPressed;
  final Widget child;
  final double radius;

  const CircularButton({
    Key key,
    @required this.onPressed,
    @required this.child,
    this.radius = 36.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      padding: EdgeInsets.zero,
      child: child,
      onPressed: onPressed,
      shape: const CircleBorder(),
      constraints: BoxConstraints.tightFor(width: radius, height: radius),
    );
  }
}

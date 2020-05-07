import 'package:flutter/material.dart';

class CircularTextIconButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final void Function() onTap;
  final Color color;
  final Color splashColor;

  const CircularTextIconButton({
    Key key,
    @required this.text,
    @required this.icon,
    @required this.onTap,
    this.color,
    this.splashColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: const Size(56, 56),
      child: ClipOval(
        child: Material(
          color: color,
          child: InkWell(
            splashColor: splashColor,
            onTap: onTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon),
                Text(text),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class CircularTextIconButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final void Function() onTap;
  final Color color;
  final Color splashColor;
  final TextStyle textStyle;
  final Color iconColor;

  const CircularTextIconButton({
    Key key,
    @required this.text,
    @required this.icon,
    @required this.onTap,
    this.color,
    this.splashColor,
    this.iconColor = Colors.white,
    this.textStyle = const TextStyle(color: Colors.white),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox.fromSize(
      size: const Size(56, 56),
      child: ClipOval(
        child: Material(
          color: color ?? theme.primaryColor,
          child: InkWell(
            splashColor: splashColor ?? theme.splashColor,
            onTap: onTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, color: iconColor),
                Text(text, style: textStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

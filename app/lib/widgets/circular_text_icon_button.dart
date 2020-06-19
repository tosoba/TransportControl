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
    final theme = Theme.of(context);
    final iconAndTextColor =
        theme.brightness == Brightness.dark ? Colors.black : Colors.white;
    return SizedBox.fromSize(
      size: const Size(56, 56),
      child: ClipOval(
        child: Material(
          color: color ?? theme.accentColor,
          child: InkWell(
            splashColor: splashColor ?? theme.splashColor,
            onTap: onTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconAndTextColor),
                Text(text, style: TextStyle(color: iconAndTextColor))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

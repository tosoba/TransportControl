import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

class ShakeTransition extends StatefulWidget {
  final Widget child;
  final StreamController<dynamic> trigger = StreamController();

  ShakeTransition({Key key, this.child}) : super(key: key);

  void shake() => trigger.add(Object());

  @override
  _ShakeTransitionState createState() {
    return _ShakeTransitionState();
  }
}

class _ShakeTransitionState extends State<ShakeTransition>
    with SingleTickerProviderStateMixin {
  AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reset();
      }
    });
    _shakeController.addListener(() => setState(() {}));

    widget.trigger.stream.listen((_) => _shake());
  }

  void _shake() {
    if (_shakeController?.isAnimating == false) {
      _shakeController?.forward();
    }
  }

  @override
  void dispose() {
    widget.trigger.close();
    _shakeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.translation(
        _translationVector(progress: _shakeController.value),
      ),
      child: widget.child,
    );
  }

  Vector3 _translationVector({@required double progress}) {
    return Vector3(sin(progress * pi * 10.0) * 5, 0.0, 0.0);
  }
}

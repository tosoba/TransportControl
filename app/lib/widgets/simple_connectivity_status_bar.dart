import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

class SimpleConnectionStatusBar extends StatefulWidget {
  final Color color;
  final Widget title;
  final double width;
  final double height;
  final Offset endOffset;
  final Offset beginOffset;
  final Duration animationDuration;

  SimpleConnectionStatusBar({
    Key key,
    this.height = 25,
    this.width = double.maxFinite,
    this.color = Colors.redAccent,
    this.endOffset = const Offset(0.0, 0.0),
    this.beginOffset = const Offset(0.0, -1.0),
    this.animationDuration = const Duration(milliseconds: 200),
    this.title = const Text(
      'Please check your internet connection',
      style: TextStyle(color: Colors.white, fontSize: 14),
    ),
  }) : super(key: key);

  _SimpleConnectionStatusBarState createState() =>
      _SimpleConnectionStatusBarState();
}

class _SimpleConnectionStatusBarState extends State<SimpleConnectionStatusBar>
    with SingleTickerProviderStateMixin {
  StreamSubscription<bool> _connectionChangeStream;
  bool _hasConnection = true;
  AnimationController controller;
  Animation<Offset> offset;

  @override
  void initState() {
    Connectivity()
        .checkConnectivity()
        .then((result) => result != ConnectivityResult.none)
        .then(_connectionChanged);

    _connectionChangeStream = Connectivity()
        .onConnectivityChanged
        .map((result) => result != ConnectivityResult.none)
        .listen(_connectionChanged);

    controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    offset = Tween<Offset>(begin: widget.beginOffset, end: widget.endOffset)
        .animate(controller);

    super.initState();
  }

  void _connectionChanged(bool hasConnection) {
    if (_hasConnection == hasConnection) return;
    hasConnection ? controller.reverse() : controller.forward();
    _hasConnection = hasConnection;
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: offset,
      child: Container(
        child: SafeArea(
          bottom: false,
          child: Container(
            color: widget.color,
            width: widget.width,
            height: widget.height,
            child: Center(child: widget.title),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _connectionChangeStream.cancel();
    super.dispose();
  }
}

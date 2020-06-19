import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

enum _LoadingState { idle, loading, success, error }

class LoadingButton extends StatefulWidget {
  final LoadingButtonController controller;
  final VoidCallback onPressed;
  final Widget child;
  final double height;
  final double width;
  final bool animateOnTap;

  LoadingButton({
    Key key,
    @required this.controller,
    @required this.onPressed,
    @required this.child,
    this.height = 56,
    this.width = 56,
    this.animateOnTap = true,
  });

  @override
  State<StatefulWidget> createState() => LoadingButtonState();
}

class LoadingButtonState extends State<LoadingButton>
    with TickerProviderStateMixin {
  AnimationController _buttonController;
  AnimationController _checkButtonControler;

  Animation _squeezeAnimation;
  Animation _bounceAnimation;

  final _loadingState = BehaviorSubject<_LoadingState>.seeded(
    _LoadingState.idle,
  );

  @override
  Widget build(BuildContext context) {
    final check = Container(
      alignment: FractionalOffset.center,
      decoration: BoxDecoration(
        color: Theme.of(context).floatingActionButtonTheme.backgroundColor,
        borderRadius:
            BorderRadius.all(Radius.circular(_bounceAnimation.value / 2)),
      ),
      width: _bounceAnimation.value,
      height: _bounceAnimation.value,
      child: _bounceAnimation.value > 20
          ? Icon(Icons.check, color: Theme.of(context).iconTheme.color)
          : null,
    );

    final cross = Container(
      alignment: FractionalOffset.center,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius:
            BorderRadius.all(Radius.circular(_bounceAnimation.value / 2)),
      ),
      width: _bounceAnimation.value,
      height: _bounceAnimation.value,
      child: _bounceAnimation.value > 20
          ? Icon(Icons.close, color: Theme.of(context).iconTheme.color)
          : null,
    );

    final loader = SizedBox(
      height: widget.height - 25,
      width: widget.height - 25,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        strokeWidth: 2,
      ),
    );

    final childStream = StreamBuilder<_LoadingState>(
      stream: _loadingState,
      builder: (context, snapshot) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: snapshot.data == _LoadingState.loading ? loader : widget.child,
      ),
    );

    final idle = ButtonTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
      minWidth: _squeezeAnimation.value,
      height: widget.height,
      child: RaisedButton(
        padding: const EdgeInsets.all(0),
        child: childStream,
        color: Theme.of(context).accentColor,
        onPressed: widget.onPressed == null ? null : _btnPressed,
      ),
    );

    return Container(
      height: widget.height,
      width: widget.width,
      child: Center(
        child: _loadingState.value == _LoadingState.error
            ? cross
            : _loadingState.value == _LoadingState.success ? check : idle,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _checkButtonControler = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 0,
      end: widget.height,
    ).animate(
      CurvedAnimation(parent: _checkButtonControler, curve: Curves.elasticOut),
    );
    _bounceAnimation.addListener(() {
      setState(() {});
    });

    _squeezeAnimation = Tween<double>(
      begin: widget.width,
      end: widget.height,
    ).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOutCirc),
    );
    _squeezeAnimation.addListener(() {
      setState(() {});
    });

    _squeezeAnimation.addStatusListener((state) {
      if (state == AnimationStatus.completed) {
        widget.onPressed();
      }
    });

    widget.controller?._setListeners(_start, _stop, _success, _error, _reset);
  }

  @override
  void dispose() {
    _buttonController.dispose();
    _checkButtonControler.dispose();
    _loadingState.close();
    super.dispose();
  }

  void _btnPressed() async {
    if (widget.animateOnTap) {
      _start();
    } else {
      widget.onPressed();
    }
  }

  void _start() {
    _loadingState.sink.add(_LoadingState.loading);
    _buttonController.forward();
  }

  void _stop() {
    _loadingState.sink.add(_LoadingState.idle);
    _buttonController.reverse();
  }

  void _success() {
    _loadingState.sink.add(_LoadingState.success);
    _checkButtonControler.forward();
  }

  void _error() {
    _loadingState.sink.add(_LoadingState.error);
    _checkButtonControler.forward();
  }

  void _reset() {
    _loadingState.sink.add(_LoadingState.idle);
    _buttonController.reverse();
    _checkButtonControler.reset();
  }
}

class LoadingButtonController {
  VoidCallback _startListener;
  VoidCallback _stopListener;
  VoidCallback _successListener;
  VoidCallback _errorListener;
  VoidCallback _resetListener;

  void _setListeners(
    VoidCallback startListener,
    VoidCallback stopListener,
    VoidCallback successListener,
    VoidCallback errorListener,
    VoidCallback resetListener,
  ) {
    this._startListener = startListener;
    this._stopListener = stopListener;
    this._successListener = successListener;
    this._errorListener = errorListener;
    this._resetListener = resetListener;
  }

  void start() {
    _startListener();
  }

  void stop() {
    _stopListener();
  }

  void success() {
    _successListener();
  }

  void error() {
    _errorListener();
  }

  void reset() {
    _resetListener();
  }
}

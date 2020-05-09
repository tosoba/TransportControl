import 'package:flutter/material.dart';

class FloatingActionButtonWithTransition extends StatefulWidget {
  final Widget Function() buildPage;

  const FloatingActionButtonWithTransition({
    Key key,
    @required this.buildPage,
  }) : super(key: key);

  @override
  _FloatingActionButtonWithTransitionState createState() {
    return _FloatingActionButtonWithTransitionState();
  }
}

class _FloatingActionButtonWithTransitionState
    extends State<FloatingActionButtonWithTransition> {
  final GlobalKey _fabKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return _buildFab(context, key: _fabKey);
  }

  Widget _buildFab(BuildContext context, {Key key}) {
    return FloatingActionButton(
      elevation: 0,
      backgroundColor: Colors.pink,
      key: key,
      onPressed: () => _onPressed(context),
      child: Icon(Icons.search),
    );
  }

  void _onPressed(BuildContext context) {
    final RenderBox fabRenderBox = _fabKey.currentContext.findRenderObject();
    final fabSize = fabRenderBox.size;
    final fabOffset = fabRenderBox.localToGlobal(Offset.zero);

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return widget.buildPage();
        },
        transitionsBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          return _buildTransition(child, animation, fabSize, fabOffset);
        },
      ),
    );
  }

  Widget _buildTransition(
    Widget page,
    Animation<double> animation,
    Size fabSize,
    Offset fabOffset,
  ) {
    if (animation.value == 1) return page;

    final borderTween = BorderRadiusTween(
      begin: BorderRadius.circular(fabSize.width / 2),
      end: BorderRadius.circular(0.0),
    );
    final sizeTween = SizeTween(
      begin: fabSize,
      end: MediaQuery.of(context).size,
    );
    final offsetTween = Tween<Offset>(
      begin: fabOffset,
      end: Offset.zero,
    );

    final easeInAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeIn,
    );
    final easeAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    );

    final radius = borderTween.evaluate(easeInAnimation);
    final offset = offsetTween.evaluate(animation);
    final size = sizeTween.evaluate(easeInAnimation);

    final transitionFab = Opacity(
      opacity: 1 - easeAnimation.value,
      child: _buildFab(context),
    );

    Widget positionedClippedChild(Widget child) {
      return Positioned(
        width: size.width,
        height: size.height,
        left: offset.dx,
        top: offset.dy,
        child: ClipRRect(borderRadius: radius, child: child),
      );
    }

    return Stack(
      children: [
        positionedClippedChild(page),
        positionedClippedChild(transitionFab),
      ],
    );
  }
}

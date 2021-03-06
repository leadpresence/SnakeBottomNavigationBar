import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/src/theming/snake_bottom_bar_theme.dart';
import 'package:flutter_snake_navigationbar/src/theming/snake_shape.dart';
import 'selection_notifier.dart';

class SnakeView extends StatefulWidget {
  final int itemsCount;
  final SnakeShape shape;
  final double widgetEdgePadding;
  final SelectionNotifier notifier;
  final Duration animationDuration;
  final Duration delayTransition;
  final Curve snakeCurve;
  final double circlePadding;
  final double indicatorHeight;

  const SnakeView({
    @required this.itemsCount,
    @required this.shape,
    @required this.widgetEdgePadding,
    @required this.notifier,
    this.animationDuration = const Duration(milliseconds: 200),
    this.delayTransition = const Duration(milliseconds: 50),
    this.snakeCurve = Curves.easeInOut,
    this.circlePadding = 4,
    this.indicatorHeight = 4,
  });

  @override
  _SnakeViewState createState() => _SnakeViewState();
}

class _SnakeViewState extends State<SnakeView> {
  double left = 0;
  int snakeSize = 1;
  int currentIndex;
  Orientation orientation;
  double oneItemWidth;
  double prevItemWidth;

  bool get isRTL => Directionality.of(context) == TextDirection.rtl;

  @override
  Widget build(BuildContext context) {
    oneItemWidth =
        (MediaQuery.of(context).size.width - widget.widgetEdgePadding) /
            widget.itemsCount;

    widget.notifier.addListener(() {
      if (widget.notifier.lastIndex < widget.notifier.currentIndex) {
        _goRight();
      } else if (widget.notifier.lastIndex > widget.notifier.currentIndex) {
        _goLeft();
      }
      currentIndex = widget.notifier.currentIndex;
    });

    if (currentIndex == null ||
        currentIndex != widget.notifier.currentIndex ||
        orientation != MediaQuery.of(context).orientation ||
        prevItemWidth != oneItemWidth) {
      left = oneItemWidth * widget.notifier.currentIndex;
      currentIndex = widget.notifier.currentIndex;
      orientation = MediaQuery.of(context).orientation;
      prevItemWidth = oneItemWidth;
    }

    final viewPadding = widget.shape.type == SnakeShapeType.circle ||
            widget.shape.centered
        ? EdgeInsets.symmetric(
            vertical: widget.circlePadding,
            horizontal: (oneItemWidth -
                    (kBottomNavigationBarHeight - widget.circlePadding * 2)) /
                2,
          )
        : EdgeInsets.zero;

    final snakeViewWidth =
        widget.shape.type == SnakeShapeType.circle || widget.shape.centered
            ? oneItemWidth * snakeSize - (viewPadding.left + viewPadding.right)
            : oneItemWidth * snakeSize;

    return AnimatedPositioned(
      left: isRTL ? null : left,
      right: isRTL ? left : null,
      duration: widget.animationDuration,
      curve: widget.snakeCurve,
      child: AnimatedPadding(
        duration: widget.animationDuration,
        padding: viewPadding,
        child: AnimatedContainer(
          curve: widget.snakeCurve,
          duration: widget.animationDuration,
          width: snakeViewWidth,
          height: _snakeViewHeight(),
          child: Material(
            shape: _snakeShape(),
            clipBehavior: Clip.antiAlias,
            child: Container(
              decoration: BoxDecoration(
                  gradient: SnakeBottomBarTheme.of(context).snakeGradient),
            ),
          ),
        ),
      ),
    );
  }

  double _snakeViewHeight() {
    switch (widget.shape.type) {
      case SnakeShapeType.circle:
        return kBottomNavigationBarHeight - widget.circlePadding * 2;
        break;
      case SnakeShapeType.rectangle:
        return kBottomNavigationBarHeight;
        break;
      case SnakeShapeType.indicator:
        return widget.indicatorHeight;
        break;
      case SnakeShapeType.custom:
        return widget.shape.centered
            ? kBottomNavigationBarHeight - widget.circlePadding * 2
            : kBottomNavigationBarHeight;
        break;
    }
    return -1;
  }

  ShapeBorder _snakeShape() {
    switch (widget.shape.type) {
      case SnakeShapeType.circle:
        return _getRoundShape(_snakeViewHeight() / 2);
        break;
      default:
        return widget.shape.shape;
        break;
    }
  }

  void _goRight() {
    final newSnakeSize =
        widget.notifier.currentIndex + 1 - widget.notifier.lastIndex;
    setState(() => snakeSize = newSnakeSize);
    Future.delayed(
      widget.animationDuration + widget.delayTransition,
      () => setState(() {
        snakeSize = 1;
        left = oneItemWidth * widget.notifier.currentIndex;
      }),
    );
  }

  void _goLeft() {
    final newSnakeSize =
        (widget.notifier.currentIndex - widget.notifier.lastIndex).abs();
    setState(() {
      left = oneItemWidth * widget.notifier.currentIndex;
      snakeSize = newSnakeSize + 1;
    });
    Future.delayed(
      widget.animationDuration + widget.delayTransition,
      () => setState(() => snakeSize = 1),
    );
  }

  ShapeBorder _getRoundShape(double radius) => RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(radius)));
}

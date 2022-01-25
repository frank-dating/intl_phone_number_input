import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Make animated rainbow vibe for child
class AnimatedGradient extends StatefulWidget {
  /// Default constructor
  const AnimatedGradient({
    Key? key,
    required this.child,
    required this.colors,
    this.begin = Alignment.centerLeft,
    this.end = Alignment.centerRight,
    this.isActive = true,
  }) : super(key: key);

  /// Child what want be rainbow
  final Widget child;

  /// Colors to animate
  final List<Color> colors;

  /// Begin of the gradient
  final Alignment begin;

  /// End of the gradient
  final Alignment end;

  /// Is gradient should be animated
  final bool isActive;

  @override
  _AnimatedGradientState createState() => _AnimatedGradientState();
}

class _AnimatedGradientState extends State<AnimatedGradient>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    if (!widget.isActive) return;
    _animationController
      ..forward()
      ..addStatusListener(
        (status) {
          if (status == AnimationStatus.completed) _animationController.reverse();
          if (status == AnimationStatus.dismissed) _animationController.forward();
        },
      );
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) => ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            begin: widget.begin,
            end: widget.end,
            colors: _generateColors(),
          ).createShader(bounds);
        },
        child: widget.child,
      ),
    );
  }

  List<Color> _generateColors() {
    final list = <Color>[];
    for (var i = 0; i < widget.colors.length; i++) {
      list.add(_getColor(i));
    }

    return list;
  }

  Color _getColor(int index) {
    // '% _colors.length' limits index in list length
    return ColorTween(
      begin: widget.colors[index % widget.colors.length],
      end: widget.colors[(index + 1) % widget.colors.length],
    ).animate(_animationController).value!;
  }
}

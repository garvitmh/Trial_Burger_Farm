import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final Color color;
  final bool animate;

  const AppLogo({
    super.key,
    this.size = 56,
    this.color = Colors.white,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    final logo = SvgPicture.asset(
      'assets/icons/burger_farm_logo.svg',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    if (animate) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutBack,
        builder: (context, value, child) =>
            Transform.scale(scale: value, child: child),
        child: logo,
      );
    }
    return logo;
  }
}

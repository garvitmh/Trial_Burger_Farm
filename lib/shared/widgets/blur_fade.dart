import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/animations/app_animations.dart';
import '../../core/theme/app_durations.dart';

/// BlurFade — port of the Next.js `BlurFade` entry primitive.
///
/// Animates a child from `(opacity: 0, blur: 6px, y: +6)` to its resting state
/// over [duration], with an optional [delay]. Cascadable: stack multiple
/// BlurFades with incrementing delays to reproduce the reference's
/// 100/200/300/400/500ms hero stagger.
///
/// Honors `MediaQueryData.disableAnimations` — when reduced-motion is on,
/// the child appears at full opacity with no blur or offset (single frame).
class BlurFade extends StatefulWidget {
  const BlurFade({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppDurations.blurFade,
    this.curve = AppCurves.springOut,
    this.beginBlur = 6.0,
    this.beginOffset = const Offset(0, 6),
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;

  /// Initial gaussian blur sigma. The reference uses 6px → 0px.
  final double beginBlur;

  /// Initial pixel offset before resting. Reference uses (0, 6).
  final Offset beginOffset;

  @override
  State<BlurFade> createState() => _BlurFadeState();
}

class _BlurFadeState extends State<BlurFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _t =
      CurvedAnimation(parent: _controller, curve: widget.curve);

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce) {
      return widget.child;
    }
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) {
        final progress = _t.value;
        final blur = widget.beginBlur * (1 - progress);
        final offset = widget.beginOffset * (1 - progress);
        return Opacity(
          opacity: progress.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: offset,
            child: blur < 0.1
                ? child
                : ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                    child: child,
                  ),
          ),
        );
      },
    );
  }
}

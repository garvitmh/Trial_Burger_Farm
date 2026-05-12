import 'package:flutter/material.dart';
import '../../core/animations/app_animations.dart';
import '../../core/theme/app_durations.dart';

/// OtpCellEntry — 3D rotate-X entry transform used on each of the 6 OTP cells.
///
/// Reproduces the reference's `digitSlot` motion:
///   scale: 0.15 → 1.0
///   opacity: 0 → 1
///   y: 28 → 0
///   rotateX: -62° → 0°
///   spring 440 / 21  →  ~320ms with springOut curve
///
/// Each cell is delayed by `index * 75ms` after the 60ms global lead-in, so
/// the row appears to flip into existence one digit at a time.
class OtpCellEntry extends StatefulWidget {
  const OtpCellEntry({
    super.key,
    required this.index,
    required this.child,
    this.staggerMs = 75,
    this.initialDelay = const Duration(milliseconds: 60),
  });

  final int index;
  final Widget child;
  final int staggerMs;
  final Duration initialDelay;

  @override
  State<OtpCellEntry> createState() => _OtpCellEntryState();
}

class _OtpCellEntryState extends State<OtpCellEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: AppDurations.otpEnter,
  );
  late final Animation<double> _t =
      CurvedAnimation(parent: _c, curve: AppCurves.springOut);

  @override
  void initState() {
    super.initState();
    final delay = widget.initialDelay +
        Duration(milliseconds: widget.staggerMs * widget.index);
    Future<void>.delayed(delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce) return widget.child;
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) {
        final v = _t.value;
        final scale = 0.15 + 0.85 * v;
        final dy = 28.0 * (1 - v);
        final radians = (-62.0 * (1 - v)) * (3.1415926535 / 180.0);
        final matrix = Matrix4.identity()
          ..setEntry(3, 2, 0.0012) // perspective
          ..translateByDouble(0.0, dy, 0.0, 1.0)
          ..rotateX(radians)
          ..scaleByDouble(scale, scale, 1.0, 1.0);
        return Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: Transform(
            transform: matrix,
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
    );
  }
}

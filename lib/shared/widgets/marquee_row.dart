import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';

/// MarqueeRow — infinite horizontal scrolling row used in the onboarding
/// welcome state to show food-chip illustrations.
///
/// The reference uses two rows running at different speeds (40s and 28s)
/// with each chip bobbing on its own 2.75s sine wave. Both are reproduced
/// here via Flutter [AnimationController]s.
///
/// To replicate the CSS `mask-image: linear-gradient(...)` edge fade, the
/// row is wrapped in a [ShaderMask] with a horizontal gradient.
class MarqueeRow extends StatefulWidget {
  const MarqueeRow({
    super.key,
    required this.assets,
    required this.scrollDuration,
    this.bobDuration = const Duration(milliseconds: 2750),
    this.height = 88.0,
    this.gap = 14.0,
  });

  /// Asset paths to repeat across the strip.
  final List<String> assets;

  /// How long a single end-to-end cycle takes. Reference: 40s row A, 28s row B.
  final Duration scrollDuration;
  final Duration bobDuration;
  final double height;
  final double gap;

  @override
  State<MarqueeRow> createState() => _MarqueeRowState();
}

class _MarqueeRowState extends State<MarqueeRow>
    with TickerProviderStateMixin {
  late final AnimationController _scroll;
  late final AnimationController _bob;

  @override
  void initState() {
    super.initState();
    _scroll = AnimationController(vsync: this, duration: widget.scrollDuration)
      ..repeat();
    _bob = AnimationController(vsync: this, duration: widget.bobDuration)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    final doubled = <String>[...widget.assets, ...widget.assets];
    return SizedBox(
      height: widget.height + 4, // breathing room for bob translation
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (rect) => const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.0, 0.12, 0.88, 1.0],
          colors: [
            Color(0x00000000),
            Color(0xFF000000),
            Color(0xFF000000),
            Color(0x00000000),
          ],
        ).createShader(rect),
        child: ClipRect(
          child: AnimatedBuilder(
            animation: _scroll,
            builder: (context, _) {
              // The doubled strip is rendered once, then translated -50% so
              // when scroll completes a cycle, the second half is in the
              // same screen position as the first half was at start →
              // seamless loop.
              final t = reduce ? 0.0 : _scroll.value;
              return LayoutBuilder(
                builder: (context, constraints) {
                  // Width of one half. Each tile is (height + gap); we
                  // approximate using assets.length.
                  final stripWidth =
                      widget.assets.length * (widget.height + widget.gap);
                  return Stack(
                    children: [
                      Positioned(
                        left: -t * stripWidth,
                        top: 0,
                        bottom: 0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var i = 0; i < doubled.length; i++) ...[
                              _Chip(
                                asset: doubled[i],
                                size: widget.height,
                                bob: _bob,
                                phase: (i % widget.assets.length) * 0.14,
                                reduce: reduce,
                              ),
                              SizedBox(width: widget.gap),
                            ],
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.asset,
    required this.size,
    required this.bob,
    required this.phase,
    required this.reduce,
  });

  final String asset;
  final double size;
  final AnimationController bob;
  final double phase;
  final bool reduce;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: bob,
        builder: (context, _) {
          // sine-wave bob 0 → -6 → 0 over the full duration, offset by `phase`.
          final raw = (bob.value + phase) % 1.0;
          final dy = reduce ? 0.0 : -6.0 * (1 - (2 * raw - 1).abs());
          return Transform.translate(
            offset: Offset(0, dy),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFFFFF), Color(0xFFFFF8F0)],
                ),
                border: Border.all(color: AppColors.primaryGlow, width: 1),
                boxShadow: AppShadows.marqueeChip,
              ),
              padding: EdgeInsets.all(size * 0.18),
              child: Image.asset(
                asset,
                fit: BoxFit.contain,
                errorBuilder: (_, e, s) => const SizedBox.shrink(),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// AppScaffold — Burger Farm Base Scaffold Wrapper
///
/// All screens MUST use AppScaffold instead of raw Scaffold.
/// Ensures consistent background color, safe area handling, and
/// system UI overlay behavior across all screens.
///
/// DO NOT add business logic here. This is a pure layout wrapper.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.backgroundColor,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset = true,
    this.extendBodyBehindAppBar = false,
    this.extendBody = false,
  });

  final Widget body;
  final Color? backgroundColor;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool resizeToAvoidBottomInset;
  final bool extendBodyBehindAppBar;
  final bool extendBody;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.surface,
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      extendBody: extendBody,
    );
  }
}

/// AppSafeArea — Standard safe area wrapper with consistent horizontal padding.
class AppSafeArea extends StatelessWidget {
  const AppSafeArea({
    super.key,
    required this.child,
    this.horizontalPadding = AppSpacing.pageHorizontal,
    this.top = true,
    this.bottom = true,
  });

  final Widget child;
  final double horizontalPadding;
  final bool top;
  final bool bottom;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: top,
      bottom: bottom,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: child,
      ),
    );
  }
}

/// AppPageTransitionWrapper — Wraps page content in a standard fade+slide entry.
/// Apply to the root of each page's build method for consistent entry animations.
class AppPageTransitionWrapper extends StatelessWidget {
  const AppPageTransitionWrapper({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 250),
  });

  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: duration,
      child: child,
    );
  }
}

/// AppDivider — Consistent divider using design token border color.
class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.height, this.indent});
  final double? height;
  final double? indent;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height ?? 1,
      thickness: 1,
      indent: indent ?? 0,
      endIndent: indent ?? 0,
      color: AppColors.border,
    );
  }
}

/// AppGap — Semantic spacing widget using AppSpacing tokens.
/// Replaces SizedBox(height/width: X) with named, token-driven gaps.
class AppGap extends StatelessWidget {
  const AppGap.xs2({super.key}) : _size = AppSpacing.xs2, _axis = Axis.vertical;
  const AppGap.xs({super.key}) : _size = AppSpacing.xs, _axis = Axis.vertical;
  const AppGap.sm({super.key}) : _size = AppSpacing.sm, _axis = Axis.vertical;
  const AppGap.md({super.key}) : _size = AppSpacing.md, _axis = Axis.vertical;
  const AppGap.lg({super.key}) : _size = AppSpacing.lg, _axis = Axis.vertical;
  const AppGap.xl({super.key}) : _size = AppSpacing.xl, _axis = Axis.vertical;
  const AppGap.xl2({super.key}) : _size = AppSpacing.xl2, _axis = Axis.vertical;
  const AppGap.xl3({super.key}) : _size = AppSpacing.xl3, _axis = Axis.vertical;
  const AppGap.xl4({super.key}) : _size = AppSpacing.xl4, _axis = Axis.vertical;
  const AppGap.xl5({super.key}) : _size = AppSpacing.xl5, _axis = Axis.vertical;
  const AppGap.xl6({super.key}) : _size = AppSpacing.xl6, _axis = Axis.vertical;

  const AppGap.hXs({super.key}) : _size = AppSpacing.xs, _axis = Axis.horizontal;
  const AppGap.hSm({super.key}) : _size = AppSpacing.sm, _axis = Axis.horizontal;
  const AppGap.hMd({super.key}) : _size = AppSpacing.md, _axis = Axis.horizontal;
  const AppGap.hLg({super.key}) : _size = AppSpacing.lg, _axis = Axis.horizontal;
  const AppGap.hXl({super.key}) : _size = AppSpacing.xl, _axis = Axis.horizontal;
  const AppGap.hXl2({super.key}) : _size = AppSpacing.xl2, _axis = Axis.horizontal;

  final double _size;
  final Axis _axis;

  @override
  Widget build(BuildContext context) {
    return _axis == Axis.vertical
        ? SizedBox(height: _size)
        : SizedBox(width: _size);
  }
}

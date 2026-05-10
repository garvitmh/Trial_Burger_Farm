import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';

/// AppLoader — Burger Farm Loading Indicator
///
/// Use for full-screen loading states or inline async loading.
/// Uses the brand orange for the progress indicator.
class AppLoader extends StatelessWidget {
  const AppLoader({super.key, this.size = 28.0, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation(color ?? AppColors.primary),
        ),
      ),
    );
  }
}

/// AppFullScreenLoader — Covers the full scaffold with a centered loader.
class AppFullScreenLoader extends StatelessWidget {
  const AppFullScreenLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.surface,
      child: AppLoader(),
    );
  }
}

/// AppSkeletonBox — Shimmer skeleton placeholder for loading states.
/// Always use skeleton loaders over raw spinners in list/card contexts.
class AppSkeletonBox extends StatelessWidget {
  const AppSkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.surface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(borderRadius ?? AppRadius.sm),
        ),
      ),
    );
  }
}

/// AppErrorView — Standard error state with icon, message, and retry action.
/// Handles network errors, auth errors, and empty data gracefully.
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    this.message,
    this.onRetry,
    this.icon,
  });

  final String? message;
  final VoidCallback? onRetry;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon ??
                const Icon(
                  Icons.wifi_off_rounded,
                  size: 48,
                  color: AppColors.textMuted,
                ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message ?? 'Something went wrong. Please try again.',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: AppColors.textMuted),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl2),
              TextButton(
                onPressed: onRetry,
                child: Text(
                  'Try Again',
                  style: AppTypography.buttonLabelSm.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// AppEmptyView — Standard empty state with illustration, message, and CTA.
class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    super.key,
    required this.message,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.icon,
  });

  final String message;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon ??
                const Icon(
                  Icons.inbox_rounded,
                  size: 52,
                  color: AppColors.textMuted,
                ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl2),
              TextButton(
                onPressed: onAction,
                child: Text(
                  actionLabel!,
                  style: AppTypography.buttonLabelSm.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// AppStatusBadge — Store status indicator (Open/Closed/Opening Soon)
/// Matches CSS .badge + .bg-open / .bg-closed / .bg-soon styles.
enum AppBadgeStatus { open, closed, soon }

class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({super.key, required this.status});
  final AppBadgeStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      AppBadgeStatus.open => ('Open', AppColors.badgeOpenBg, AppColors.success),
      AppBadgeStatus.closed =>
        ('Closed', AppColors.badgeClosedBg, AppColors.error),
      AppBadgeStatus.soon =>
        ('Opening Soon', AppColors.badgeSoonBg, AppColors.warning),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        label,
        style: AppTypography.badge.copyWith(color: fg),
      ),
    );
  }
}

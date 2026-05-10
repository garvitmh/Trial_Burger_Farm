import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../presentation/controllers/otp_controller.dart';
import '../../presentation/controllers/otp_timer_service.dart';
import '../../presentation/states/otp_state.dart';

/// OtpVerificationPage — Premium 6-digit OTP verification screen.
///
/// Features:
///   - Pinput-based OTP field with premium focus rings
///   - 30s countdown timer with visual resend button
///   - Auto-focus on mount, SMS autofill preparation
///   - Animated error states, loading states
///   - Staggered entrance animations
class OtpVerificationPage extends ConsumerStatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  ConsumerState<OtpVerificationPage> createState() =>
      _OtpVerificationPageState();
}

class _OtpVerificationPageState extends ConsumerState<OtpVerificationPage> {
  final _pinController = TextEditingController();
  final _pinFocus = FocusNode();
  // Phone number: passed from login via GoRouter extra, fallback for dev
  late final String _phone;

  @override
  void initState() {
    super.initState();
    // Extract phone from GoRouter extra if available
    _phone = (() {
      try {
        final extra = GoRouterState.of(context).extra;
        if (extra is Map && extra['phone'] is String) {
          return extra['phone'] as String;
        }
      } catch (_) {}
      return '+91 XXXXX XXXXX'; // fallback in dev
    })();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    // Auto-focus OTP field after mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _pinFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocus.dispose();
    super.dispose();
  }

  void _onOtpComplete(String code) {
    HapticFeedback.lightImpact();
    ref.read(otpControllerProvider.notifier).verifyOtp(code);
  }

  void _resend() {
    final timerValue = ref.read(otpTimerProvider);
    if (timerValue > 0) return;
    _pinController.clear();
    HapticFeedback.lightImpact();
    // In a real app: ref.read(otpControllerProvider.notifier).resendOtp(phone)
    ref.read(otpTimerProvider.notifier).startCooldown();
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(otpControllerProvider);
    final timerSeconds = ref.watch(otpTimerProvider);
    final isLoading = otpState is OtpStateLoading;
    final hasError = otpState is OtpStateError;
    String? errorMsg;
    if (otpState is OtpStateError) errorMsg = otpState.message;

    // On success, router's auth stream picks it up — no manual push needed
    ref.listen(otpControllerProvider, (prev, next) {
      if (next is OtpStateSuccess && mounted) {
        context.go(RoutePaths.preferences);
      }
    });

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.only(
            left: AppSpacing.pageH,
            right: AppSpacing.pageH,
            top: AppSpacing.xl,
            bottom: bottomInset + AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: AppSpacing.xl),

              // Heading
              Text(
                'Enter the code',
                style: AppTypography.headlineXL.copyWith(
                  color: AppColors.textPrimary,
                ),
              ).animate(delay: 100.ms).slideY(begin: 0.2, end: 0, duration: 500.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: AppSpacing.xs),

              RichText(
                text: TextSpan(
                  style: AppTypography.bodyMd.copyWith(color: AppColors.textMuted),
                  children: [
                    const TextSpan(text: 'We sent a 6-digit code to '),
                    TextSpan(
                      text: _phone,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 160.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: AppSpacing.xxl),

              // OTP Input
              Center(
                child: _OtpPinField(
                  controller: _pinController,
                  focusNode: _pinFocus,
                  hasError: hasError,
                  onCompleted: _onOtpComplete,
                ),
              ).animate(delay: 250.ms)
                  .slideY(begin: 0.15, end: 0, duration: 500.ms)
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: AppSpacing.sm),

              // Error message
              if (hasError)
                Center(
                  child: Text(
                    errorMsg ?? 'Invalid code. Please try again.',
                    style: AppTypography.captionMd.copyWith(
                      color: AppColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0),
                ),

              const SizedBox(height: AppSpacing.xxl),

              // Loading indicator
              if (isLoading)
                Center(
                  child: const CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2.5,
                  ).animate().fadeIn(duration: 200.ms),
                ),

              const SizedBox(height: AppSpacing.xl),

              // Resend timer
              Center(
                child: _ResendTimer(
                  seconds: timerSeconds,
                  onResend: _resend,
                ),
              ).animate(delay: 400.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: AppSpacing.xxl),

              // Verify button (also responds to auto-complete from Pinput)
              _VerifyButton(
                onTap: () => _onOtpComplete(_pinController.text),
                isLoading: isLoading,
                enabled: _pinController.text.length == 6 && !isLoading,
              ).animate(delay: 480.ms).slideY(begin: 0.2, end: 0, duration: 500.ms).fadeIn(duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpPinField extends StatelessWidget {
  const _OtpPinField({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.onCompleted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final ValueChanged<String> onCompleted;

  @override
  Widget build(BuildContext context) {
    final defaultTheme = PinTheme(
      width: 50,
      height: 58,
      textStyle: AppTypography.headlineLg.copyWith(
        color: AppColors.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w800,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
    );

    final focusedTheme = defaultTheme.copyWith(
      decoration: defaultTheme.decoration?.copyWith(
        color: AppColors.surfaceWhite,
        border: Border.all(color: AppColors.primary, width: 2.0),
        boxShadow: AppShadows.inputFocus,
      ),
    );

    final errorTheme = defaultTheme.copyWith(
      textStyle: AppTypography.headlineLg.copyWith(
        color: AppColors.error,
        fontSize: 24,
        fontWeight: FontWeight.w800,
      ),
      decoration: defaultTheme.decoration?.copyWith(
        border: Border.all(color: AppColors.error, width: 1.5),
        color: AppColors.error.withValues(alpha: 0.04),
      ),
    );

    return Semantics(
      label: 'OTP input field, 6 digits',
      child: Pinput(
        length: 6,
        controller: controller,
        focusNode: focusNode,
        defaultPinTheme: defaultTheme,
        focusedPinTheme: focusedTheme,
        errorPinTheme: errorTheme,
        forceErrorState: hasError,
        showCursor: true,
        // SMS autofill prep: declares this field as a one-time code
        autofillHints: const [AutofillHints.oneTimeCode],
        keyboardType: TextInputType.number,
        cursor: Container(
          width: 2,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        onCompleted: onCompleted,
        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
        animationCurve: const Cubic(0.16, 1, 0.3, 1),
        animationDuration: const Duration(milliseconds: 180),
      ),
    );
  }
}

class _ResendTimer extends StatelessWidget {
  const _ResendTimer({required this.seconds, required this.onResend});
  final int seconds;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    if (seconds > 0) {
      return RichText(
        text: TextSpan(
          style: AppTypography.bodyMd.copyWith(color: AppColors.textMuted),
          children: [
            const TextSpan(text: "Resend code in "),
            TextSpan(
              text: '${seconds}s',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }
    return GestureDetector(
      onTap: onResend,
      child: Text(
        'Resend OTP',
        style: AppTypography.buttonLabel.copyWith(
          color: AppColors.primary,
          fontSize: 15,
        ),
      ),
    );
  }
}

class _VerifyButton extends StatelessWidget {
  const _VerifyButton({
    required this.onTap,
    required this.isLoading,
    required this.enabled,
  });
  final VoidCallback onTap;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.55,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: double.infinity,
          height: AppSpacing.buttonHeight,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.button),
            boxShadow: enabled ? AppShadows.brandGlow : null,
          ),
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Verify & Continue',
                  style: AppTypography.buttonLabel.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }
}

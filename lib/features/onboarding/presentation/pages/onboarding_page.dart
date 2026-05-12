import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/animations/app_animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_durations.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../features/auth/domain/entities/auth_state.dart';
import '../../../../features/auth/domain/value_objects/auth_failures.dart';
import '../../../../features/auth/presentation/controllers/auth_session_manager.dart';
import '../../../../features/auth/presentation/controllers/otp_controller.dart';
import '../../../../features/auth/presentation/controllers/otp_timer_service.dart';
import '../../../../features/auth/presentation/states/otp_state.dart';
import '../../../../shared/widgets/blur_fade.dart';
import '../../../../shared/widgets/marquee_row.dart';
import '../../../../shared/widgets/otp_cell_entry.dart';
import '../../data/onboarding_prefs_service.dart';

/// Which morph state the onboarding flow renders.
///
/// The same `OnboardingPage` widget hosts all three states; the route a
/// user enters via decides the `initialStep`. Internal transitions
/// update this without changing the URL.
enum OnboardingFlowStep { welcome, phone, otp }

/// OnboardingPage — single-page morph hosting the entire pre-home auth
/// experience (welcome → phone → otp). Reconstructed from the Next.js
/// reference's `app/onboarding/page.tsx` + `OnboardingAuthPanel`.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key, this.initialStep = OnboardingFlowStep.welcome});

  final OnboardingFlowStep initialStep;

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  late OnboardingFlowStep _step = widget.initialStep;
  final _phoneController = TextEditingController();
  String _phoneE164 = '';
  bool _googleLoading = false;
  bool _guestLoading = false;
  // Audit fix I-4: `_sendingOtp` tracks the in-flight phone→codeSent window.
  // While true, the Send OTP button shows a spinner. The `ref.listen` in
  // `build()` advances to the OTP step only when `OtpController` transitions
  // OtpStateLoading → OtpStateInitial (signaling `codeSent` fired), or
  // surfaces the error inline if it transitions to OtpStateError.
  bool _sendingOtp = false;
  String? _phoneError;

  static final RegExp _indianMobile = RegExp(r'^[6-9]\d{9}$');

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // ─── State transitions ──────────────────────────────────────────────────

  void _setStep(OnboardingFlowStep next) {
    if (!mounted) return;
    setState(() => _step = next);
  }

  void _sendOtp() {
    if (_sendingOtp) return;
    final raw = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
    if (!_indianMobile.hasMatch(raw)) {
      setState(() => _phoneError =
          'Please enter a valid 10-digit Indian mobile number.');
      return;
    }
    HapticFeedback.lightImpact();
    setState(() {
      _phoneError = null;
      _sendingOtp = true;
      _phoneE164 = '+91$raw';
    });
    // Fire-and-forget. The `ref.listen` in build() reacts to controller
    // state to advance the step or surface a verificationFailed error.
    ref.read(otpControllerProvider.notifier).sendOtp(_phoneE164);
  }

  Future<void> _continueAsGuest() async {
    if (_guestLoading) return;
    HapticFeedback.lightImpact();
    setState(() => _guestLoading = true);
    try {
      await ref.read(authStateProvider.notifier).signInAsGuest();
      // On success: auth stream flips state → router redirects automatically.
      // No need to navigate manually. But for users where shell routes are
      // gated by onboarding-complete, also mark onboarding complete here
      // (the listener does this too, but earlier is fine).
      ref.read(onboardingCompleteProvider.notifier).markComplete();
    } on AuthFailure catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } finally {
      if (mounted) setState(() => _guestLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_googleLoading) return;
    HapticFeedback.lightImpact();
    setState(() => _googleLoading = true);
    try {
      await ref.read(authStateProvider.notifier).signInWithGoogle();
      // Success → auth stream flips state, router redirects.
    } on SignInCancelledFailure {
      // Silent.
    } on AuthFailure catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  // ─── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // When auth succeeds (via OTP or Google), mark onboarding complete so the
    // next cold-start doesn't put the user back here.
    ref.listen<AsyncValue<AuthState>>(authStateProvider, (prev, next) {
      next.whenData((value) {
        if (value is AuthStateAuthenticated) {
          ref.read(onboardingCompleteProvider.notifier).markComplete();
        }
      });
    });

    // Audit fix I-4: advance to OTP step only when codeSent fires (Loading
    // → Initial transition), or surface error inline if verificationFailed
    // fires (Loading → Error transition).
    ref.listen<OtpState>(otpControllerProvider, (prev, next) {
      if (!_sendingOtp) return;
      if (next is OtpStateInitial && prev is OtpStateLoading) {
        if (!mounted) return;
        setState(() => _sendingOtp = false);
        _setStep(OnboardingFlowStep.otp);
      } else if (next is OtpStateError) {
        if (!mounted) return;
        setState(() {
          _sendingOtp = false;
          _phoneError = next.message;
        });
      }
    });

    final heroCollapsed = _step != OnboardingFlowStep.welcome;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _OnboardingHero(
              step: _step,
              phoneMasked: _phoneE164,
              collapsed: heroCollapsed,
            ),
            _MarqueeZone(collapsed: heroCollapsed),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                reverse: true,
                padding: EdgeInsets.only(bottom: bottomInset),
                child: _AuthPanel(
                  step: _step,
                  phoneE164: _phoneE164,
                  phoneController: _phoneController,
                  phoneError: _phoneError,
                  googleLoading: _googleLoading,
                  sendingOtp: _sendingOtp,
                  onContinueWithPhone: () => _setStep(OnboardingFlowStep.phone),
                  onSendOtp: _sendOtp,
                  onGoogle: _signInWithGoogle,
                  onAppleStub: () {},
                  onGuestContinue: _continueAsGuest,
                  onBackToWelcome: () {
                    setState(() {
                      _step = OnboardingFlowStep.welcome;
                      _phoneError = null;
                    });
                  },
                  onEditNumber: () => _setStep(OnboardingFlowStep.phone),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hero (logo + morphing copy) ───────────────────────────────────────────

class _OnboardingHero extends StatelessWidget {
  const _OnboardingHero({
    required this.step,
    required this.phoneMasked,
    required this.collapsed,
  });

  final OnboardingFlowStep step;
  final String phoneMasked;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageH,
        AppSpacing.xl,
        AppSpacing.pageH,
        AppSpacing.sm,
      ),
      child: Column(
        children: [
          // Logo shrinks 0.72x on non-welcome states.
          AnimatedScale(
            duration: AppDurations.heroMorph,
            curve: AppCurves.springOut,
            scale: collapsed ? 0.72 : 1.0,
            child: AnimatedSlide(
              duration: AppDurations.heroMorph,
              curve: AppCurves.springOut,
              offset: collapsed ? const Offset(0, -0.06) : Offset.zero,
              child: BlurFade(
                delay: const Duration(milliseconds: 100),
                child: Image.asset(
                  'assets/images/brand/logo.png',
                  width: 96,
                  height: 96,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Hero copy — animates via swap when step changes.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: AppCurves.springOut,
            switchOutCurve: AppCurves.material,
            transitionBuilder: (child, anim) {
              final slide = Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(anim);
              return FadeTransition(
                opacity: anim,
                child: SlideTransition(position: slide, child: child),
              );
            },
            child: _HeroCopy(
              key: ValueKey(step),
              step: step,
              phoneMasked: phoneMasked,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({super.key, required this.step, required this.phoneMasked});
  final OnboardingFlowStep step;
  final String phoneMasked;

  @override
  Widget build(BuildContext context) {
    switch (step) {
      case OnboardingFlowStep.welcome:
        return Column(
          children: [
            Text(
              'Welcome to the official\nBurger Farm app',
              textAlign: TextAlign.center,
              style: AppTypography.displayHeroLg.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Farm-fresh cravings, delivered fast.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyLg.copyWith(color: AppColors.textMuted),
            ),
          ],
        );
      case OnboardingFlowStep.phone:
        return Column(
          children: [
            Text(
              'Sign in with phone',
              textAlign: TextAlign.center,
              style: AppTypography.displayHeroMd.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "We'll text you a secure one-time passcode.",
              textAlign: TextAlign.center,
              style: AppTypography.bodyMd.copyWith(color: AppColors.textMuted),
            ),
          ],
        );
      case OnboardingFlowStep.otp:
        return Column(
          children: [
            Text(
              'Almost there',
              textAlign: TextAlign.center,
              style: AppTypography.displayHeroMd.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text.rich(
              TextSpan(
                style: AppTypography.bodyMd.copyWith(color: AppColors.textMuted),
                children: [
                  const TextSpan(text: 'Sent to '),
                  TextSpan(
                    text: _maskPhone(phoneMasked),
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
    }
  }

  static String _maskPhone(String e164) {
    final digits = e164.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 6) return digits.isEmpty ? 'your number' : digits;
    final last2 = digits.substring(digits.length - 2);
    final first2 = digits.substring(0, digits.length - 8 < 2 ? 2 : digits.length - 8);
    return '$first2••••$last2';
  }
}

// ─── Marquee zone (collapses on non-welcome states) ────────────────────────

class _MarqueeZone extends StatelessWidget {
  const _MarqueeZone({required this.collapsed});
  final bool collapsed;

  static const _baseStrip = [
    'assets/images/onboarding/chip-burger.png',
    'assets/images/onboarding/chip-fries.png',
    'assets/images/onboarding/chip-drink.png',
    'assets/images/onboarding/chip-wrap.png',
    'assets/images/onboarding/chip-box.png',
    'assets/images/onboarding/chip-shake.png',
    'assets/images/onboarding/chip-harvest.png',
  ];
  static const _altStrip = [
    'assets/images/onboarding/chip-wrap.png',
    'assets/images/onboarding/chip-box.png',
    'assets/images/onboarding/chip-shake.png',
    'assets/images/onboarding/chip-harvest.png',
    'assets/images/onboarding/chip-burger.png',
    'assets/images/onboarding/chip-fries.png',
    'assets/images/onboarding/chip-drink.png',
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.heroMorph,
      curve: AppCurves.springOut,
      height: collapsed ? 0 : 220,
      child: AnimatedOpacity(
        duration: AppDurations.heroMorph,
        opacity: collapsed ? 0 : 1,
        child: ClipRect(
          child: OverflowBox(
            maxHeight: 220,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'FROM THE FARM LANE',
                  style: AppTypography.decorMicro.copyWith(
                    color: AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const RepaintBoundary(
                  child: MarqueeRow(
                    assets: _baseStrip,
                    scrollDuration: AppDurations.marqueeSlow,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const RepaintBoundary(
                  child: MarqueeRow(
                    assets: _altStrip,
                    scrollDuration: AppDurations.marqueeFast,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Auth panel ────────────────────────────────────────────────────────────

class _AuthPanel extends StatelessWidget {
  const _AuthPanel({
    required this.step,
    required this.phoneE164,
    required this.phoneController,
    required this.phoneError,
    required this.googleLoading,
    required this.sendingOtp,
    required this.onContinueWithPhone,
    required this.onSendOtp,
    required this.onGoogle,
    required this.onAppleStub,
    required this.onGuestContinue,
    required this.onBackToWelcome,
    required this.onEditNumber,
  });

  final OnboardingFlowStep step;
  final String phoneE164;
  final TextEditingController phoneController;
  final String? phoneError;
  final bool googleLoading;
  final bool sendingOtp;
  final VoidCallback onContinueWithPhone;
  final VoidCallback onSendOtp;
  final VoidCallback onGoogle;
  final VoidCallback onAppleStub;
  final VoidCallback onGuestContinue;
  final VoidCallback onBackToWelcome;
  final VoidCallback onEditNumber;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl4,
        AppSpacing.lg,
        AppSpacing.xl4,
        AppSpacing.xl4,
      ),
      child: AnimatedSwitcher(
        duration: AppDurations.panelEnter,
        switchInCurve: AppCurves.springOut,
        switchOutCurve: AppCurves.material,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        ),
        child: switch (step) {
          OnboardingFlowStep.welcome => _WelcomePanel(
              key: const ValueKey('welcome'),
              onContinueWithPhone: onContinueWithPhone,
              onGoogle: onGoogle,
              onApple: onAppleStub,
              onGuestContinue: onGuestContinue,
              googleLoading: googleLoading,
            ),
          OnboardingFlowStep.phone => _PhonePanel(
              key: const ValueKey('phone'),
              controller: phoneController,
              error: phoneError,
              sending: sendingOtp,
              onSendOtp: onSendOtp,
              onBack: onBackToWelcome,
            ),
          OnboardingFlowStep.otp => _OtpPanel(
              key: const ValueKey('otp'),
              phoneE164: phoneE164,
              onEditNumber: onEditNumber,
            ),
        },
      ),
    );
  }
}

// ─── Welcome panel ─────────────────────────────────────────────────────────

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel({
    super.key,
    required this.onContinueWithPhone,
    required this.onGoogle,
    required this.onApple,
    required this.onGuestContinue,
    required this.googleLoading,
  });

  final VoidCallback onContinueWithPhone;
  final VoidCallback onGoogle;
  final VoidCallback onApple;
  final VoidCallback onGuestContinue;
  final bool googleLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlurFade(
          delay: const Duration(milliseconds: 240),
          child: _PrimaryCta(
            label: 'Continue with Phone',
            onTap: onContinueWithPhone,
            leading: const Icon(Icons.phone_rounded,
                color: Colors.white, size: 18),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const _OrDivider(),
        const SizedBox(height: AppSpacing.md),
        BlurFade(
          delay: const Duration(milliseconds: 360),
          child: Row(
            children: [
              Expanded(
                child: _SocialButton(
                  label: 'Google',
                  loading: googleLoading,
                  onTap: onGoogle,
                  filled: false,
                  iconBuilder: () => _GoogleGlyph(),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _SocialButton(
                  label: 'Apple',
                  loading: false,
                  onTap: onApple,
                  filled: true,
                  iconBuilder: () => const Icon(
                    Icons.apple_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        BlurFade(
          delay: const Duration(milliseconds: 440),
          child: GestureDetector(
            onTap: onGuestContinue,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Continue as Guest',
                    style: AppTypography.buttonLabel.copyWith(
                      color: AppColors.primary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        BlurFade(
          delay: const Duration(milliseconds: 480),
          child: Text.rich(
            TextSpan(
              style: AppTypography.captionMd.copyWith(
                color: AppColors.textMuted,
                height: 1.5,
              ),
              children: [
                const TextSpan(text: 'By continuing you agree to our '),
                TextSpan(
                  text: 'Terms',
                  style: AppTypography.captionMd.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(text: ' & '),
                TextSpan(
                  text: 'Privacy',
                  style: AppTypography.captionMd.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

// ─── Phone panel ───────────────────────────────────────────────────────────

class _PhonePanel extends StatelessWidget {
  const _PhonePanel({
    super.key,
    required this.controller,
    required this.error,
    required this.sending,
    required this.onSendOtp,
    required this.onBack,
  });

  final TextEditingController controller;
  final String? error;
  final bool sending;
  final VoidCallback onSendOtp;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BackChip(label: 'Back', onTap: onBack),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'MOBILE NUMBER',
          style: AppTypography.formLabel.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: AppSpacing.sm),
        AutofillGroup(
          child: _PhoneInput(controller: controller),
        ),
        const SizedBox(height: 6),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs),
            child: Text(
              error!,
              style: AppTypography.captionMd.copyWith(color: AppColors.error),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs),
            child: Text(
              "We'll text you a one-time code. Std. rates may apply.",
              style: AppTypography.captionMd.copyWith(color: AppColors.textMuted),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        // Trust badge — judgment-call keep per briefing decision 2.
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.12)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield_outlined, size: 14, color: AppColors.success),
              const SizedBox(width: 6),
              Text(
                'Secure login. No spam, ever.',
                style: AppTypography.captionMd.copyWith(color: AppColors.success),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _PrimaryCta(
          label: 'Send OTP',
          onTap: onSendOtp,
          loading: sending,
        ),
      ],
    );
  }
}

class _PhoneInput extends StatelessWidget {
  const _PhoneInput({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.ctaLg),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.md),
          _IndiaFlagBadge(),
          const SizedBox(width: 8),
          Text(
            '+91',
            style: AppTypography.inputDisplay.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(width: 1.2, height: 28, color: AppColors.border),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Semantics(
              label: 'Phone number',
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                maxLength: 10,
                autofillHints: const [AutofillHints.telephoneNumberNational],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                style: AppTypography.inputDisplay.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '98765 43210',
                  hintStyle: AppTypography.inputDisplay.copyWith(
                    color: AppColors.textMuted.withValues(alpha: 0.45),
                  ),
                  border: InputBorder.none,
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
        ],
      ),
    );
  }
}

class _IndiaFlagBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        width: 24,
        height: 16,
        child: CustomPaint(painter: _IndiaFlagPainter()),
      ),
    );
  }
}

class _IndiaFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height / 3;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, h),
        Paint()..color = const Color(0xFFFF9933));
    canvas.drawRect(Rect.fromLTWH(0, h, size.width, h),
        Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(0, h * 2, size.width, h),
        Paint()..color = const Color(0xFF138808));
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(c, 3, Paint()..color = const Color(0xFF000080));
  }

  @override
  bool shouldRepaint(_IndiaFlagPainter old) => false;
}

// ─── OTP panel ─────────────────────────────────────────────────────────────

class _OtpPanel extends ConsumerStatefulWidget {
  const _OtpPanel({
    super.key,
    required this.phoneE164,
    required this.onEditNumber,
  });

  /// The phone number that was used to send the current OTP. Required so
  /// the Resend tap can re-invoke `OtpController.resendOtp` correctly.
  final String phoneE164;
  final VoidCallback onEditNumber;

  @override
  ConsumerState<_OtpPanel> createState() => _OtpPanelState();
}

class _OtpPanelState extends ConsumerState<_OtpPanel> {
  final List<TextEditingController> _cells =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focus = List.generate(6, (_) => FocusNode());

  /// Audit fix I-6: the auto-verify Timer is cancelled and re-scheduled
  /// whenever the cell content changes, so backspacing from the 6th cell
  /// before the verify delay elapses doesn't fire a stale verify call.
  Timer? _verifyTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _verifyTimer?.cancel();
    for (final c in _cells) {
      c.dispose();
    }
    for (final f in _focus) {
      f.dispose();
    }
    super.dispose();
  }

  String get _joined => _cells.map((c) => c.text).join();

  void _onCellChanged(int i, String value) {
    // Audit fix I-6: cancel any pending verify before mutating the row.
    _verifyTimer?.cancel();
    _verifyTimer = null;

    final d = value.replaceAll(RegExp(r'\D'), '');
    if (d.length > 1) {
      // Paste path.
      _distributePaste(d);
      return;
    }
    _cells[i].text = d;
    _cells[i].selection = TextSelection.fromPosition(
      TextPosition(offset: d.length),
    );
    if (d.isNotEmpty) {
      HapticFeedback.selectionClick();
      if (i < 5) {
        _focus[i + 1].requestFocus();
      } else {
        _focus[i].unfocus();
        _maybeVerify();
      }
    }
    setState(() {});
  }

  void _distributePaste(String digits) {
    final str = digits.substring(0, digits.length.clamp(0, 6));
    for (var j = 0; j < 6; j++) {
      _cells[j].text = j < str.length ? str[j] : '';
    }
    final last = (str.length - 1).clamp(0, 5);
    _focus[last].requestFocus();
    setState(() {});
    if (str.length == 6) _maybeVerify();
  }

  void _maybeVerify() {
    final code = _joined;
    if (code.length != 6) return;
    _verifyTimer?.cancel();
    _verifyTimer = Timer(AppDurations.verifyDelay, () {
      if (!mounted) return;
      ref.read(otpControllerProvider.notifier).verifyOtp(code);
    });
  }

  void _clearCells() {
    _verifyTimer?.cancel();
    _verifyTimer = null;
    for (final c in _cells) {
      c.text = '';
    }
    _focus[0].requestFocus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<OtpState>(otpControllerProvider, (prev, next) {
      if (next is OtpStateSuccess) {
        HapticFeedback.mediumImpact();
      } else if (next is OtpStateError) {
        HapticFeedback.heavyImpact();
        _clearCells();
      }
    });

    final state = ref.watch(otpControllerProvider);
    final timer = ref.watch(otpTimerProvider);
    final isError = state is OtpStateError;
    final hasCode = _joined.length == 6;
    final isSending = state is OtpStateLoading && !hasCode;
    final isVerifying = hasCode || state is OtpStateLoading;
    final errorMessage = state is OtpStateError ? state.message : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BackChip(label: 'Edit number', onTap: widget.onEditNumber),
        const SizedBox(height: AppSpacing.lg),
        AutofillGroup(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (i) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 5 ? 8 : 0),
                  child: OtpCellEntry(
                    index: i,
                    child: _OtpCell(
                      controller: _cells[i],
                      focusNode: _focus[i],
                      isError: isError,
                      isFirst: i == 0,
                      onChanged: (v) => _onCellChanged(i, v),
                      onBackspaceEmpty: () {
                        if (i > 0) {
                          _cells[i - 1].text = '';
                          _focus[i - 1].requestFocus();
                          setState(() {});
                        }
                      },
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (errorMessage != null)
          Center(
            child: Text(
              errorMessage,
              style: AppTypography.captionMd.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          )
        else if (isSending)
          Center(
            child: Text(
              'Sending code…',
              style: AppTypography.actionSm.copyWith(color: AppColors.textMuted),
            ),
          )
        else if (isVerifying)
          Center(
            child: Text(
              'Verifying…',
              style: AppTypography.actionSm.copyWith(color: AppColors.success),
            ),
          ),
        const SizedBox(height: AppSpacing.xl),
        Center(
          child: timer > 0
              ? Text.rich(
                  TextSpan(
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.textMuted,
                    ),
                    children: [
                      const TextSpan(text: 'Resend code in '),
                      TextSpan(
                        text: '${timer}s',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )
              : GestureDetector(
                  onTap: () {
                    if (state is OtpStateLoading) return;
                    if (widget.phoneE164.isEmpty) return;
                    HapticFeedback.lightImpact();
                    _clearCells();
                    ref
                        .read(otpControllerProvider.notifier)
                        .resendOtp(widget.phoneE164);
                  },
                  child: Text(
                    'Resend OTP',
                    style: AppTypography.actionSm.copyWith(
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

/// Audit fix I-7: was a StatelessWidget that allocated a `FocusNode` inline
/// every build. With six cells × frequent rebuilds, the leaked nodes
/// accumulated. Now stateful with `_keyboardFocus` disposed in `dispose()`.
class _OtpCell extends StatefulWidget {
  const _OtpCell({
    required this.controller,
    required this.focusNode,
    required this.isError,
    required this.isFirst,
    required this.onChanged,
    required this.onBackspaceEmpty,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isError;
  final bool isFirst;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspaceEmpty;

  @override
  State<_OtpCell> createState() => _OtpCellState();
}

class _OtpCellState extends State<_OtpCell> {
  late final FocusNode _keyboardFocus = FocusNode(skipTraversal: true);

  @override
  void dispose() {
    _keyboardFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filled = widget.controller.text.isNotEmpty;
    return AnimatedContainer(
      duration: AppDurations.normal,
      curve: AppCurves.material,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.surfaceWhite, AppColors.surface],
        ),
        borderRadius: BorderRadius.circular(AppRadius.cellLg),
        border: Border.all(
          width: 2,
          color: widget.isError
              ? AppColors.error
              : filled
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : AppColors.border,
        ),
        boxShadow: filled ? AppShadows.otpCellActive : AppShadows.soft,
      ),
      alignment: Alignment.center,
      child: KeyboardListener(
        focusNode: _keyboardFocus,
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              widget.controller.text.isEmpty) {
            widget.onBackspaceEmpty();
          }
        },
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          textAlign: TextAlign.center,
          maxLength: 1,
          autofillHints:
              widget.isFirst ? const [AutofillHints.oneTimeCode] : null,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          style: AppTypography.otpDigit.copyWith(
            color: widget.isError ? AppColors.error : AppColors.textPrimary,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: '',
            isDense: true,
          ),
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}

// ─── Shared sub-widgets ────────────────────────────────────────────────────

class _BackChip extends StatelessWidget {
  const _BackChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.brandLight,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.chevron_left_rounded,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.actionSm.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryCta extends StatefulWidget {
  const _PrimaryCta({
    required this.label,
    required this.onTap,
    this.leading,
    this.loading = false,
  });
  final String label;
  final VoidCallback onTap;
  final Widget? leading;
  final bool loading;

  @override
  State<_PrimaryCta> createState() => _PrimaryCtaState();
}

class _PrimaryCtaState extends State<_PrimaryCta>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press =
      AnimationController(vsync: this, duration: AppDurations.fast);
  late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 0.97)
      .animate(CurvedAnimation(parent: _press, curve: AppCurves.material));

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.loading;
    return GestureDetector(
      onTapDown: disabled ? null : (_) => _press.forward(),
      onTapUp: disabled
          ? null
          : (_) {
              _press.reverse();
              HapticFeedback.lightImpact();
              widget.onTap();
            },
      onTapCancel: () => _press.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: AnimatedOpacity(
          duration: AppDurations.standard,
          opacity: disabled ? 0.85 : 1,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.ctaLg),
              boxShadow: AppShadows.brandGlow,
            ),
            alignment: Alignment.center,
            child: widget.loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.label,
                        style: AppTypography.buttonLabelLg.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      if (widget.leading != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        widget.leading!,
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.border)),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'OR',
          style: AppTypography.labelMicro.copyWith(
            color: AppColors.textMuted.withValues(alpha: 0.6),
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Container(height: 1, color: AppColors.border)),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.loading,
    required this.onTap,
    required this.filled,
    required this.iconBuilder,
  });
  final String label;
  final bool loading;
  final VoidCallback onTap;
  final bool filled;
  final Widget Function() iconBuilder;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: filled ? AppColors.textPrimary : AppColors.surfaceWhite,
          border: filled ? null : Border.all(color: AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(AppRadius.ctaLg),
          boxShadow: filled ? null : AppShadows.soft,
        ),
        alignment: Alignment.center,
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  iconBuilder(),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    label,
                    style: AppTypography.buttonLabel.copyWith(
                      color: filled ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GoogleGlyph extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleGlyphPainter()),
    );
  }
}

class _GoogleGlyphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paints = [
      Paint()..color = const Color(0xFF4285F4),
      Paint()..color = const Color(0xFF34A853),
      Paint()..color = const Color(0xFFFBBC05),
      Paint()..color = const Color(0xFFEA4335),
    ];
    const sweeps = [
      [1.5708, 1.5708],
      [3.1416, 1.5708],
      [4.7124, 1.5708],
      [0.0, 1.5708],
    ];
    for (var i = 0; i < 4; i++) {
      final p = paints[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawArc(rect, sweeps[i][0], sweeps[i][1], false, p);
    }
  }

  @override
  bool shouldRepaint(_GoogleGlyphPainter old) => false;
}

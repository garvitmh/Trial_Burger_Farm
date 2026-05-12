import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../shared/widgets/brand_painters.dart';
import '../../domain/value_objects/auth_failures.dart';
import '../controllers/auth_session_manager.dart';
import '../controllers/otp_controller.dart';

/// LoginPage — Premium phone-auth entry screen.
///
/// Layout: White dot-pattern top panel (30%) + bottom sheet (70%).
/// Features: India +91 flag prefix, phone input, Send OTP CTA,
///           Google/Apple social logins, Continue as Guest, legal footer.
/// Keyboard-safe: uses SingleChildScrollView + bottom inset padding.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _phoneController = TextEditingController();
  final _phoneFocus = FocusNode();
  final bool _isLoading = false;
  bool _googleLoading = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  void _sendOtp() {
    final national = _phoneController.text.trim();
    if (national.length < 10) return;
    HapticFeedback.lightImpact();
    final e164 = '+91$national';
    // Fire the actual phone-auth call so verificationId is populated before
    // the OTP page mounts. The controller transitions through Loading and
    // back to Initial in its codeSent callback; the OTP page consumes it
    // from there.
    ref.read(otpControllerProvider.notifier).sendOtp(e164);
    context.push(RoutePaths.otpVerification, extra: {'phone': e164});
  }

  void _continueAsGuest() {
    HapticFeedback.lightImpact();
    context.go(RoutePaths.preferences);
  }

  Future<void> _signInWithGoogle() async {
    if (_googleLoading) return;
    HapticFeedback.lightImpact();
    setState(() => _googleLoading = true);
    try {
      await ref.read(authStateProvider.notifier).signInWithGoogle();
      // On success the auth stream flips state to Authenticated and the
      // router redirects automatically — no navigation needed here.
    } on SignInCancelledFailure {
      // Silent — user dismissed the picker.
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

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ─── Top panel with dot pattern ────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.30,
            child: _TopPatternPanel(),
          ),

          // ─── Bottom content sheet ───────────────────────────────────────────
          Positioned.fill(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.30 - 20),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadius.sheet),
                      ),
                      boxShadow: AppShadows.float,
                    ),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.only(
                        left: AppSpacing.pageH,
                        right: AppSpacing.pageH,
                        top: AppSpacing.xl,
                        bottom: bottomInset + AppSpacing.xl,
                      ),
                      child: _LoginSheetContent(
                        phoneController: _phoneController,
                        phoneFocus: _phoneFocus,
                        isLoading: _isLoading || _googleLoading,
                        onSendOtp: _sendOtp,
                        onGoogleSignIn: _signInWithGoogle,
                        onAppleSignIn: () {},
                        onGuestContinue: _continueAsGuest,
                      ),
                    ),
                  ).animate().slideY(
                        begin: 0.10,
                        end: 0,
                        duration: 700.ms,
                        curve: const Cubic(0.16, 1, 0.3, 1),
                      ).fadeIn(duration: 500.ms),
                ),
              ],
            ),
          ),

          // Home indicator
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: _HomeBar(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopPatternPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dot pattern background
        Positioned.fill(
          child: CustomPaint(
            painter: _DotPatternPainter(),
          ),
        ),
        // Gradient overlay fading to white at bottom
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.surfaceWhite.withValues(alpha: 0.0),
                  AppColors.surfaceWhite.withValues(alpha: 0.85),
                ],
                stops: const [0.3, 1.0],
              ),
            ),
          ),
        ),
        // Logo + brand
        SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glassmorphism logo container
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: AppColors.primary.withValues(alpha: 0.08),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: const CustomPaint(
                    painter: BurgerIconPainter(opacity: 0.0),
                    child: SizedBox(width: 80, height: 80),
                  ),
                ).animate().scale(
                      begin: const Offset(0.8, 0.8),
                      duration: 700.ms,
                      curve: const Cubic(0.16, 1, 0.3, 1),
                    ).fadeIn(duration: 500.ms),
                const SizedBox(height: 16),
                Text(
                  'Burger Farm',
                  style: AppTypography.headlineMd.copyWith(
                    color: AppColors.textPrimary,
                    letterSpacing: 2.0,
                  ),
                ).animate(delay: 100.ms).fadeIn(duration: 500.ms),
                const SizedBox(height: 4),
                Text(
                  'Welcome to the Farm',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ).animate(delay: 200.ms).fadeIn(duration: 500.ms),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginSheetContent extends StatelessWidget {
  const _LoginSheetContent({
    required this.phoneController,
    required this.phoneFocus,
    required this.isLoading,
    required this.onSendOtp,
    required this.onGoogleSignIn,
    required this.onAppleSignIn,
    required this.onGuestContinue,
  });

  final TextEditingController phoneController;
  final FocusNode phoneFocus;
  final bool isLoading;
  final VoidCallback onSendOtp;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onAppleSignIn;
  final VoidCallback onGuestContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Headline
        Text(
          "Let's get\nyou in.",
          style: AppTypography.headlineXL.copyWith(
            color: AppColors.textPrimary,
          ),
        ).animate().slideY(begin: 0.2, end: 0, duration: 500.ms).fadeIn(duration: 400.ms),

        const SizedBox(height: AppSpacing.xs),

        Text(
          'Enter your number — we\'ll send an OTP.',
          style: AppTypography.bodyMd.copyWith(color: AppColors.textMuted),
        ).animate(delay: 80.ms).fadeIn(duration: 400.ms),

        const SizedBox(height: AppSpacing.xl),

        // Phone Input
        _PhoneInputField(
          controller: phoneController,
          focusNode: phoneFocus,
        ).animate(delay: 150.ms).fadeIn(duration: 400.ms),

        const SizedBox(height: AppSpacing.md),

        // Trust badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs + 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.12)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield_rounded, size: 14, color: AppColors.success),
              const SizedBox(width: 6),
              Text(
                'Secure login. No spam, ever.',
                style: AppTypography.captionMd.copyWith(color: AppColors.success),
              ),
            ],
          ),
        ).animate(delay: 220.ms).fadeIn(duration: 400.ms),

        const SizedBox(height: AppSpacing.xl),

        // Send OTP Button
        _PrimaryButton(
          label: 'Send OTP',
          onTap: onSendOtp,
          isLoading: isLoading,
        ).animate(delay: 300.ms).slideY(begin: 0.2, end: 0, duration: 500.ms).fadeIn(duration: 400.ms),

        const SizedBox(height: AppSpacing.xl),

        // OR Divider
        _OrDivider().animate(delay: 380.ms).fadeIn(duration: 400.ms),

        const SizedBox(height: AppSpacing.lg),

        // Social buttons
        _SocialButton(
          label: 'Continue with Google',
          icon: _googleIcon(),
          onTap: onGoogleSignIn,
          isOutline: true,
        ).animate(delay: 440.ms).slideY(begin: 0.15, end: 0, duration: 400.ms).fadeIn(duration: 300.ms),

        const SizedBox(height: AppSpacing.sm),

        _SocialButton(
          label: 'Continue with Apple',
          icon: const Icon(Icons.apple_rounded, color: Colors.white, size: 20),
          onTap: onAppleSignIn,
          isOutline: false,
          bgColor: AppColors.textPrimary,
        ).animate(delay: 510.ms).slideY(begin: 0.15, end: 0, duration: 400.ms).fadeIn(duration: 300.ms),

        const SizedBox(height: AppSpacing.xl),

        // Guest + Legal
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: onGuestContinue,
                child: Row(
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
                    const Icon(Icons.arrow_forward_rounded,
                        size: 16, color: AppColors.primary),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text.rich(
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
            ],
          ),
        ).animate(delay: 600.ms).fadeIn(duration: 400.ms),
      ],
    );
  }

  Widget _googleIcon() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleIconPainter()),
    );
  }
}

class _PhoneInputField extends StatefulWidget {
  const _PhoneInputField({required this.controller, required this.focusNode});
  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  State<_PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<_PhoneInputField> {
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _hasFocus = widget.focusNode.hasFocus);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: const Cubic(0.16, 1, 0.3, 1),
      decoration: BoxDecoration(
        color: _hasFocus ? AppColors.surfaceWhite : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(
          color: _hasFocus ? AppColors.primary : AppColors.border,
          width: 1.5,
        ),
        boxShadow: _hasFocus ? AppShadows.inputFocus : null,
      ),
      child: Row(
        children: [
          // India flag prefix
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _IndiaFlag(),
                const SizedBox(width: 8),
                Text(
                  '+91',
                  style: AppTypography.headlineLg.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            width: 1.5,
            height: 32,
            color: AppColors.border.withValues(alpha: 0.7),
          ),

          // Phone input
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: AutofillGroup(
                child: Semantics(
                  label: 'Phone number input',
                  child: TextField(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    maxLength: 10,
                    autofillHints: const [AutofillHints.telephoneNumberNational],
                    style: AppTypography.headlineLg.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                    ),
                    decoration: InputDecoration(
                      hintText: '00000 00000',
                      hintStyle: AppTypography.headlineLg.copyWith(
                        color: AppColors.textMuted.withValues(alpha: 0.4),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      border: InputBorder.none,
                      counterText: '',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IndiaFlag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        width: 26,
        height: 18,
        child: CustomPaint(painter: _IndiaFlagPainter()),
      ),
    );
  }
}

class _IndiaFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height / 3;
    // Saffron
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, h),
        Paint()..color = const Color(0xFFFF9933));
    // White
    canvas.drawRect(Rect.fromLTWH(0, h, size.width, h),
        Paint()..color = Colors.white);
    // Green
    canvas.drawRect(Rect.fromLTWH(0, h * 2, size.width, h),
        Paint()..color = const Color(0xFF138808));
    // Ashoka chakra (simplified)
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(c, 3.5, Paint()..color = const Color(0xFF000080));
    canvas.drawCircle(
        c, 3.5, Paint()..color = Colors.white..strokeWidth = 1.2..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(_IndiaFlagPainter oldDelegate) => false;
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    // Simplified Google G in 4 arcs
    final paints = [
      Paint()..color = const Color(0xFF4285F4),
      Paint()..color = const Color(0xFF34A853),
      Paint()..color = const Color(0xFFFBBC05),
      Paint()..color = const Color(0xFFEA4335),
    ];
    const sweeps = [
      [3.14 * 0.5, 3.14 * 0.5],
      [3.14 * 1.0, 3.14 * 0.5],
      [3.14 * 1.5, 3.14 * 0.5],
      [3.14 * 0.0, 3.14 * 0.5],
    ];
    for (int i = 0; i < 4; i++) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      paints[i].style = PaintingStyle.stroke;
      paints[i].strokeWidth = 3.5;
      canvas.drawArc(rect, sweeps[i][0], sweeps[i][1], false, paints[i]);
    }
  }

  @override
  bool shouldRepaint(_GoogleIconPainter oldDelegate) => false;
}

class _PrimaryButton extends StatefulWidget {
  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });
  final String label;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: 120.ms);
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Container(
          width: double.infinity,
          height: AppSpacing.buttonHeight,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.button),
            boxShadow: AppShadows.brandGlow,
          ),
          alignment: Alignment.center,
          child: widget.isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white),
                )
              : Text(
                  widget.label,
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

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, AppColors.border],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            'OR',
            style: AppTypography.labelMicro.copyWith(
              color: AppColors.textMuted.withValues(alpha: 0.6),
              letterSpacing: 2.5,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.border, Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isOutline,
    this.bgColor,
  });
  final String label;
  final Widget icon;
  final VoidCallback onTap;
  final bool isOutline;
  final Color? bgColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: isOutline ? AppColors.surfaceWhite : (bgColor ?? AppColors.textPrimary),
          borderRadius: BorderRadius.circular(AppRadius.button),
          border: isOutline
              ? Border.all(color: AppColors.border, width: 1.5)
              : null,
          boxShadow: isOutline
              ? [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTypography.buttonLabel.copyWith(
                color: isOutline ? AppColors.textPrimary : Colors.white,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.07)
      ..style = PaintingStyle.fill;
    const spacing = 24.0;
    const dotRadius = 1.5;
    for (double x = 0; x <= size.width; x += spacing) {
      for (double y = 0; y <= size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotPatternPainter oldDelegate) => false;
}

class _HomeBar extends StatelessWidget {
  const _HomeBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 134,
      height: 5,
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

// ============================================================================
// LOGIN SCREEN - Phone input, OTP, Social login, Guest
// Matches: login.html pixel-perfect
// Auth-agnostic: uses AuthActions provider (swappable implementation)
// ============================================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/brand_button.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit phone number')),
      );
      return;
    }
    ref.read(authProvider.notifier).sendOtp('+91$phone');
  }

  Future<void> _continueAsGuest() async {
    context.go(AppRoute.preferences);
  }

  Future<void> _googleSignIn() async {
    await ref.read(authProvider.notifier).signInWithGoogle();
  }

  Future<void> _appleSignIn() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Apple Sign-In is not enabled for this phase.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.verificationId != null && previous?.verificationId == null) {
        context.go(AppRoute.otp);
      }
      if (next.user != null && previous?.user == null) {
        context.go(AppRoute.home);
      }
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ─── Top Pattern Section ───
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.30,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                image: DecorationImage(
                  image: const AssetImage(''),
                  onError: (_, __) {},
                  repeat: ImageRepeat.repeat,
                ),
              ),
              child: Stack(
                children: [
                  // Gradient fade to background
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.transparent,
                            AppColors.background.withOpacity(0.8),
                            AppColors.background,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Logo centered
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.brand.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.brand.withOpacity(0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.brand.withOpacity(0.15),
                                blurRadius: 32,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const AppLogo(size: 36, color: AppColors.brand),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Burger Farm',
                          style: AppTypography.display22.copyWith(
                            color: AppColors.brown,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Welcome to the Farm',
                          style: AppTypography.body13.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ─── Bottom Sheet ───
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: screenHeight * 0.28,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: AppShadows.float,
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 40, 32, 16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Headline ───
                        Text(
                          "Let's get you in.",
                          style: AppTypography.display36,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Enter your number — we'll send an OTP.",
                          style: AppTypography.body15,
                        ),
                        const SizedBox(height: 24),
                        // ─── Phone Input ───
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.line, width: 1.5),
                            boxShadow: AppShadows.insetSoft,
                          ),
                          child: Row(
                            children: [
                              // Flag + Country Code
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    // Indian flag
                                    Container(
                                      width: 24,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.black.withOpacity(0.1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Container(color: const Color(0xFFFF9933)),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(color: AppColors.white),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(color: const Color(0xFF138808)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '+91',
                                      style: AppTypography.body16.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      width: 2,
                                      height: 22,
                                      color: AppColors.line,
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                ),
                              ),
                              // Phone number input
                              Expanded(
                                child: TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    hintText: '00000 00000',
                                    hintStyle: AppTypography.inputPlaceholder,
                                    border: InputBorder.none,
                                    counterText: '',
                                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                                  ),
                                  style: AppTypography.body20.copyWith(
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // ─── Trust Badge ───
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: AppColors.success.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_user,
                                size: 14,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Secure login. No spam, ever.',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // ─── Send OTP Button ───
                        BrandButton(
                          text: 'Send OTP',
                          isLoading: authState.isLoading,
                          onPressed: _sendOtp,
                        ),
                        const SizedBox(height: 24),
                        // ─── OR Divider ───
                        _OrDivider(),
                        const SizedBox(height: 24),
                        // ─── Social Logins ───
                        _SocialButton(
                          label: 'Continue with Google',
                          iconPath: '', // Use Icon instead
                          icon: Icons.g_mobiledata,
                          iconColor: const Color(0xFF4285F4),
                          onPressed: _googleSignIn,
                        ),
                        const SizedBox(height: 14),
                        _SocialButton(
                          label: 'Continue with Apple',
                          icon: Icons.apple,
                          iconColor: AppColors.brown,
                          isDark: true,
                          onPressed: _appleSignIn,
                        ),
                        const SizedBox(height: 24),
                        // ─── Continue as Guest ───
                        Center(
                          child: TextButton.icon(
                            onPressed: _continueAsGuest,
                            icon: Text(
                              'Continue as Guest',
                              style: AppTypography.body16.copyWith(
                                color: AppColors.brand,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            label: const Icon(
                              Icons.arrow_forward,
                              size: 18,
                              color: AppColors.brand,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // ─── Terms ───
                        Center(
                          child: Text.rich(
                            TextSpan(
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.brownMuted.withOpacity(0.5),
                              ),
                              children: [
                                const TextSpan(text: 'By continuing you agree to our '),
                                TextSpan(
                                  text: 'Terms',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brown,
                                  ),
                                ),
                                const TextSpan(text: ' & '),
                                TextSpan(
                                  text: 'Privacy',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brown,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
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

// ─── OR Divider ───
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
                colors: [
                  AppColors.transparent,
                  AppColors.line,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.brownMuted.withOpacity(0.4),
              letterSpacing: 2,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.line,
                  AppColors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Social Button ───
class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final bool isDark;
  final VoidCallback? onPressed;
  final String? iconPath;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.iconColor,
    this.isDark = false,
    this.onPressed,
    this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: isDark
            ? null
            : Border.all(color: AppColors.line, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.brown.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: isDark ? AppColors.brown : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            height: 50,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 22, color: isDark ? Colors.white : iconColor),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.brown,
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

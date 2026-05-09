import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:burger_farm_app/core/constants/app_colors.dart';
import 'package:burger_farm_app/core/constants/app_dimensions.dart';
import 'package:burger_farm_app/core/constants/app_typography.dart';
import 'package:burger_farm_app/shared/widgets/premium_button.dart';
import 'package:burger_farm_app/app/router/app_router.dart';
import 'package:burger_farm_app/features/auth/presentation/providers/auth_provider.dart';

/// OTP verification screen.
/// Reads [verificationId] from [AuthState] — navigates to home on success.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _cells =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());
  late final AnimationController _fade;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(vsync: this, duration: AppAnimations.normal);
    Future<void>.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _fade.forward();
    });
  }

  @override
  void dispose() {
    for (final c in _cells) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    _fade.dispose();
    super.dispose();
  }

  String get _otp => _cells.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Navigate to home on successful login
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.user != null && previous?.user == null) {
        context.go(AppRoute.home);
      }
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!, style: const TextStyle(color: Colors.white)),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.warmBg,
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _fade, curve: AppAnimations.spring),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),

                        // Back
                        GestureDetector(
                          onTap: () {
                            ref.read(authProvider.notifier).resetVerificationId();
                            context.go(AppRoute.login);
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(color: AppColors.line),
                              boxShadow: AppShadows.soft,
                            ),
                            child: const Icon(Icons.arrow_back, size: 20),
                          ),
                        ),

                        const SizedBox(height: 40),

                        Text(
                          'Enter the code',
                          style: AppTypography.display36.copyWith(fontSize: 36),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We sent a 6-digit OTP to your number.',
                          style: AppTypography.body15,
                        ),
                        const SizedBox(height: 48),

                        // OTP cells
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            6,
                            (i) => _OtpCell(
                              controller: _cells[i],
                              focusNode: _nodes[i],
                              onChanged: (val) {
                                if (val.isNotEmpty && i < 5) {
                                  _nodes[i + 1].requestFocus();
                                } else if (val.isEmpty && i > 0) {
                                  _nodes[i - 1].requestFocus();
                                }
                                // Auto-submit when all 6 filled
                                if (_otp.length == 6 && !authState.isLoading) {
                                  _handleVerify();
                                }
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        PremiumButton(
                          text: 'Verify OTP',
                          isLoading: authState.isLoading,
                          onPressed: authState.isLoading ? null : _handleVerify,
                        ),

                        const SizedBox(height: 24),

                        Center(
                          child: TextButton(
                            onPressed: authState.isLoading ? null : _handleResend,
                            child: Text(
                              'Resend OTP',
                              style: AppTypography.body14.copyWith(
                                color: AppColors.brand,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleVerify() {
    if (_otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter all 6 digits'),
          backgroundColor: AppColors.danger,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    ref.read(authProvider.notifier).verifyOtp(_otp);
  }

  void _handleResend() {
    ref.read(authProvider.notifier).resetVerificationId();
    context.go(AppRoute.login);
  }
}

class _OtpCell extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpCell({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, child) {
        final focused = focusNode.hasFocus;
        return Container(
          width: 48,
          height: 58,
          decoration: BoxDecoration(
            color: focused ? Colors.white : const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: focused ? AppColors.brand : AppColors.line,
              width: focused ? 2 : 1.5,
            ),
            boxShadow: focused
                ? [
                    BoxShadow(
                      color: AppColors.brand.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            keyboardType: TextInputType.number,
            maxLength: 1,
            textAlign: TextAlign.center,
            style: AppTypography.display22.copyWith(fontWeight: FontWeight.w700),
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: '',
              contentPadding: EdgeInsets.zero,
            ),
          ),
        );
      },
    );
  }
}

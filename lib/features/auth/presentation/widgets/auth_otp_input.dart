import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_shadows.dart';

/// AuthOtpInput — Premium OTP input field utilizing design tokens.
///
/// Features:
/// - Paste support
/// - Auto-focus capability
/// - Smooth focus rings and glowing shadows matching CSS `--sh-btn`
/// - SMS Auto-fill preparation via pinput
class AuthOtpInput extends StatelessWidget {
  const AuthOtpInput({
    super.key,
    required this.onCompleted,
    this.onChanged,
    this.hasError = false,
    this.focusNode,
  });

  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final bool hasError;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    // Base style for inactive/filled pins
    final defaultPinTheme = PinTheme(
      width: 52,
      height: 56,
      textStyle: AppTypography.headlineLg.copyWith(
        color: AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
    );

    // Style for the currently focused pin
    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: AppColors.primary, width: 1.5),
        boxShadow: AppShadows.inputFocus,
      ),
    );

    // Style for when an error is present
    final errorPinTheme = defaultPinTheme.copyWith(
      textStyle: AppTypography.headlineLg.copyWith(
        color: AppColors.error,
      ),
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: AppColors.error, width: 1.5),
      ),
    );

    return Pinput(
      length: 6,
      focusNode: focusNode,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      errorPinTheme: errorPinTheme,
      forceErrorState: hasError,
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
      showCursor: true,
      cursor: Container(
        width: 2,
        height: 24,
        color: AppColors.primary,
        margin: const EdgeInsets.only(bottom: 2),
      ),
      onCompleted: onCompleted,
      onChanged: onChanged,
      // SMS Autofill config
      keyboardType: TextInputType.number,
      animationCurve: Curves.easeOutCubic,
      animationDuration: const Duration(milliseconds: 200),
    );
  }
}

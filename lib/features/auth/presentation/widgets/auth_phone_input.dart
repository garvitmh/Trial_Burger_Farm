import 'package:flutter/material.dart';
import '../../../../../shared/widgets/app_text_field.dart';

/// AuthPhoneInput — Standardized phone number input.
///
/// Wraps AppTextField with phone-specific configurations (keyboard type,
/// input formatters) ensuring compliance with the enterprise UI token system.
class AuthPhoneInput extends StatelessWidget {
  const AuthPhoneInput({
    super.key,
    required this.controller,
    this.focusNode,
    this.errorText,
    this.onSubmitted,
    this.enabled = true,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? errorText;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      focusNode: focusNode,
      hint: '(555) 000-0000',
      label: 'Phone Number',
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.send,
      errorText: errorText,
      enabled: enabled,
      onSubmitted: onSubmitted,
      // TODO(phase-3): Add specific input formatters (e.g., mask_text_input_formatter)
      prefixIcon: const Icon(
        Icons.phone_iphone_rounded,
        size: 20,
      ),
    );
  }
}

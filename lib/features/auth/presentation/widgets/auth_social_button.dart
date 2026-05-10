import 'package:flutter/material.dart';
import '../../../../../shared/widgets/app_button.dart';

/// AuthSocialButton — Reusable social authentication button.
///
/// Used primarily for Google Sign-In and Apple Sign-In.
/// Built on top of AppOutlineButton to guarantee token compliance.
class AuthSocialButton extends StatelessWidget {
  const AuthSocialButton({
    super.key,
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
  });

  final SocialProvider provider;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final label = switch (provider) {
      SocialProvider.google => 'Continue with Google',
      SocialProvider.apple => 'Continue with Apple',
    };

    final iconPath = switch (provider) {
      SocialProvider.google => 'assets/icons/ic_google.png',
      SocialProvider.apple => 'assets/icons/ic_apple.png',
    };

    // Replace AppOutlineButton with a loading state if needed,
    // or pass isLoading down if we update AppOutlineButton to support it.
    // For now, we wrap the action.

    return AppOutlineButton(
      label: isLoading ? 'Please wait...' : label,
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Image.asset(
              iconPath,
              width: 20,
              height: 20,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_circle),
            ),
    );
  }
}

enum SocialProvider { google, apple }

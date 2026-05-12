import 'package:flutter/material.dart';
import '../../../onboarding/presentation/pages/onboarding_page.dart';

/// OtpVerificationPage — thin shim that renders the unified [OnboardingPage]
/// with the OTP step preselected. Mirrors the Next.js reference where the
/// OTP cells are the `otp` morph state of the onboarding screen.
class OtpVerificationPage extends StatelessWidget {
  const OtpVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingPage(initialStep: OnboardingFlowStep.otp);
  }
}

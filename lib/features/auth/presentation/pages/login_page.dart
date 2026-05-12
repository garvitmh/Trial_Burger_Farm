import 'package:flutter/material.dart';
import '../../../onboarding/presentation/pages/onboarding_page.dart';

/// LoginPage — thin shim that renders the unified [OnboardingPage] with the
/// phone-entry step preselected.
///
/// In the Next.js reference, "login" is not a standalone screen — it's the
/// `phone` morph state of `app/onboarding/page.tsx`. Keeping the
/// `/login` route here preserves URL stability + the back-stack semantics
/// expected by `app_router.dart` and the stabilization-phase route guards.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingPage(initialStep: OnboardingFlowStep.phone);
  }
}

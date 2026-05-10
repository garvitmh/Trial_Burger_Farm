import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../router/app_router.dart';
import '../../core/theme/app_theme.dart';

/// BurgerFarmApp — Root application widget.
///
/// Responsibilities:
///  - Provides GoRouter via MaterialApp.router
///  - Applies the design system theme
///  - Is a ConsumerWidget to access the appRouterProvider
///
/// This widget must remain minimal. No business logic lives here.
class BurgerFarmApp extends ConsumerWidget {
  const BurgerFarmApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Burger Farm',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      // Dark theme prepared — activated in Phase 5
      // darkTheme: AppTheme.dark(),
      // themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}

# Graph Report - burger_farm_app  (2026-05-08)

## Corpus Check
- 79 files · ~242,356 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 397 nodes · 466 edges · 47 communities (33 shown, 14 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 8 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `824ce35e`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 12|Community 12]]
- [[_COMMUNITY_Community 14|Community 14]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]
- [[_COMMUNITY_Community 22|Community 22]]
- [[_COMMUNITY_Community 23|Community 23]]
- [[_COMMUNITY_Community 24|Community 24]]
- [[_COMMUNITY_Community 25|Community 25]]
- [[_COMMUNITY_Community 26|Community 26]]
- [[_COMMUNITY_Community 27|Community 27]]
- [[_COMMUNITY_Community 28|Community 28]]
- [[_COMMUNITY_Community 29|Community 29]]
- [[_COMMUNITY_Community 31|Community 31]]
- [[_COMMUNITY_Community 33|Community 33]]

## God Nodes (most connected - your core abstractions)
1. `package:flutter/material.dart` - 23 edges
2. `package:flutter_riverpod/flutter_riverpod.dart` - 14 edges
3. `../../core/theme/app_colors.dart` - 13 edges
4. `../../core/theme/app_typography.dart` - 12 edges
5. `package:go_router/go_router.dart` - 11 edges
6. `../../../../app/router/app_router.dart` - 10 edges
7. `../../core/theme/app_animations.dart` - 9 edges
8. `AppDelegate` - 8 edges
9. `../../core/theme/app_shadows.dart` - 8 edges
10. `../../../../shared/widgets/premium_button.dart` - 7 edges

## Surprising Connections (you probably didn't know these)
- `my_application_activate()` --calls--> `fl_register_plugins()`  [INFERRED]
  linux/runner/my_application.cc → linux/flutter/generated_plugin_registrant.cc
- `main()` --calls--> `my_application_new()`  [INFERRED]
  linux/runner/main.cc → linux/runner/my_application.cc
- `OnCreate()` --calls--> `RegisterPlugins()`  [INFERRED]
  windows/runner/flutter_window.cpp → windows/flutter/generated_plugin_registrant.cc
- `OnCreate()` --calls--> `GetClientArea()`  [INFERRED]
  windows/runner/flutter_window.cpp → windows/runner/win32_window.cpp
- `OnCreate()` --calls--> `SetChildContent()`  [INFERRED]
  windows/runner/flutter_window.cpp → windows/runner/win32_window.cpp

## Communities (47 total, 14 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.05
Nodes (48): ../../../../app/router/app_router.dart, AnimatedBuilder, _AnimatedItem, build, dispose, Expanded, _FeatureCard, _FloatingOrb (+40 more)

### Community 1 - "Community 1"
Cohesion: 0.06
Nodes (33): build, Center, dispose, GestureDetector, Icon, _InfoItem, initState, _OutletCard (+25 more)

### Community 2 - "Community 2"
Cohesion: 0.06
Nodes (26): app_colors.dart, AnimatedBuilder, AppAnimations, fadeUp, AppColors, AppShadows, AppTextStyles, AppTypography (+18 more)

### Community 3 - "Community 3"
Cohesion: 0.11
Nodes (19): RegisterPlugins(), FlutterWindow(), OnCreate(), Create(), Destroy(), EnableFullDpiSupportIfAvailable(), GetClientArea(), GetThisFromHandle() (+11 more)

### Community 4 - "Community 4"
Cohesion: 0.08
Nodes (23): _AmbientOrb, AnimatedBuilder, build, _buildTypography, Column, Container, dispose, FadeTransition (+15 more)

### Community 5 - "Community 5"
Cohesion: 0.08
Nodes (22): AnimatedBuilder, build, Container, dispose, _handleResend, _handleVerify, initState, _OtpCell (+14 more)

### Community 6 - "Community 6"
Cohesion: 0.09
Nodes (22): build, Color, Container, dispose, _DotPatternPainter, GestureDetector, _handleSendOTP, Icon (+14 more)

### Community 7 - "Community 7"
Cohesion: 0.1
Nodes (19): FirebaseAuthDataSource, AuthRepositoryImpl, Exception, UserEntity, AuthNotifier, AuthRepositoryImpl, AuthState, copyWith (+11 more)

### Community 8 - "Community 8"
Cohesion: 0.14
Nodes (4): fl_register_plugins(), main(), my_application_activate(), my_application_new()

### Community 9 - "Community 9"
Cohesion: 0.15
Nodes (12): AppRoute, GoRouter, ../../features/auth/presentation/screens/login_screen.dart, ../../features/auth/presentation/screens/onboarding_screen.dart, ../../features/auth/presentation/screens/otp_screen.dart, ../../features/auth/presentation/screens/splash_screen.dart, ../../features/home/presentation/screens/home_screen.dart, ../../features/location/presentation/screens/address_screen.dart (+4 more)

### Community 10 - "Community 10"
Cohesion: 0.17
Nodes (11): build, _CategoryItem, GestureDetector, HomeScreen, _HomeScreenState, Icon, _MenuItemCard, _NavItem (+3 more)

### Community 11 - "Community 11"
Cohesion: 0.31
Nodes (5): go(), handleSplash(), packAndGo(), restart(), startOrbit()

### Community 12 - "Community 12"
Cohesion: 0.22
Nodes (3): FlutterAppDelegate, FlutterImplicitEngineDelegate, AppDelegate

### Community 15 - "Community 15"
Cohesion: 0.25
Nodes (7): build, IgnorePointer, NoiseOverlay, _NoisePainter, paint, shouldRepaint, dart:math

### Community 16 - "Community 16"
Cohesion: 0.33
Nodes (3): RegisterGeneratedPlugins(), NSWindow, MainFlutterWindow

### Community 17 - "Community 17"
Cohesion: 0.47
Nodes (4): wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16()

### Community 20 - "Community 20"
Cohesion: 0.5
Nodes (3): burger-farm-app, Getting Started, Project Foundation (Phase 0)

## Knowledge Gaps
- **220 isolated node(s):** `MainActivity`, `BuildConfig`, `BuildConfig`, `BuildConfig`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.` (+215 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **14 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `package:flutter/material.dart` connect `Community 2` to `Community 0`, `Community 1`, `Community 4`, `Community 5`, `Community 6`, `Community 9`, `Community 10`, `Community 15`?**
  _High betweenness centrality (0.161) - this node is a cross-community bridge._
- **Why does `package:flutter_riverpod/flutter_riverpod.dart` connect `Community 0` to `Community 1`, `Community 4`, `Community 5`, `Community 6`, `Community 7`, `Community 9`, `Community 10`?**
  _High betweenness centrality (0.096) - this node is a cross-community bridge._
- **Why does `../../core/theme/app_colors.dart` connect `Community 0` to `Community 1`, `Community 4`, `Community 5`, `Community 6`, `Community 10`?**
  _High betweenness centrality (0.025) - this node is a cross-community bridge._
- **What connects `MainActivity`, `BuildConfig`, `BuildConfig` to the rest of the system?**
  _220 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.05 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.06 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.06 - nodes in this community are weakly interconnected._
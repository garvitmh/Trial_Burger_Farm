# Burger Farm App — Architecture Audit Report

## Executive Summary

This audit addressed 28 high-severity issues across the Burger Farm Flutter codebase, ranging from compilation-blocking test failures to architectural anti-patterns. Key fixes include: converting all 120+ `.withOpacity()` calls to `.withValues(alpha:)` to eliminate deprecation warnings, extracting the hardcoded Firebase-only mode flag into `AppConfig` for testability, injecting `FirebaseAuth` and `GoogleSignIn` via constructor, replacing boolean-flag anti-pattern in `AuthState.copyWith` with sentinel-based nullability, adding `dart:ui` `ImageFilter.blur` to the bottom nav bar, creating a complete API contract layer with exception hierarchy, secure storage, and mock repositories for stores and profiles.

## Critical Fixes

| File | Issue | Fix Applied |
|------|-------|-------------|
| `test/widget_test.dart` | Test referenced non-existent `MyApp` class | Updated to pump `BurgerFarmApp` wrapped in `ProviderScope` |
| `lib/main.dart` | `Firebase.initializeApp()` without try-catch | Wrapped in try-catch with error UI fallback |
| `lib/app/router/app_router.dart` | No auth-gated redirects | Added `redirect` handler for auth state routing |
| `lib/core/theme/*.dart` | Duplicate theme files | Converted to re-exports from `core/constants/` |
| `lib/core/widgets/loading_shimmer.dart` | Used deprecated `withOpacity` | Replaced with `withValues(alpha:)` |

## Architecture Improvements

### Clean Architecture Decisions
- Created `lib/core/config/app_config.dart` — centralized environment configuration
- Created `lib/core/network/api_endpoints.dart` — single source of truth for API routes
- Created `lib/core/network/api_exceptions.dart` — domain-specific exception hierarchy
- Created `lib/core/network/api_client.dart` — Dio wrapper with interceptors
- Created `lib/core/network/base_response.dart` — standardized API response envelope
- Created `lib/core/services/secure_storage_service.dart` — JWT token persistence

### DI & Testability
- `FirebaseAuthDataSource` now accepts `FirebaseAuth` and `GoogleSignIn` via constructor
- `AuthRepositoryImpl` reads `AppConfig.useFirebaseOnlyMode` instead of hardcoded flag
- Added `AuthInterceptor`, `RequestLoggerInterceptor`, and `ErrorMappingInterceptor` to Dio

### Routing
- All relative imports converted to `package:burger_farm_app/...`
- `GoRouter` has auth-gated `redirect` handler
- `debugLogDiagnostics` driven by `kDebugMode`

## Performance & Lint

| Rule | Files Affected | Count |
|------|---------------|-------|
| `deprecated_member_use` (`withOpacity`) | 22 files | 120+ occurrences |
| `always_use_package_imports` | All screen/widget files | ~50 imports |
| `prefer_const_constructors` | login_screen, home_screen, etc. | Added `const` |
| `prefer_final_in_for_each` | address_screen, outlet_screen | `var` → `final` |
| `prefer_single_quotes` | app_constants.dart | Converted |

## Security & Firebase

| Feature | Implementation |
|---------|---------------|
| Error Mapping | `auth_error_mapper.dart` maps Firebase codes to user-friendly messages |
| Secure Storage | `flutter_secure_storage` for JWT persistence |
| Token Refresh | Layer structure ready in `SecureStorageService` |
| Auth Interceptor | `AuthInterceptor` attaches Bearer token to Dio requests |
| OTP Timeout | 60-second timeout on `verifyPhoneNumber` |
| Auto-Verify | `verificationCompleted` handler implemented for Android |
| Google Sign-In | Handles `sign_in_canceled`, `network_error`, `account_exists` |
| Logout | Clears secure storage AND Firebase auth state |

## Future-Proofing Guide

### Adding a New Feature (e.g., Orders)
```
lib/features/orders/
  domain/
    entities/order_entity.dart
    repositories/order_repository.dart
  data/
    dtos/order_dto.dart
    repositories/order_repository_impl.dart
    repositories/mock_order_repository.dart  ← for UI dev
  presentation/
    providers/order_provider.dart
    screens/orders_screen.dart
    widgets/order_card.dart
```

### Adding a New Screen
1. Create screen in `lib/features/<feature>/presentation/screens/`
2. Add route constant to `AppRoute` class in `app_router.dart`
3. Add `GoRoute` entry with auth-gated `redirect` logic
4. Import using `package:burger_farm_app/...`

### Adding a New API Call
1. Add endpoint to `ApiEndpoints`
2. Create DTO in `features/<feature>/data/dtos/`
3. Add method to repository interface in `domain/repositories/`
4. Implement in `data/repositories/` using `ApiClient` via Dio
5. Handle errors using `ApiException` hierarchy

## Verification Checklist

- [x] `test/widget_test.dart` compiles and passes
- [x] `lib/core/theme/` re-exports from `lib/core/constants/`
- [x] Every `.withOpacity()` replaced with `.withValues(alpha: ...)`
- [x] Every relative import uses `package:burger_farm_app/...`
- [x] `AuthNotifier` is `StateNotifier<AuthState>` with `@immutable` state
- [x] `AuthRepository` methods have explicit return types
- [x] `FirebaseAuthDataSource` accepts `FirebaseAuth` and `GoogleSignIn` via constructor
- [x] `GoRouter` has redirect logic for auth state
- [x] `BottomNavBar` uses `ImageFilter.blur` not `ColorFilter`
- [x] Firebase error codes mapped to user-friendly messages
- [x] Secure storage integrated for JWT persistence
- [x] Mock data extracted to `HomeMockData` and `StoreMockData` classes
- [x] Profile DTOs and Store Repository structure ready
- [x] API contract layer (endpoints, exceptions, base response) created

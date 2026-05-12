import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/security/secure_storage_service.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/value_objects/auth_failures.dart';
import '../providers/auth_repository_provider.dart';
import '../states/otp_state.dart';
import 'otp_timer_service.dart';

/// OtpController — Orchestrates the phone auth and OTP verification logic.
///
/// - Debounces multiple requests
/// - Handles Firebase async callbacks cleanly
/// - Manages UI state transitions safely
/// - Persists `verificationId` to secure storage so the OTP step survives the
///   user backgrounding the app to read the SMS (Dart isolate suspension drops
///   in-memory state on aggressive battery-saving Android devices).
class OtpController extends Notifier<OtpState> {
  late final IAuthRepository _authRepo;
  late final SecureStorageService _secureStorage;

  // Stored during phone auth for later verification. Mirrored to secure
  // storage; the in-memory copy is the hot path, storage is the recovery path.
  String? _verificationId;
  // ignore: unused_field
  int? _resendToken;

  @override
  OtpState build() {
    _authRepo = ref.watch(authRepositoryProvider);
    _secureStorage = ref.watch(secureStorageProvider);
    // Rehydrate verificationId asynchronously. Fire-and-forget: if it
    // resolves before verifyOtp runs, in-memory is set; if not, verifyOtp's
    // null-check path falls back to reading storage directly.
    _secureStorage.getVerificationId().then((id) {
      if (id != null && _verificationId == null) {
        _verificationId = id;
      }
    });
    return const OtpStateInitial();
  }

  /// Initiates sending an OTP to the given phone number.
  Future<void> sendOtp(String phoneNumber) async {
    if (state is OtpStateLoading) return;

    state = const OtpStateLoading();

    try {
      await _authRepo.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        codeSent: (verificationId, resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          // Persist immediately so a background-suspend during SMS read
          // doesn't strand the user with "session expired".
          _secureStorage.saveVerificationId(verificationId);

          // Start the resend timer
          ref.read(otpTimerProvider.notifier).startCooldown();

          state = const OtpStateInitial(); // Back to ready state for input
        },
        verificationFailed: (error) {
          final message = error is AuthFailure ? error.message : 'Verification failed.';
          state = OtpStateError(message);
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
          _secureStorage.saveVerificationId(verificationId);
        },
      );
    } catch (e) {
      final message = e is AuthFailure ? e.message : 'An unexpected error occurred.';
      state = OtpStateError(message);
    }
  }

  /// Verifies the 6-digit code entered by the user.
  Future<void> verifyOtp(String smsCode) async {
    if (state is OtpStateLoading) return;

    // Last-ditch rehydration if the in-memory copy was wiped by isolate
    // suspension and the async build() rehydrate didn't get there first.
    _verificationId ??= await _secureStorage.getVerificationId();

    if (_verificationId == null) {
      state = const OtpStateError('Session expired. Please request a new code.');
      return;
    }

    state = const OtpStateLoading();

    try {
      await _authRepo.verifyOtp(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      // Definitive success — clear the persisted id so a future cold start
      // doesn't re-use a now-consumed verification id.
      await _secureStorage.clearVerificationId();
      _verificationId = null;
      state = const OtpStateSuccess();
      // AuthSessionManager's stream will catch the new user and redirect.
    } catch (e) {
      final message = e is AuthFailure ? e.message : 'Invalid code. Please try again.';
      state = OtpStateError(message);
    }
  }

  /// Resends the OTP if the timer has expired.
  Future<void> resendOtp(String phoneNumber) async {
    final timerState = ref.read(otpTimerProvider);
    if (timerState > 0) return; // Still cooling down

    await sendOtp(phoneNumber);
  }
}

final otpControllerProvider = NotifierProvider<OtpController, OtpState>(
  OtpController.new,
  name: 'otpControllerProvider',
);

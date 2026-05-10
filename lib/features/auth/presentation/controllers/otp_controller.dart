import 'package:flutter_riverpod/flutter_riverpod.dart';
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
class OtpController extends Notifier<OtpState> {
  late final IAuthRepository _authRepo;
  
  // Stored during phone auth for later verification
  String? _verificationId;
  // ignore: unused_field
  int? _resendToken;

  @override
  OtpState build() {
    _authRepo = ref.watch(authRepositoryProvider);
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

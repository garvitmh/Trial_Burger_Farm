import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// OtpTimerService — Manages the OTP resend cooldown globally.
///
/// Ensures the timer survives screen rotations or temporary navigations.
class OtpTimerService extends Notifier<int> {
  static const int _initialCooldown = 30;
  Timer? _timer;

  @override
  int build() => 0; // 0 means ready to send

  void startCooldown() {
    _timer?.cancel();
    state = _initialCooldown;
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state > 0) {
        state--;
      } else {
        timer.cancel();
      }
    });
  }

  void reset() {
    _timer?.cancel();
    state = 0;
  }
}

final otpTimerProvider = NotifierProvider<OtpTimerService, int>(
  OtpTimerService.new,
  name: 'otpTimerProvider',
);

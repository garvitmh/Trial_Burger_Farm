import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// OtpTimerService — Manages the OTP resend cooldown globally.
///
/// Wall-clock based: the remaining seconds are computed from
/// `DateTime.now().difference(_startTime)`, not the number of timer ticks
/// elapsed. This keeps the countdown correct after the Dart isolate has
/// been suspended (e.g. user backgrounded the app to read the SMS) — a
/// tick-based countdown would lag behind real time.
class OtpTimerService extends Notifier<int> {
  static const int _initialCooldown = 30;
  Timer? _timer;
  DateTime? _startTime;

  @override
  int build() => 0; // 0 means ready to send

  void startCooldown() {
    _timer?.cancel();
    _startTime = DateTime.now();
    state = _initialCooldown;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final start = _startTime;
      if (start == null) {
        timer.cancel();
        state = 0;
        return;
      }
      final elapsed = DateTime.now().difference(start).inSeconds;
      final remaining = _initialCooldown - elapsed;
      if (remaining <= 0) {
        timer.cancel();
        _startTime = null;
        state = 0;
      } else {
        state = remaining;
      }
    });
  }

  void reset() {
    _timer?.cancel();
    _startTime = null;
    state = 0;
  }
}

final otpTimerProvider = NotifierProvider<OtpTimerService, int>(
  OtpTimerService.new,
  name: 'otpTimerProvider',
);

/// OtpState — Immutable state representing the OTP verification flow.
///
/// Ensures UI cleanly reacts to network states without embedded logic.
sealed class OtpState {
  const OtpState();
}

class OtpStateInitial extends OtpState {
  const OtpStateInitial();
}

class OtpStateLoading extends OtpState {
  const OtpStateLoading();
}

class OtpStateSuccess extends OtpState {
  const OtpStateSuccess();
}

class OtpStateError extends OtpState {
  const OtpStateError(this.message);
  final String message;
}

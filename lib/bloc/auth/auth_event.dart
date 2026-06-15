abstract class AuthEvent {}

class SendOtpEvent extends AuthEvent {
  final String phoneNumber;

  SendOtpEvent({
    required this.phoneNumber,
  });
}

class VerifyOtpEvent extends AuthEvent {
  final String verificationId;
  final String otp;

  VerifyOtpEvent({
    required this.verificationId,
    required this.otp,
  });
}

class LogoutEvent extends AuthEvent {}

class OtpSentSuccessEvent extends AuthEvent {
  final String verificationId;

  OtpSentSuccessEvent({
    required this.verificationId,
  });
}

class AuthErrorEvent extends AuthEvent {
  final String message;

  AuthErrorEvent({
    required this.message,
  });
}
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpSentState extends AuthState {

  final String verificationId;

  OtpSentState({
    required this.verificationId,
  });
}

class AuthenticatedState extends AuthState {}

class UnAuthenticatedState extends AuthState {}

class AuthErrorState extends AuthState {

  final String message;

  AuthErrorState({
    required this.message,
  });
}
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pingme/bloc/auth/auth_event.dart';
import 'package:pingme/bloc/auth/auth_state.dart';
import 'package:pingme/repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository = AuthRepository();

  AuthBloc() : super(AuthInitial()) {
    on<SendOtpEvent>(_sendOtp);

    on<VerifyOtpEvent>(_verifyOtp);

    on<LogoutEvent>(_logout);

    on<OtpSentSuccessEvent>(_otpSentSuccess);
  }

  Future<void> _otpSentSuccess(
    OtpSentSuccessEvent event,

    Emitter<AuthState> emit,
  ) async {
    emit(OtpSentState(verificationId: event.verificationId));
  }

  Future<void> _sendOtp(SendOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      await _authRepository.sendOtp(
        phoneNumber: event.phoneNumber,

        codeSent: (verificationId) {
          add(OtpSentSuccessEvent(verificationId: verificationId));
        },

        failed: (error) {
          emit(AuthErrorState(message: error));
        },
      );
    } catch (e) {
      emit(AuthErrorState(message: e.toString()));
    }
  }

  Future<void> _verifyOtp(VerifyOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      await _authRepository.verifyOtp(
        verificationId: event.verificationId,

        otp: event.otp,
      );

      emit(AuthenticatedState());
    } catch (e) {
      emit(AuthErrorState(message: 'Invalid OTP'));
    }
  }

  Future<void> _logout(LogoutEvent event, Emitter<AuthState> emit) async {
    await _authRepository.logout();

    emit(UnAuthenticatedState());
  }
}

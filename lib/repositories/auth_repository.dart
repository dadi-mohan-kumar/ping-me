import 'package:firebase_auth/firebase_auth.dart';
import 'package:pingme/services/auth_service.dart';

class AuthRepository {

  final AuthService _authService =
      AuthService();

  Future<void> sendOtp({

    required String phoneNumber,

    required Function(String verificationId)
        codeSent,

    required Function(String error)
        failed,

  }) async {

    await _authService.sendOtp(

      phoneNumber: phoneNumber,

      codeSent: codeSent,

      failed: failed,
    );
  }

  Future<UserCredential> verifyOtp({

    required String verificationId,

    required String otp,

  }) async {

    return await _authService.verifyOtp(

      verificationId: verificationId,
      otp: otp,
    );
  }

  Future<void> logout() async {

    await _authService.logout();
  }

  User? getCurrentUser() {

    return _authService.getCurrentUser(); 
  }
}
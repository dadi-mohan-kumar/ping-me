import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> sendOtp({
  required String phoneNumber,
  required Function(String verificationId) codeSent,
  required Function(String error) failed,
}) async {

  print('Sending OTP to: $phoneNumber');

  await _firebaseAuth.verifyPhoneNumber(
    phoneNumber: phoneNumber,

    verificationCompleted: (PhoneAuthCredential credential) async {
      print('verificationCompleted');
      await _firebaseAuth.signInWithCredential(credential);
    },

    verificationFailed: (FirebaseAuthException error) {
      print('verificationFailed: ${error.code}');
      print('verificationFailed: ${error.message}');
      failed(error.message ?? 'Authentication Failed');
    },

    codeSent: (String verificationId, int? resendToken) {
      print('codeSent');
      print('verificationId: $verificationId');
      codeSent(verificationId);
    },

    codeAutoRetrievalTimeout: (String verificationId) {
      print('codeAutoRetrievalTimeout');
    },
  );
}
  Future<UserCredential> verifyOtp({
    required String verificationId,

    required String otp,
  }) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    return await _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}

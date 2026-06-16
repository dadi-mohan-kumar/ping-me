import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pingme/bloc/auth/auth_bloc.dart';
import 'package:pingme/bloc/auth/auth_event.dart';
import 'package:pingme/bloc/auth/auth_state.dart';
import 'package:pingme/repositories/chat_repository.dart';
import 'package:pingme/screens/contact.dart';

import 'package:pingme/screens/name.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;

  const OtpScreen({super.key, required this.verificationId});

  @override
  State<OtpScreen> createState() {
    return _OtpScreenState();
  }
}

class _OtpScreenState extends State<OtpScreen> {
  final formKey = GlobalKey<FormState>();

  String otp = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: CommonAppBar.build(context),

      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthenticatedState) {
            final user = FirebaseAuth.instance.currentUser!;

            final chatRepository = ChatRepository();

            final exists = await chatRepository.userExists(user.uid);

            if (!mounted) {
              return;
            }

            if (exists) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) {
                    return const ContactScreen();
                  },
                ),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) {
                    return const ProfileSetupScreen();
                  },
                ),
              );
            }
          }

          if (state is AuthErrorState) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },

        builder: (context, state) {
          return Center(
            child: Column(
              children: [
                Image.asset('assets/pingMe.png'),
                Card(
                  margin: const EdgeInsets.all(16),
                
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                
                    child: Form(
                      key: formKey,
                
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                
                        children: [
                          const Text('Enter OTP'),
                
                          const SizedBox(height: 20),
                
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Enter OTP',
                
                              border: OutlineInputBorder(),
                            ),
                
                            keyboardType: TextInputType.number,
                
                            validator: (value) {
                              if (value == null || value.trim().length != 6) {
                                return 'Enter valid OTP';
                              }
                
                              return null;
                            },
                
                            onSaved: (value) {
                              otp = value!;
                            },
                          ),
                
                          const SizedBox(height: 20),
                
                          SizedBox(
                            width: double.infinity,
                
                            child: ElevatedButton(
                              onPressed: state is AuthLoading
                                  ? null
                                  : () {
                                      final isValid = formKey.currentState!
                                          .validate();
                
                                      if (!isValid) {
                                        return;
                                      }
                
                                      formKey.currentState!.save();
                
                                      context.read<AuthBloc>().add(
                                        VerifyOtpEvent(
                                          verificationId: widget.verificationId,
                
                                          otp: otp,
                                        ),
                                      );
                                    },
                
                              child: state is AuthLoading
                                  ? const CircularProgressIndicator()
                                  : const Text('Verify'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

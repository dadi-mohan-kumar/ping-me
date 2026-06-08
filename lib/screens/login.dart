import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pingme/bloc/auth/auth_bloc.dart';
import 'package:pingme/bloc/auth/auth_event.dart';
import 'package:pingme/bloc/auth/auth_state.dart';

import 'package:pingme/screens/otp.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();

  String phoneNumber = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: CommonAppBar.build(context),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OtpSentState) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return OtpScreen(verificationId: state.verificationId);
                },
              ),
            );
          }

          if (state is AuthErrorState) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },

        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset('assets/pingMe.png'),
                  Padding(
                    padding: const EdgeInsets.all(16),

                    child: Card(
                      elevation: 5,

                      child: Padding(
                        padding: const EdgeInsets.all(16),

                        child: Form(
                          key: formKey,

                          child: Column(
                            mainAxisSize: MainAxisSize.min,

                            children: [
                              const Text(
                                'Login',

                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 20),

                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Phone Number',

                                  border: OutlineInputBorder(),

                                  prefixText: '+91 ',
                                ),

                                keyboardType: TextInputType.phone,

                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length != 10) {
                                    return 'Enter valid phone number';
                                  }

                                  return null;
                                },

                                onSaved: (value) {
                                  phoneNumber = value!;
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
                                            SendOtpEvent(
                                              phoneNumber: '+91$phoneNumber',
                                            ),
                                          );
                                        },

                                  child: state is AuthLoading
                                      ? const CircularProgressIndicator()
                                      : const Text('Continue'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

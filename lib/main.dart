import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pingme/bloc/auth/auth_bloc.dart';
import 'package:pingme/bloc/auth/auth_state.dart';
import 'package:pingme/firebase_options.dart';
import 'package:pingme/screens/contact.dart';
import 'package:pingme/screens/login.dart';
import 'package:pingme/services/notificationService.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pingme/l10n/app_localizations.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Background message: ${message.messageId}');
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await NotificationService().initialize();

  runApp(const PingMeApp());
}

class PingMeApp extends StatefulWidget {
  const PingMeApp({super.key});

  static _PingMeAppState of(BuildContext context) {
    return context.findAncestorStateOfType<_PingMeAppState>()!;
  }

  @override
  State<PingMeApp> createState() => _PingMeAppState();
}

class _PingMeAppState extends State<PingMeApp> {
  bool isDarkMode = false;

  void changeTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  Locale _locale = const Locale('en');

  void changeLanguage(String languageCode) {
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(),

      child: MaterialApp(
        navigatorKey: navigatorKey,
        locale: _locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        supportedLocales: AppLocalizations.supportedLocales,

        debugShowCheckedModeBanner: false,
        themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        darkTheme: ThemeData.dark(),

        // Use a BlocConsumer or separate Listener/Builder to catch auth transitions
        home: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthenticatedState) {
              // Whenever a user logs in or is verified active on boot,
              // sync their token to Firestore seamlessly!
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                NotificationService().saveUserTokenToDatabase(user.uid);
              }
            }
          },
          builder: (context, state) {
            if (state is AuthenticatedState) {
              return const ContactScreen();
            } else if (state is UnAuthenticatedState) {
              return const LoginScreen();
            }

            // Cold start fallback behavior
            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser != null) {
              // Trigger the initial token save for silent cold updates
              NotificationService().saveUserTokenToDatabase(currentUser.uid);
              return const ContactScreen();
            }

            return const LoginScreen();
          },
        ),
      ),
    );
  }
}

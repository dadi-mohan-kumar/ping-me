import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pingme/main.dart';
import 'package:pingme/screens/login.dart';
import 'package:pingme/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<Map<String, dynamic>?> getUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    final appState = PingMeApp.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),

      body: FutureBuilder<Map<String, dynamic>?>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data!;
          final l10n = AppLocalizations.of(context)!;

          return Column(
            children: [
              SizedBox(height: 10),
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(userData['profileImage']),
              ),
              SizedBox(height: 7),
              Center(
                child: Text(
                  userData['name'],
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),

              ListTile(
                leading: const Icon(Icons.language),
                title: Text('languages'),
                subtitle: const Text('English / తెలుగు'),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: const Text('English'),
                            onTap: () {
                              appState.changeLanguage('en');
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: const Text('తెలుగు'),
                            onTap: () {
                              appState.changeLanguage('te');
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 10),

              SwitchListTile(
                title: Text(AppLocalizations.of(context)!.darkTheme),

                value: appState.isDarkMode,

                onChanged: (value) {
                  appState.changeTheme(value);
                },
              ),

              SizedBox(height: 15),

              ListTile(
                title: Text(AppLocalizations.of(context)!.logout),
                trailing: Icon(Icons.logout, color: Colors.red),

                onTap: () async {
                  await FirebaseAuth.instance.signOut();

                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

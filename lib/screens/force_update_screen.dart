import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdateScreen extends StatelessWidget {
  final String playStoreUrl;

  const ForceUpdateScreen({super.key, required this.playStoreUrl});

  Future<void> openStore() async {
    await launchUrl(
      Uri.parse(playStoreUrl),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.system_update, size: 100),

              SizedBox(height: 20),

              Text(
                'Update Required',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10),

              Text(
                'Please update the app to continue.',
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 30),

              ElevatedButton(onPressed: openStore, child: Text('Update Now')),
            ],
          ),
        ),
      ),
    );
  }
}

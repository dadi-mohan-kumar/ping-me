import 'package:flutter/material.dart';
import 'package:pingme/screens/settings.dart';

class CommonAppBar {

  static AppBar build(BuildContext context ){
    return AppBar(
      title: Text('PING ME'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [IconButton(onPressed: () {
           Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return SettingsScreen();
                            },
                          ),
                        );
        }, icon: Icon(Icons.settings))],
    );
  }
}
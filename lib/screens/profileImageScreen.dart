import 'package:flutter/material.dart';
import 'package:pingme/widgets/app_theme.dart';

class ProfileImageScreen extends StatelessWidget {
  final String imageUrl;
  final String name;

  const ProfileImageScreen({
    super.key,
    required this.imageUrl,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(title: Text(name), backgroundColor: AppColors.dark),
      body: Center(
        child: Hero(
          tag: imageUrl,
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: SizedBox(
              width: 300,
              height: 300,
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ChatTile extends StatelessWidget {

  final String name;

  final String imageUrl;

  final VoidCallback onTap;

  const ChatTile({

    super.key,

    required this.name,

    required this.imageUrl,

    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return ListTile(

      leading: CircleAvatar(
        backgroundImage:
            NetworkImage(imageUrl),
      ),

      title: Text(name),

      onTap: onTap,
    );
  }
}
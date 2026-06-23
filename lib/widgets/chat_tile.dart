import 'package:flutter/material.dart';

class ChatTile extends StatelessWidget {

  final String name;

  final String imageUrl;

  final VoidCallback onTap;

  final String phone;

  const ChatTile({

    super.key,

    required this.name,

    required this.imageUrl,

    required this.onTap,

    required this.phone,
  });

  @override
  Widget build(BuildContext context) {

    return ListTile(

      leading: CircleAvatar(
        backgroundImage:
            NetworkImage(imageUrl),
      ),

      title: Text(name),
      subtitle: Text(phone),

      onTap: onTap,
    );
  }
}
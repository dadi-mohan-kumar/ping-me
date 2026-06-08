import 'package:flutter/material.dart';
import 'package:pingme/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;

  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          isMe
              ? Alignment.centerRight
              : Alignment.centerLeft,

      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 3,
        ),

        padding: const EdgeInsets.all(12),

        constraints: const BoxConstraints(
          maxWidth: 250,
        ),

        decoration: BoxDecoration(
          color:
              isMe
                  ? Colors.blue
                  : Colors.grey.shade300,

          borderRadius:
              BorderRadius.circular(12),
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.end,

          children: [
            Text(
              message.message,

              style: TextStyle(
                color:
                    isMe
                        ? Colors.white
                        : Colors.black,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              _formatTime(
                message.timestamp,
              ),

              style: TextStyle(
                fontSize: 10,
                color:
                    isMe
                        ? Colors.white70
                        : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(
    DateTime dateTime,
  ) {
    final hour =
        dateTime.hour
            .toString()
            .padLeft(2, '0');

    final minute =
        dateTime.minute
            .toString()
            .padLeft(2, '0');

    return '$hour:$minute';
  }
}
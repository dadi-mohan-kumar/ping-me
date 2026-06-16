import 'package:flutter/material.dart';
import 'package:pingme/models/message_model.dart';
import 'package:intl/intl.dart';
import 'package:pingme/widgets/app_theme.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;

  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(maxWidth: 250),
            decoration: BoxDecoration(
              color: isMe ? AppColors.primary : AppColors.grey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message.message,
                  style: TextStyle(
                    color: isMe ? AppColors.secondary : AppColors.dark,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: isMe ? AppColors.white : AppColors.dark,
                      ),
                    ),

                    if (isMe) ...[
                      const SizedBox(width: 4),

                      Icon(
                        message.isSeen ? Icons.done_all : Icons.done,
                        size: 16,
                        color: message.isSeen ? Colors.blue : Colors.grey,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          if (message.reaction != null)
            Positioned(
              bottom: -8,
              right: isMe ? 18 : null,
              left: isMe ? null : 18,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 3),
                  ],
                ),
                child: Text(
                  message.reaction!,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }
}

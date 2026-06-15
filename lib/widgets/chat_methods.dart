// import 'package:flutter/material.dart';
// import 'package:pingme/repositories/chat_repository.dart';

// class ChatMethods {

//   ChatRepository chatRepository = ChatRepository();

//   static void showReactionPicker(
//   BuildContext context,
//   String messageId,
//   Widget widget
// ) {
//   final emojis = [
//     '👍',
//     '❤️',
//     '😂',
//     '😮',
//     '😢',
//     '🙏',
//   ];

//   showDialog(
//     context: context,
//     barrierColor: Colors.transparent,
//     builder: (_) {
//       return Dialog(
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: emojis.map((emoji) {
//               return InkWell(
//                 onTap: () async {
//                   Navigator.pop(context);

//                   await chatRepository.reactToMessage(
//                     chatId: widget.chatId,
//                     messageId: messageId,
//                     reaction: emoji,
//                   );
//                 },
//                 child: Text(
//                   emoji,
//                   style: const TextStyle(fontSize: 30),
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//       );
//     },
//   );
// }

// }
// import 'package:flutter/material.dart';
// import 'package:pingme/dummy/dummyChat.dart';
// import 'package:pingme/widgets/message_bubble.dart';

// class ChatScreen extends StatefulWidget {
//   final String chatId;
//   final String name;
//   final String imageUrl;

//   const ChatScreen({super.key, required this.chatId ,required this.name, required this.imageUrl});

//   @override
//   State<ChatScreen> createState() {
//     return _ChatScreenState();
//   }
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final messageController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             CircleAvatar(backgroundImage: NetworkImage(widget.imageUrl)),

//             const SizedBox(width: 10),

//             Text(widget.name),
//           ],
//         ),
//       ),

//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               reverse: true,

//               padding: const EdgeInsets.only(top: 10),

//               itemCount: dummyMessages.length,

//               itemBuilder: (context, index) {
//                 return MessageBubble(message: dummyMessages[index]);

//               },
//             ),
//           ),

//           Container(
//             padding: const EdgeInsets.all(10),

//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: messageController,

//                     decoration: InputDecoration(
//                       hintText: 'Type a message',

//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(25),
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(width: 10),

//                 CircleAvatar(
//                   child: IconButton(
//                     onPressed: () {},

//                     icon: const Icon(Icons.send),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:pingme/models/message_model.dart';

import 'package:pingme/repositories/chat_repository.dart';
import 'package:pingme/services/fcmService.dart';

import 'package:pingme/widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  final String name;
  final String receiverId;
  final String imageUrl;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.name,
    required this.receiverId,
    required this.imageUrl,
  });

  @override
  State<ChatScreen> createState() {
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();

  final ScrollController scrollController = ScrollController();

  final ChatRepository chatRepository = ChatRepository();

  Future<void> sendMessage() async {
    final text = messageController.text.trim();

    if (text.isEmpty) {
      return;
    }

    final receiverToken = await chatRepository.getUserFcmToken(
      widget.receiverId,
    );

    print('Receiver Token: $receiverToken');

    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    final message = MessageModel(
      senderId: currentUserId,
      receiverId: widget.receiverId,
      message: text,
      timestamp: DateTime.now(),
      isSeen: false,
    );

    // Save message in Firestore
    await chatRepository.sendMessage(chatId: widget.chatId, message: message);

    final senderDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();

    final senderName = senderDoc.data()?['name'] ?? 'PingMe';

    // Send push notification
    if (receiverToken != null && receiverToken.isNotEmpty) {
      await FCMService.sendPushNotification(
        receiverToken: receiverToken,
        title: senderName,
        // title: FirebaseAuth.instance.currentUser!.displayName.toString(),
        body: text,
        chatId: widget.chatId,
        senderId: currentUserId,
      );
    }

    messageController.clear();
  }

  @override
  void dispose() {
    messageController.dispose();

    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(widget.imageUrl)),

            const SizedBox(width: 10),

            Expanded(child: Text(widget.name, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: chatRepository.getMessages(widget.chatId),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Start the conversation'));
                }

                final docs = snapshot.data!.docs;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (scrollController.hasClients) {
                    scrollController.jumpTo(
                      scrollController.position.maxScrollExtent,
                    );
                  }
                });

                return ListView.builder(
                  controller: scrollController,

                  itemCount: docs.length,

                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    final message = MessageModel.fromMap(data);

                    final isMe = message.senderId == currentUserId;

                    return MessageBubble(message: message, isMe: isMe);
                  },
                );
              },
            ),
          ),

          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(10),

              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,

                      textCapitalization: TextCapitalization.sentences,

                      decoration: InputDecoration(
                        hintText: 'Type a message',

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),

                      onSubmitted: (_) {
                        sendMessage();
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  CircleAvatar(
                    child: IconButton(
                      onPressed: sendMessage,

                      icon: const Icon(Icons.send),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

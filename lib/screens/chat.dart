import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:pingme/models/message_model.dart';

import 'package:pingme/repositories/chat_repository.dart';
import 'package:pingme/services/fcmService.dart';
import 'package:pingme/l10n/app_localizations.dart';
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

  Timer? typingTimer;

  @override
  void initState() {
    super.initState();

    chatRepository.markMessageAsSeen(
      widget.chatId,
      FirebaseAuth.instance.currentUser!.uid,
    );
  }

  Future<void> showEditDialog({
    required String messageId,
    required String currentMessage,
  }) async {
    final controller = TextEditingController(text: currentMessage);

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Edit Message'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final text = controller.text.trim();

                if (text.isEmpty) {
                  return;
                }

                await chatRepository.editMessage(
                  chatId: widget.chatId,
                  messageId: messageId,
                  newMessage: text,
                );

                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void showReactionPicker(BuildContext context, String messageId) {
    final emojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (_) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: emojis.map((emoji) {
                return InkWell(
                  onTap: () async {
                    Navigator.pop(context);

                    await chatRepository.reactToMessage(
                      chatId: widget.chatId,
                      messageId: messageId,
                      reaction: emoji,
                    );
                  },
                  child: Text(emoji, style: const TextStyle(fontSize: 30)),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  bool isSending = false;

  Future<void> sendMessage() async {
    final canSend = await chatRepository.canSendMessage(
      senderId: FirebaseAuth.instance.currentUser!.uid,
      receiverId: widget.receiverId,
    );

    if (!canSend) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You cannot send messages to this user'),
          ),
        );
      }

      return;
    }

    final isBlocked = await chatRepository.isBlocked(
      currentUserId: FirebaseAuth.instance.currentUser!.uid,
      otherUserId: widget.receiverId,
    );

    if (isBlocked) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have blocked this user')),
        );
      }

      return;
    }

    if (isSending) return;

    final text = messageController.text.trim();

    if (text.isEmpty) return;

    isSending = true;

    try {
      final receiverToken = await chatRepository.getUserFcmToken(
        widget.receiverId,
      );

      final currentUserId = FirebaseAuth.instance.currentUser!.uid;

      final message = MessageModel(
        senderId: currentUserId,
        receiverId: widget.receiverId,
        message: text,
        timestamp: DateTime.now(),
        isSeen: false,
      );

      await chatRepository.stopTyping(chatId: widget.chatId);

      await chatRepository.sendMessage(chatId: widget.chatId, message: message);

      final senderDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      final senderName = senderDoc.data()?['name'] ?? 'PingMe';

      if (receiverToken != null && receiverToken.isNotEmpty) {
        await FCMService.sendPushNotification(
          receiverToken: receiverToken,
          title: senderName,
          body: text,
          chatId: widget.chatId,
          senderId: currentUserId,
        );
      }

      messageController.clear();
    } finally {
      if (mounted) {
        isSending = false;
      }
    }
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

            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(widget.chatId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Text(widget.name);
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;

                  final typingBy = data['typingBy'] ?? '';

                  final isTyping = typingBy == widget.receiverId;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.name),

                      if (isTyping)
                        const Text(
                          'typing...',
                          style: TextStyle(fontSize: 12, color: Colors.green),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),

        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'block') {
                await chatRepository.blockUser(
                  currentUserId: FirebaseAuth.instance.currentUser!.uid,
                  blockedUserId: widget.receiverId,
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('User blocked')));
                }
              }

              if (value == 'unblock') {
                await chatRepository.unblockUser(
                  currentUserId: FirebaseAuth.instance.currentUser!.uid,
                  blockedUserId: widget.receiverId,
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User unblocked')),
                  );
                }
              }
            },

            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(Icons.block),
                    SizedBox(width: 8),
                    Text('Block User'),
                  ],
                ),
              ),

              const PopupMenuItem(
                value: 'unblock',
                child: Row(
                  children: [
                    Icon(Icons.lock_open),
                    SizedBox(width: 8),
                    Text('Unblock User'),
                  ],
                ),
              ),
            ],
          ),
        ],
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

                if (snapshot.hasData) {
                  chatRepository.markMessageAsSeen(
                    widget.chatId,
                    currentUserId,
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      AppLocalizations.of(context)!.startConversation,
                    ),
                  );
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
                    // final data = docs[index].data() as Map<String, dynamic>;
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final message = MessageModel.fromMap(data);

                    if ((message.deletedFor).contains(currentUserId)) {
                      return const SizedBox.shrink();
                    }

                    final isMe = message.senderId == currentUserId;

                    return GestureDetector(
                      onDoubleTap: () {
                        showReactionPicker(context, doc.id);
                      },

                      onLongPress: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (_) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: Icon(Icons.delete_outline),
                                  title: Text('Delete for me'),
                                  onTap: () async {
                                    Navigator.pop(context);

                                    await chatRepository.deleteForMe(
                                      chatId: widget.chatId,
                                      messageId: doc.id,
                                      userId: currentUserId,
                                    );
                                  },
                                ),
                                if (isMe)
                                  ListTile(
                                    leading: const Icon(Icons.edit),
                                    title: const Text('Edit Message'),
                                    onTap: () {
                                      Navigator.pop(context);

                                      showEditDialog(
                                        messageId: doc.id,
                                        currentMessage: message.message,
                                      );
                                    },
                                  ),

                                if (isMe)
                                  ListTile(
                                    leading: Icon(Icons.delete_forever),
                                    title: Text('Delete for everyone'),
                                    onTap: () async {
                                      Navigator.pop(context);

                                      await chatRepository.deleteForEveryone(
                                        chatId: widget.chatId,
                                        messageId: doc.id,
                                      );
                                    },
                                  ),
                              ],
                            );
                          },
                        );
                      },
                      child: MessageBubble(message: message, isMe: isMe),
                    );
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
                      onChanged: (value) async {
                        if (value.isNotEmpty) {
                          await chatRepository.setTyping(
                            chatId: widget.chatId,
                            userId: currentUserId,
                          );

                          typingTimer?.cancel();

                          typingTimer = Timer(
                            const Duration(seconds: 2),
                            () async {
                              await chatRepository.stopTyping(
                                chatId: widget.chatId,
                              );
                            },
                          );
                        } else {
                          await chatRepository.stopTyping(
                            chatId: widget.chatId,
                          );
                        }
                      },

                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.typeMessage,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),

                      onSubmitted: (_) {
                        if (!isSending) {
                          sendMessage();
                        }
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

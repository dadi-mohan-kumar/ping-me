import 'package:flutter/material.dart';
import 'package:pingme/screens/all_contact.dart';
import 'package:pingme/screens/chat.dart';
import 'package:pingme/screens/force_update_screen.dart';
import 'package:pingme/screens/profileImageScreen.dart';
import 'package:pingme/screens/settings.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pingme/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pingme/repositories/chat_repository.dart';
import 'package:pingme/services/notificationService.dart';
import 'package:intl/intl.dart';
import 'package:pingme/services/remote_config_service.dart';
import 'package:pingme/widgets/app_theme.dart';
import 'package:pingme/widgets/chat_tile.dart';

// class ContactScreen extends StatefulWidget {
//   const ContactScreen({super.key});

//   @override
//   State<ContactScreen> createState() {
//     return _ContactScreenState();
//   }
// }

// class _ContactScreenState extends State<ContactScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat'),
//         actions: [
//           ElevatedButton(onPressed: () {
//              Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (context) {
//                               return AllContact();
//                             },
//                           ),
//                         );
//           }, child: Icon(Icons.add)),
//           ElevatedButton(onPressed: () {
//              Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (context) {
//                               return SettingsScreen();
//                             },
//                           ),
//                         );
//           }, child: Icon(Icons.settings)),

//         ],
//       ),
//       body: ListView.builder(
//         itemCount: dummyContacts.length,
//         itemBuilder: (context, index) {
//           final contact = dummyContacts[index];

//           return ListTile(
//             leading: CircleAvatar(
//               backgroundImage: NetworkImage(contact.imageUrl),
//             ),
//             title: Text(contact.name),
//             subtitle: Text(contact.message),

//             trailing: Text(contact.time),
//             onTap: () {
//               Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (context) {
//                               return ChatScreen(name: '${contact.name}',imageUrl: '${contact.imageUrl}',);
//                             },
//                           ),
//                         );
//             },

//           );

//         },
//       ),
//     );
//   }
// }

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() {
    return _ContactScreenState();
  }
}

class _ContactScreenState extends State<ContactScreen> {
  final ChatRepository chatRepository = ChatRepository();

  String searchText = '';

  Future<void> checkForceUpdate() async {
    final forceUpdate = await ForceUpdateService.isUpdateRequired();

    if (!mounted) return;

    if (forceUpdate) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ForceUpdateScreen(playStoreUrl: ForceUpdateService.getStoreUrl()),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    checkForceUpdate();
    NotificationService().initialize();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(AppLocalizations.of(context)!.chats),

          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const AllContact()));
              },
              icon: const Icon(Icons.add),
            ),

            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
              icon: const Icon(Icons.settings),
            ),
          ],
        ),

        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),

              child: TextField(
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchChats,

                  prefixIcon: Icon(Icons.search, color: AppColors.primary),

                  border: OutlineInputBorder(),
                ),

                onChanged: (value) {
                  setState(() {
                    searchText = value.toLowerCase();
                  });
                },
              ),
            ),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: chatRepository.getChats(currentUserId),

                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(AppLocalizations.of(context)!.noChatsYet),
                    );
                  }

                  final chats = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: chats.length,

                    itemBuilder: (context, index) {
                      final chat = chats[index];

                      final chatData = chat.data() as Map<String, dynamic>;

                      final participants = List<String>.from(
                        chatData['participants'],
                      );

                      participants.remove(currentUserId);

                      if (participants.isEmpty) {
                        return const SizedBox();
                      }

                      final otherUserId = participants.first;

                      return StreamBuilder<DocumentSnapshot>(
                        stream: chatRepository.getUserStream(otherUserId),

                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox();
                          }

                          if (!userSnapshot.hasData ||
                              !userSnapshot.data!.exists) {
                            return const SizedBox();
                          }

                          final userData =
                              userSnapshot.data!.data() as Map<String, dynamic>;
                          final bool isOnline = userData['isOnline'] ?? false;

                          final name = userData['name']
                              .toString()
                              .toLowerCase();

                          final dynamic lastMessageTime =
                              chatData['lastMessageTime'];

                          DateTime dateTime;

                          if (lastMessageTime is Timestamp) {
                            dateTime = lastMessageTime.toDate();
                          } else if (lastMessageTime is String) {
                            dateTime = DateTime.parse(lastMessageTime);
                          } else {
                            dateTime = DateTime.now();
                          }

                          final now = DateTime.now();

                          String displayTime;

                          if (dateTime.day == now.day &&
                              dateTime.month == now.month &&
                              dateTime.year == now.year) {
                            displayTime = DateFormat('h:mm a').format(dateTime);
                          } else if (dateTime.day ==
                                  now.subtract(const Duration(days: 1)).day &&
                              dateTime.month ==
                                  now.subtract(const Duration(days: 1)).month &&
                              dateTime.year ==
                                  now.subtract(const Duration(days: 1)).year) {
                            displayTime = 'Yesterday';
                          } else {
                            displayTime =
                                '${dateTime.day.toString().padLeft(2, '0')}/'
                                '${dateTime.month.toString().padLeft(2, '0')}/'
                                '${dateTime.year}';
                          }

                          if (!name.contains(searchText)) {
                            return const SizedBox();
                          }

                          return GestureDetector(
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (_) {
                                  return AlertDialog(
                                    title: const Text('Delete Chat'),
                                    content: Text(
                                      'Are you sure you want to delete the chat with ${userData['name']}?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);

                                          await chatRepository.deleteChat(
                                            chatId: chat.id,
                                          );

                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text('Chat deleted'),
                                              ),
                                            );
                                          }
                                        },
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: ListTile(
                              leading: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProfileImageScreen(
                                        imageUrl: userData['profileImage'],
                                        name: userData['name'],
                                      ),
                                    ),
                                  );
                                },
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundImage: NetworkImage(
                                        userData['profileImage'],
                                      ),
                                    ),

                                    if (isOnline)
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              title: Text(userData['name']),

                              subtitle: Text(
                                chatData['lastMessage'] ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              trailing: Text(displayTime),

                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                      chatId: chat.id,
                                      name: userData['name'],
                                      imageUrl: userData['profileImage'],
                                      receiverId: otherUserId,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

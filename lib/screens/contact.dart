import 'package:flutter/material.dart';
import 'package:pingme/screens/all_contact.dart';
import 'package:pingme/screens/chat.dart';
import 'package:pingme/screens/settings.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:pingme/repositories/chat_repository.dart';
import 'package:pingme/services/notificationService.dart';

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

   @override
    void initState() {
      super.initState();

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
          title: const Text('Chats'),

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
                decoration: const InputDecoration(
                  hintText: 'Search chats',

                  prefixIcon: Icon(Icons.search),

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
                    return const Center(child: Text('No Chats Yet'));
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

                      return FutureBuilder<DocumentSnapshot>(
                        future: chatRepository.getUserById(otherUserId),

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
                            displayTime =
                                '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
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

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                userData['profileImage'],
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

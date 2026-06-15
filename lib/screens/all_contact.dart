import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pingme/repositories/chat_repository.dart';
import 'package:pingme/screens/chat.dart';
import 'package:pingme/widgets/chat_tile.dart';

class AllContact extends StatefulWidget {
  const AllContact({super.key});

  @override
  State<AllContact> createState() {
    return _AllContactState();
  }
}

class _AllContactState extends State<AllContact> {
  final ChatRepository chatRepository = ChatRepository();

  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  String searchText = '';

  @override
  Widget build(BuildContext context) {
    //  final token = FirebaseMessaging.instance.getToken();
    //  print(token);

    return Scaffold(
      appBar: AppBar(title: const Text('All Contacts')),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),

            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search users',

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
              stream: chatRepository.getUsers(),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData) {
                  return const Center(child: Text('No Users Found'));
                }

                final users = snapshot.data!.docs;

                final filteredUsers = users.where((user) {
                  final data = user.data() as Map<String, dynamic>;

                  final name = data['name'].toString().toLowerCase();

                  return name.contains(searchText);
                }).toList();

                return ListView.builder(
                  itemCount: filteredUsers.length,

                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];

                    final data = user.data() as Map<String, dynamic>;

                    if (data['uid'] == currentUserId) {
                      return const SizedBox();
                    }

                    return ChatTile(
                      name: data['name'],

                      imageUrl: data['profileImage'],

                      onTap: () async {
                        final chatId = await chatRepository.createChat(
                          currentUserId: currentUserId,

                          otherUserId: data['uid'],
                        );

                        if (!mounted) {
                          return;
                        }

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return ChatScreen(
                                chatId: chatId,

                                name: data['name'],

                                imageUrl: data['profileImage'],
                                receiverId: data['uid'],
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
    );
  }
}

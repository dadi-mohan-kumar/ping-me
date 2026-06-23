import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pingme/repositories/chat_repository.dart';
import 'package:pingme/screens/chat.dart';
import 'package:pingme/widgets/chat_tile.dart';

class DiscoverPeopleScreen extends StatefulWidget {
  const DiscoverPeopleScreen({super.key});

  @override
  State<DiscoverPeopleScreen> createState() {
    return _DiscoverPeopleScreenState();
  }
}

class _DiscoverPeopleScreenState extends State<DiscoverPeopleScreen> {
  final ChatRepository chatRepository = ChatRepository();

  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  String searchText = '';

  @override
  Widget build(BuildContext context) {
    //  final token = FirebaseMessaging.instance.getToken();
    //  print(token);

    return Scaffold(
      appBar: AppBar(title: const Text('Discover people')),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),

            child: TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Search users by phone number',

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
            child: searchText.trim().isEmpty
                ? const Center(child: Text('Search users by phone number'))
                : StreamBuilder<QuerySnapshot>(
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

                        final phone = data['phoneNumber']
                            .toString()
                            .toLowerCase();

                        return phone.contains(searchText);
                      }).toList();

                      if (filteredUsers.isEmpty) {
                        return const Center(
                          child: Text('No matching users found'),
                        );
                      }

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
                            phone: data['phoneNumber'],
                            onTap: () async {
                              final chatId = await chatRepository.createChat(
                                currentUserId: currentUserId,
                                otherUserId: data['uid'],
                              );

                              if (!mounted) return;

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    chatId: chatId,
                                    receiverId: data['uid'],
                                    name: data['name'],
                                    imageUrl: data['profileImage'],
                                  ),
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

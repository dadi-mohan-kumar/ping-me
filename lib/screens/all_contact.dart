import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:pingme/models/discover_user_model.dart';
import 'package:pingme/repositories/chat_repository.dart';
import 'package:pingme/repositories/contact_repositor.dart';
import 'package:pingme/screens/chat.dart';

class AllContacts extends StatefulWidget {
  const AllContacts({super.key});

  @override
  State<AllContacts> createState() => _AllContactsState();
}

class _AllContactsState extends State<AllContacts> {
  final ContactRepository contactRepository = ContactRepository();

  final ChatRepository chatRepository = ChatRepository();

  final TextEditingController searchController = TextEditingController();

  List<Contact> allContacts = [];

  List<Contact> searchResults = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    loadContacts();
  }

  Future<void> loadContacts() async {
    setState(() {
      isLoading = true;
    });

    allContacts = await contactRepository.getDeviceContacts();

    setState(() {
      searchResults = allContacts;
      isLoading = false;
    });
  }

  void searchContacts(String query) {
    final lowerQuery = query.toLowerCase().trim();

    if (lowerQuery.isEmpty) {
      setState(() {
        searchResults = allContacts;
      });
      return;
    }

    final filtered = allContacts.where((contact) {
      final name = contact.displayName.toLowerCase();

      final phone = contact.phones.isNotEmpty
          ? contact.phones.first.number
          : '';

      return name.contains(lowerQuery) || phone.contains(query);
    }).toList();

    setState(() {
      searchResults = filtered;
    });
  }

  String normalizePhone(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');

    // if (cleaned.startsWith('91') && cleaned.length > 10) {
    //   cleaned = cleaned.substring(cleaned.length - 10);
    // }

    return cleaned;
  }

  Future<void> openChat(DiscoverUserModel user) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    final chatId = await chatRepository.createChat(
      currentUserId: currentUserId,
      otherUserId: user.uid!,
    );

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          chatId: chatId,
          receiverId: user.uid!,
          name: user.name,
          imageUrl: user.profileImage ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Contacts')),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,

              decoration: const InputDecoration(
                hintText: 'Search people',
                prefixIcon: Icon(Icons.search),
              ),

              onChanged: searchContacts,
            ),
          ),

          if (isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,

                itemBuilder: (context, index) {
                  final contact = searchResults[index];

                  if (contact.phones.isEmpty) {
                    return const SizedBox();
                  }

                  final phone = normalizePhone(contact.phones.first.number);

                  return FutureBuilder(
                    future: chatRepository.findUserByPhone(phone),

                    builder: (context, snapshot) {
                      DiscoverUserModel user;

                      if (snapshot.hasData && snapshot.data != null) {
                        final doc = snapshot.data!;

                        final data = doc.data() as Map<String, dynamic>;

                        user = DiscoverUserModel.fromFirestore(
                          uid: doc.id,
                          data: data,
                        );
                      } else {
                        user = DiscoverUserModel.unregistered(
                          name: contact.displayName,
                          phoneNumber: phone,
                        );
                      }

                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            user.name.isNotEmpty ? user.name[0] : '?',
                          ),
                        ),

                        title: Text(user.name),

                        subtitle: Text(user.phoneNumber),

                        trailing: user.isRegistered
                            ? ElevatedButton(
                                onPressed: () {
                                  openChat(user);
                                },
                                child: const Text('Chat'),
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Invite ${user.name}'),
                                    ),
                                  );
                                },
                                child: const Text('Invite'),
                              ),
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

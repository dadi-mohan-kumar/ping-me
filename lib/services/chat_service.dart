import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pingme/models/message_model.dart';
import 'package:pingme/models/user_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUser(UserModel user) async {
    final token = await FirebaseMessaging.instance.getToken();

    print("FCM TOKEN: $token");

    final data = {
      ...user.toMap(),
      'fcmToken': token,
    };

    print(data);

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(data);

    print("USER SAVED");
  }

  Future<String> createChat({
    required String currentUserId,
    required String otherUserId,
  }) async {
    final chats = await _firestore
        .collection('chats')
        .where(
          'participants',
          arrayContains: currentUserId,
        )
        .get();

    for (var chat in chats.docs) {
      final participants =
          List<String>.from(chat['participants']);

      if (participants.contains(otherUserId)) {
        return chat.id;
      }
    }

    final chatDoc =
        await _firestore.collection('chats').add({
      'participants': [
        currentUserId,
        otherUserId,
      ],
      'lastMessage': '',
      'lastMessageTime': Timestamp.now(),
    });

    await _firestore
        .collection('users')
        .doc(currentUserId)
        .update({
      'chatBoardIds':
          FieldValue.arrayUnion([chatDoc.id]),
    });

    await _firestore
        .collection('users')
        .doc(otherUserId)
        .update({
      'chatBoardIds':
          FieldValue.arrayUnion([chatDoc.id]),
    });

    return chatDoc.id;
  }

  Future<void> sendMessage({
    required String chatId,
    required MessageModel message,
  }) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());

    await _firestore
        .collection('chats')
        .doc(chatId)
        .update({
      'lastMessage': message.message,
      'lastMessageTime':
          Timestamp.fromDate(message.timestamp),
    });
  }

  Stream<QuerySnapshot> getMessages(
    String chatId,
  ) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  Stream<QuerySnapshot> getChats(
    String currentUserId,
  ) {
    return _firestore
        .collection('chats')
        .where(
          'participants',
          arrayContains: currentUserId,
        )
        .orderBy(
          'lastMessageTime',
          descending: true,
        )
        .snapshots();
  }

  Future<bool> userExists(
    String uid,
  ) async {
    final document = await _firestore
        .collection('users')
        .doc(uid)
        .get();

    return document.exists;
  }

  Stream<QuerySnapshot> getUsers() {
    return _firestore
        .collection('users')
        .snapshots();
  }

  Future<DocumentSnapshot> getUserById(
    String uid,
  ) {
    return _firestore
        .collection('users')
        .doc(uid)
        .get();
  }

  Future<String?> getUserFcmToken(
    String uid,
  ) async {
    final document = await _firestore
        .collection('users')
        .doc(uid)
        .get();

    if (!document.exists) {
      return null;
    }

    final data =
        document.data() as Map<String, dynamic>;

    return data['fcmToken'];
  }

  Future<void> markMessageAsSeen({
    required String chatId,
    required String currentUserId,
  }) async {
    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where(
          'receiverId',
          isEqualTo: currentUserId,
        )
        .get();

    for (var doc in messages.docs) {
      await doc.reference.update({
        'isSeen': true,
      });
    }
  }
}
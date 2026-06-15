import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pingme/models/message_model.dart';
import 'package:pingme/models/user_model.dart';

import 'package:pingme/services/chat_service.dart';

class ChatRepository {
  final ChatService _chatService = ChatService();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUser(UserModel user) async {
    await _chatService.saveUser(user);
  }

  Future<String> createChat({
    required String currentUserId,

    required String otherUserId,
  }) async {
    return await _chatService.createChat(
      currentUserId: currentUserId,

      otherUserId: otherUserId,
    );
  }

  Future<void> sendMessage({
    required String chatId,

    required MessageModel message,
  }) async {
    await _chatService.sendMessage(chatId: chatId, message: message);
  }

  Stream<QuerySnapshot> getMessages(String chatId) {
    return _chatService.getMessages(chatId);
  }

  Stream<QuerySnapshot> getChats(String currentUserId) {
    return _chatService.getChats(currentUserId);
  }

  Future<bool> userExists(String uid) async {
    return await _chatService.userExists(uid);
  }

  Stream<QuerySnapshot> getUsers() {
    return _chatService.getUsers();
  }

  Future<DocumentSnapshot> getUserById(String uid) {
    return _chatService.getUserById(uid);
  }

  Future<void> markMessageAsSeen(String chatId, String currentUserId) async {
    await _chatService.markMessageAsSeen(
      chatId: chatId,
      currentUserId: currentUserId,
    );
  }

  Future<String?> getUserFcmToken(String uid) async {
    return await _chatService.getUserFcmToken(uid);
  }

  Future<void> deleteForMe({
    required String chatId,
    required String messageId,
    required String userId,
  }) async {
    await _chatService.deleteForMe(
      chatId: chatId,
      messageId: messageId,
      userId: userId,
    );
  }

  Future<void> deleteForEveryone({
    required String chatId,
    required String messageId,
  }) async {
    await _chatService.deleteForEveryone(chatId: chatId, messageId: messageId);
  }

  Future<void> deleteChat({required String chatId}) async {
    await _chatService.deleteChat(chatId: chatId);
  }

  Future<void> editMessage({
    required String chatId,
    required String messageId,
    required String newMessage,
  }) async {
    await _chatService.editMessage(
      chatId: chatId,
      messageId: messageId,
      newMessage: newMessage,
    );
  }

  Stream<DocumentSnapshot> getUserStream(String otherUserId) {
    return _firestore.collection('users').doc(otherUserId).snapshots();
  }

  Future<void> reactToMessage({
    required String chatId,
    required String messageId,
    required String reaction,
  }) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'reaction': reaction});
  }

  Future<void> setTyping({
    required String chatId,
    required String userId,
  }) async {
    await _firestore.collection('chats').doc(chatId).update({
      'typingBy': userId,
    });
  }

  Future<void> stopTyping({required String chatId}) async {
    await _firestore.collection('chats').doc(chatId).update({'typingBy': ''});
  }

  Future<void> blockUser({
    required String currentUserId,
    required String blockedUserId,
  }) async {
    await _firestore.collection('users').doc(currentUserId).update({
      'blockedUsers': FieldValue.arrayUnion([blockedUserId]),
    });
  }

  Future<void> unblockUser({
    required String currentUserId,
    required String blockedUserId,
  }) async {
    await _firestore.collection('users').doc(currentUserId).update({
      'blockedUsers': FieldValue.arrayRemove([blockedUserId]),
    });
  }

  Future<bool> isBlocked({
    required String currentUserId,
    required String otherUserId,
  }) async {
    final doc = await _firestore.collection('users').doc(currentUserId).get();

    final blockedUsers = List<String>.from(doc['blockedUsers'] ?? []);

    return blockedUsers.contains(otherUserId);
  }

  Future<bool> canSendMessage({
    required String senderId,
    required String receiverId,
  }) async {
    final senderDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(senderId)
        .get();

    final receiverDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .get();

    final senderBlocked = List<String>.from(senderDoc['blockedUsers'] ?? []);

    final receiverBlocked = List<String>.from(
      receiverDoc['blockedUsers'] ?? [],
    );

    if (senderBlocked.contains(receiverId)) {
      return false;
    }

    if (receiverBlocked.contains(senderId)) {
      return false;
    }

    return true;
  }
}

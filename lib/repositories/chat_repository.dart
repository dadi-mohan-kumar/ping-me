import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pingme/models/chat_board_model.dart';
import 'package:pingme/models/message_model.dart';
import 'package:pingme/models/user_model.dart';

import 'package:pingme/services/chat_service.dart';

class ChatRepository {
  final ChatService _chatService = ChatService();

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
}

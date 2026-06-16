import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pingme/main.dart';
import 'package:pingme/screens/chat.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initialize() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permissions.');
    } else {
      print('User denied notification permissions.');
    }

    String? token = await _messaging.getToken();

    print('FCM Token: $token');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
        'Foreground Notification: '
        '${message.notification?.title}',
      );

      print('Body: ${message.notification?.body}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      final senderId = message.data['senderId'];
      final chatId = message.data['chatId'];

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(senderId)
          .get();

      final userData = userDoc.data();

      if (userData == null) return;

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: chatId,
            receiverId: senderId,
            name: userData['name'],
            imageUrl: userData['profileImage'],
          ),
        ),
      );
    });

    final initialMessage = await _messaging.getInitialMessage();

    if (initialMessage != null) {
      print('App opened from terminated state');
    }

    // Token refresh listener
    _messaging.onTokenRefresh.listen((newToken) {
      print('New FCM Token: $newToken');
    });
  }

  Future<void> saveUserTokenToDatabase(String userId) async {
    try {
      String? token = await _messaging.getToken();

      if (token == null) return;

      await _firestore.collection('users').doc(userId).set({
        'fcmToken': token,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('FCM Token synchronized for user: $userId');
    } catch (e) {
      print('Failed to save token: $e');
    }
  }

  // static Future<void> sendPushNotification({
  //   required String receiverToken,
  //   required String title,
  //   required String body,
  // }) async {
  //   try {
  //     await http.post(
  //       Uri.parse('https://your-backend-url.com/sendNotification'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         'token': receiverToken,
  //         'title': title,
  //         'body': body,
  //       }),
  //     );
  //   } catch (e) {
  //     print('Notification Error: $e');
  //   }
  // }
}

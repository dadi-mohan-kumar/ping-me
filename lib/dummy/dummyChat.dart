

class MessageModel {
  final String message;
  final String time;
  final bool isMe;

  MessageModel({
    required this.message,
    required this.time,
    required this.isMe,
  });
}

// import 'package:pingme/models/message_model.dart';

final List<MessageModel> dummyMessages = [

MessageModel(
  message: 'Okay wait',
  isMe: true,
  time: '11:06 AM',
),

MessageModel(
  message: 'Send screenshots',
  isMe: false,
  time: '11:05 AM',
),

MessageModel(
  message: 'Almost done',
  isMe: true,
  time: '11:03 AM',
),

MessageModel(
  message: 'Completed the Flutter project?',
  isMe: false,
  time: '11:02 AM',
),

MessageModel(
  message: 'Hello',
  isMe: true,
  time: '11:01 AM',
),

MessageModel(
  message: 'Hey bro',
  isMe: false,
  time: '11:00 AM',
),

MessageModel(
  message: 'Okay wait',
  isMe: true,
  time: '10:06 AM',
),

MessageModel(
  message: 'Send screenshots',
  isMe: false,
  time: '10:05 AM',
),

MessageModel(
  message: 'Almost done',
  isMe: true,
  time: '10:03 AM',
),

MessageModel(
  message: 'Completed the Flutter project?',
  isMe: false,
  time: '10:02 AM',
),

MessageModel(
  message: 'Hello',
  isMe: true,
  time: '10:01 AM',
),

MessageModel(
  message: 'Hey bro',
  isMe: true,
  time: '10:00 AM',
),
];
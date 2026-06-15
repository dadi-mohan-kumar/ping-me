class MessageModel {
  
  final String senderId;

  final String receiverId;

  final String message;

  final DateTime timestamp;

  final bool isSeen;

  final bool isEdited;

  final List<String> deletedFor;

  final bool deletedForEveryone;

  final String? reaction;

  MessageModel({
    required this.senderId,

    required this.receiverId,

    required this.message,

    required this.timestamp,

    required this.isSeen,
    this.isEdited=false,

    this.deletedFor = const [],
    
    this.deletedForEveryone = false,
    this.reaction,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,

      'receiverId': receiverId,

      'message': message,

      'timestamp': timestamp.toIso8601String(),

      'isSeen': isSeen,

      'isEdited': isEdited,

      'deletedFor': deletedFor,

      'deletedForEveryone': deletedForEveryone,
      
      'reaction': reaction,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderId: map['senderId'],

      receiverId: map['receiverId'],

      message: map['message'],

      timestamp: DateTime.parse(map['timestamp']),

      isSeen: map['isSeen'],

      deletedFor: List<String>.from(map['deletedFor'] ?? []),

      deletedForEveryone: map['deletedForEveryone'] ?? false,

      isEdited: map['isEdited'] ?? false,

      reaction: map['reaction'],
    );
  }
}

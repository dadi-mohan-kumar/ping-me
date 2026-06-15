class ChatBoardModel {
  final String chatId;

  final List<String> participants;

  final String lastMessage;

  final DateTime lastMessageTime;

  final String? typingBy;

  ChatBoardModel({
    required this.chatId,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    this.typingBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime':
          lastMessageTime.toIso8601String(),
      'typingBy' : typingBy,
    };
  }

  factory ChatBoardModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return ChatBoardModel(
      chatId: map['chatId'],
      participants: List<String>.from(
        map['participants'],
      ),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: DateTime.parse(
        map['lastMessageTime'],
      ),
      typingBy: map['typingBy'],
    );
  }
}
class UserModel {
  final String uid;
  final String name;
  final String phoneNumber;
  final String profileImage;
  final List<String> chatBoardIds;
  final String fcmToken;
  final bool isOnline;
  final DateTime? lastSeen;
  final List<String> blockedUsers;

  UserModel({
    required this.uid,
    required this.name,
    required this.phoneNumber,
    required this.profileImage,
    required this.chatBoardIds,
    required this.fcmToken,
    this.isOnline = false,
    this.lastSeen,
    this.blockedUsers = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'chatBoardIds': chatBoardIds,
      'fcmToken': fcmToken,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
      'blockedUsers' : blockedUsers,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',

      name: map['name'] ?? '',

      phoneNumber: map['phoneNumber'] ?? '',

      profileImage: map['profileImage'] ?? '',

      chatBoardIds: List<String>.from(map['chatBoardIds'] ?? []),

      fcmToken: map['fcmToken'] ?? '',

      isOnline: map['isOnline'] ?? false,

      lastSeen: map['lastSeen'] != null
          ? DateTime.parse(map['lastSeen'])
          : null,

      blockedUsers: List<String>.from(map['blockedUsers'] ?? []),
    );
  }
}

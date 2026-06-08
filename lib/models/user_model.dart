class UserModel {

  final String uid;
  final String name;
  final String phoneNumber;
  final String profileImage;
  final List<String> chatBoardIds;
  final String fcmToken;

  UserModel({

    required this.uid,
    required this.name,
    required this.phoneNumber,
    required this.profileImage,
    required this.chatBoardIds,
    required this.fcmToken,
    
  });

  Map<String, dynamic> toMap() {

    return {

      'uid': uid,
      'name': name,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'chatBoardIds' : chatBoardIds,
      'fcmToken' : fcmToken,
      
    };
  }

  factory UserModel.fromMap(
    Map<String, dynamic> map,
  ) {

    return UserModel(

      uid: map['uid'],

      name: map['name'],

      phoneNumber: map['phoneNumber'],

      profileImage: map['profileImage'],

      chatBoardIds : map['chatBoardIds'],

      fcmToken: map['fcmToken'] ?? '',

    );
  }
}



class DiscoverUserModel {
  final String name;
  final String phoneNumber;

  final String? uid;
  final String? profileImage;

  final bool isRegistered;

  DiscoverUserModel({
    required this.name,
    required this.phoneNumber,
    required this.isRegistered,
    this.uid,
    this.profileImage,
  });

  factory DiscoverUserModel.fromFirestore({
    required String uid,
    required Map<String, dynamic> data,
  }) {
    return DiscoverUserModel(
      uid: uid,
      name: data['name'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      profileImage: data['profileImage'] ?? '',
      isRegistered: true,
    );
  }

  factory DiscoverUserModel.unregistered({
    required String name,
    required String phoneNumber,
  }) {
    return DiscoverUserModel(
      name: name,
      phoneNumber: phoneNumber,
      isRegistered: false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'isRegistered': isRegistered,
    };
  }
}
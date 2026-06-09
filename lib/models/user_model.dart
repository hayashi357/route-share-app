class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? bio;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool emailVerified;
  final List<String> followingIds;
  final int followerCount;
  final int routeCount;
  final int photoCount;
  final bool isPrivate;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.bio,
    required this.createdAt,
    this.updatedAt,
    required this.emailVerified,
    this.followingIds = const [],
    this.followerCount = 0,
    this.routeCount = 0,
    this.photoCount = 0,
    this.isPrivate = false,
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? emailVerified,
    List<String>? followingIds,
    int? followerCount,
    int? routeCount,
    int? photoCount,
    bool? isPrivate,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      emailVerified: emailVerified ?? this.emailVerified,
      followingIds: followingIds ?? this.followingIds,
      followerCount: followerCount ?? this.followerCount,
      routeCount: routeCount ?? this.routeCount,
      photoCount: photoCount ?? this.photoCount,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'emailVerified': emailVerified,
      'followingIds': followingIds,
      'followerCount': followerCount,
      'routeCount': routeCount,
      'photoCount': photoCount,
      'isPrivate': isPrivate,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'],
      bio: map['bio'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
      emailVerified: map['emailVerified'] ?? false,
      followingIds: List<String>.from(map['followingIds'] ?? []),
      followerCount: map['followerCount'] ?? 0,
      routeCount: map['routeCount'] ?? 0,
      photoCount: map['photoCount'] ?? 0,
      isPrivate: map['isPrivate'] ?? false,
    );
  }
}

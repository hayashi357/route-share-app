class PhotoPost {
  final String id;
  final String uid;
  final String? routeId;
  final String imageUrl;
  final String? caption;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final bool isPublic;
  final List<String> likesByUids;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PhotoPost({
    required this.id,
    required this.uid,
    this.routeId,
    required this.imageUrl,
    this.caption,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.isPublic = true,
    this.likesByUids = const [],
    required this.createdAt,
    this.updatedAt,
  });

  int get likeCount => likesByUids.length;

  PhotoPost copyWith({
    String? id,
    String? uid,
    String? routeId,
    String? imageUrl,
    String? caption,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    bool? isPublic,
    List<String>? likesByUids,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PhotoPost(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      routeId: routeId ?? this.routeId,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      isPublic: isPublic ?? this.isPublic,
      likesByUids: likesByUids ?? this.likesByUids,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'routeId': routeId,
      'imageUrl': imageUrl,
      'caption': caption,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isPublic': isPublic,
      'likesByUids': likesByUids,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory PhotoPost.fromMap(Map<String, dynamic> map, String id) {
    return PhotoPost(
      id: id,
      uid: map['uid'] ?? '',
      routeId: map['routeId'],
      imageUrl: map['imageUrl'] ?? '',
      caption: map['caption'],
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      isPublic: map['isPublic'] ?? true,
      likesByUids: List<String>.from(map['likesByUids'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
    );
  }
}

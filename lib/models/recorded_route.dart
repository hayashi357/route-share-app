import 'location_point.dart';

class RecordedRoute {
  final String id;
  final String uid;
  final String title;
  final String? description;
  final List<LocationPoint> points;
  final List<String> photoIds;
  final DateTime startTime;
  final DateTime? endTime;
  final double totalDistance;
  final double averageSpeed;
  final bool isPublic;
  final String? shareToken;
  final DateTime createdAt;
  final DateTime? updatedAt;

  RecordedRoute({
    required this.id,
    required this.uid,
    required this.title,
    this.description,
    required this.points,
    required this.photoIds,
    required this.startTime,
    this.endTime,
    required this.totalDistance,
    required this.averageSpeed,
    this.isPublic = false,
    this.shareToken,
    required this.createdAt,
    this.updatedAt,
  });

  Duration get duration => endTime != null
      ? endTime!.difference(startTime)
      : Duration.zero;

  double get durationInHours => duration.inSeconds / 3600;

  bool get isRecording => endTime == null;

  RecordedRoute copyWith({
    String? id,
    String? uid,
    String? title,
    String? description,
    List<LocationPoint>? points,
    List<String>? photoIds,
    DateTime? startTime,
    DateTime? endTime,
    double? totalDistance,
    double? averageSpeed,
    bool? isPublic,
    String? shareToken,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecordedRoute(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      description: description ?? this.description,
      points: points ?? this.points,
      photoIds: photoIds ?? this.photoIds,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalDistance: totalDistance ?? this.totalDistance,
      averageSpeed: averageSpeed ?? this.averageSpeed,
      isPublic: isPublic ?? this.isPublic,
      shareToken: shareToken ?? this.shareToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'title': title,
      'description': description,
      'points': points.map((p) => p.toMap()).toList(),
      'photoIds': photoIds,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime?.millisecondsSinceEpoch,
      'totalDistance': totalDistance,
      'averageSpeed': averageSpeed,
      'isPublic': isPublic,
      'shareToken': shareToken,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory RecordedRoute.fromMap(Map<String, dynamic> map, String id) {
    return RecordedRoute(
      id: id,
      uid: map['uid'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      points: (map['points'] as List<dynamic>?)
              ?.map((p) => LocationPoint.fromMap(p))
              .toList() ??
          [],
      photoIds: List<String>.from(map['photoIds'] ?? []),
      startTime: DateTime.fromMillisecondsSinceEpoch(
        map['startTime'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      endTime: map['endTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['endTime'])
          : null,
      totalDistance: (map['totalDistance'] ?? 0).toDouble(),
      averageSpeed: (map['averageSpeed'] ?? 0).toDouble(),
      isPublic: map['isPublic'] ?? false,
      shareToken: map['shareToken'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
    );
  }
}

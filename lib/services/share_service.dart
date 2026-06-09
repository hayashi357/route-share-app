import 'package:firebase_database/firebase_database.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import '../models/recorded_route.dart';
import '../utils/app_exceptions.dart';

class ShareService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  static const uuid = Uuid();
  static const String baseUrl = 'https://routeshare.app';

  Future<void> shareRoute(RecordedRoute route) async {
    try {
      final token = uuid.v4();
      final sharedRoute = route.copyWith(
        isPublic: true,
        shareToken: token,
      );

      await _database.ref('shared_routes/$token').set(sharedRoute.toMap());
    } catch (e) {
      throw AppException('ルート共有に失敗しました: $e');
    }
  }

  String getShareLink(String token) {
    return '$baseUrl/routes/shared/$token';
  }

  Future<RecordedRoute?> loadSharedRoute(String token) async {
    try {
      final snapshot = await _database.ref('shared_routes/$token').get();
      if (!snapshot.exists) return null;
      return RecordedRoute.fromMap(snapshot.value as Map<String, dynamic>, token);
    } catch (e) {
      throw AppException('共有ルートの読込に失敗しました: $e');
    }
  }

  Future<void> shareViaSystem(RecordedRoute route) async {
    try {
      if (route.shareToken == null) {
        await shareRoute(route);
      }

      final link = getShareLink(route.shareToken!);
      final message =
          'このルートをチェック！\n${route.title}\n距離: ${(route.totalDistance / 1000).toStringAsFixed(2)} km\n時間: ${route.duration.inMinutes} 分\n$link';

      await Share.share(message);
    } catch (e) {
      throw AppException('ルート共有に失敗しました: $e');
    }
  }
}

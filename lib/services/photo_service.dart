import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import '../models/photo_post.dart';
import '../utils/app_exceptions.dart';

class PhotoService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  static const uuid = Uuid();

  Future<void> savePhoto(PhotoPost photo) async {
    try {
      await _database.ref('photos/${photo.id}').set(photo.toMap());
    } catch (e) {
      throw PhotoException('写真の保存に失敗しました: $e');
    }
  }

  Future<PhotoPost?> getPhoto(String photoId) async {
    try {
      final snapshot = await _database.ref('photos/$photoId').get();
      if (!snapshot.exists) return null;
      return PhotoPost.fromMap(snapshot.value as Map<String, dynamic>, photoId);
    } catch (e) {
      throw PhotoException('写真の取得に失敗しました: $e');
    }
  }

  Future<List<PhotoPost>> getUserPhotos(String uid, {int limit = 50}) async {
    try {
      final snapshot = await _database
          .ref('photos')
          .orderByChild('uid')
          .equalTo(uid)
          .limitToLast(limit)
          .get();

      if (!snapshot.exists) return [];

      final photos = <PhotoPost>[];
      for (final entry in (snapshot.value as Map).entries) {
        photos.add(PhotoPost.fromMap(entry.value as Map<String, dynamic>, entry.key));
      }
      return photos.reversed.toList();
    } catch (e) {
      throw PhotoException('写真一覧の取得に失敗しました: $e');
    }
  }

  Future<List<PhotoPost>> getRoutePhotos(String routeId, {int limit = 50}) async {
    try {
      final snapshot = await _database
          .ref('photos')
          .orderByChild('routeId')
          .equalTo(routeId)
          .limitToLast(limit)
          .get();

      if (!snapshot.exists) return [];

      final photos = <PhotoPost>[];
      for (final entry in (snapshot.value as Map).entries) {
        photos.add(PhotoPost.fromMap(entry.value as Map<String, dynamic>, entry.key));
      }
      return photos.reversed.toList();
    } catch (e) {
      throw PhotoException('ルートの写真取得に失敗しました: $e');
    }
  }

  Future<void> deletePhoto(String photoId) async {
    try {
      await _database.ref('photos/$photoId').remove();
    } catch (e) {
      throw PhotoException('写真の削除に失敗しました: $e');
    }
  }

  Future<void> likePhoto(String photoId, String uid) async {
    try {
      final photo = await getPhoto(photoId);
      if (photo != null && !photo.likesByUids.contains(uid)) {
        final updatedLikes = [...photo.likesByUids, uid];
        await _database.ref('photos/$photoId').update({
          'likesByUids': updatedLikes,
        });
      }
    } catch (e) {
      throw PhotoException('いいねに失敗しました: $e');
    }
  }

  Future<void> unlikePhoto(String photoId, String uid) async {
    try {
      final photo = await getPhoto(photoId);
      if (photo != null) {
        final updatedLikes = photo.likesByUids.where((id) => id != uid).toList();
        await _database.ref('photos/$photoId').update({
          'likesByUids': updatedLikes,
        });
      }
    } catch (e) {
      throw PhotoException('いいねの取り消しに失敗しました: $e');
    }
  }

  String generatePhotoId() => uuid.v4();
}

class PhotoException extends AppException {
  PhotoException(String message, {String? code}) : super(message, code: code);
}

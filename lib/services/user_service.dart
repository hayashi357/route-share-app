import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';
import '../utils/app_exceptions.dart';

class UserService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<UserModel> getUserInfo(String uid) async {
    try {
      final snapshot = await _database.ref('users/$uid').get();

      if (!snapshot.exists) {
        throw UserException('ユーザーが見つかりません');
      }

      return UserModel.fromMap(
        snapshot.value as Map<String, dynamic>,
        uid,
      );
    } catch (e) {
      throw UserException('ユーザー情報の取得に失敗しました: $e');
    }
  }

  Future<void> updateUserInfo(UserModel user) async {
    try {
      await _database
          .ref('users/${user.uid}')
          .set(user.copyWith(updatedAt: DateTime.now()).toMap());
    } catch (e) {
      throw UserException('ユーザー情報の更新に失敗しました: $e');
    }
  }

  Future<String> uploadProfileImage(String uid, File image) async {
    try {
      final ref = _storage.ref('user_profiles/$uid/profile.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      throw UserException('画像のアップロードに失敗しました: $e');
    }
  }

  Future<void> followUser(String currentUid, String targetUid) async {
    try {
      final currentUserRef = _database.ref('users/$currentUid');
      final currentUserSnapshot = await currentUserRef.get();
      final currentUser =
          UserModel.fromMap(currentUserSnapshot.value as Map, currentUid);

      if (!currentUser.followingIds.contains(targetUid)) {
        final updatedFollowingIds = [...currentUser.followingIds, targetUid];
        await currentUserRef.update({
          'followingIds': updatedFollowingIds,
        });
      }

      final targetUserRef = _database.ref('users/$targetUid');
      final targetUserSnapshot = await targetUserRef.get();
      final targetUser =
          UserModel.fromMap(targetUserSnapshot.value as Map, targetUid);

      await targetUserRef.update({
        'followerCount': targetUser.followerCount + 1,
      });
    } catch (e) {
      throw UserException('フォローに失敗しました: $e');
    }
  }

  Future<void> unfollowUser(String currentUid, String targetUid) async {
    try {
      final currentUserRef = _database.ref('users/$currentUid');
      final currentUserSnapshot = await currentUserRef.get();
      final currentUser =
          UserModel.fromMap(currentUserSnapshot.value as Map, currentUid);

      final updatedFollowingIds =
          currentUser.followingIds.where((id) => id != targetUid).toList();

      await currentUserRef.update({
        'followingIds': updatedFollowingIds,
      });

      final targetUserRef = _database.ref('users/$targetUid');
      final targetUserSnapshot = await targetUserRef.get();
      final targetUser =
          UserModel.fromMap(targetUserSnapshot.value as Map, targetUid);

      await targetUserRef.update({
        'followerCount': (targetUser.followerCount - 1).clamp(0, double.infinity).toInt(),
      });
    } catch (e) {
      throw UserException('アンフォローに失敗しました: $e');
    }
  }

  Future<List<UserModel>> searchUsers(String query, {int limit = 20}) async {
    try {
      final snapshot = await _database.ref('users').get();

      if (!snapshot.exists) return [];

      final users = <UserModel>[];
      for (final entry in (snapshot.value as Map).entries) {
        final user = UserModel.fromMap(entry.value as Map, entry.key);
        if (user.displayName.toLowerCase().contains(query.toLowerCase())) {
          users.add(user);
          if (users.length >= limit) break;
        }
      }
      return users;
    } catch (e) {
      throw UserException('ユーザー検索に失敗しました: $e');
    }
  }
}

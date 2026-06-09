import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../utils/app_exceptions.dart';

class ImageService {
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<File?> pickImageFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      return pickedFile != null ? File(pickedFile.path) : null;
    } catch (e) {
      throw PhotoException('ギャラリーから画像の選択に失敗しました: $e');
    }
  }

  Future<File?> takePhoto() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      return pickedFile != null ? File(pickedFile.path) : null;
    } catch (e) {
      throw PhotoException('写真の撮影に失敗しました: $e');
    }
  }

  Future<String> uploadPhoto(String uid, String photoId, File imageFile) async {
    try {
      final ref = _storage.ref('photos/$uid/$photoId.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      throw PhotoException('写真のアップロードに失敗しました: $e');
    }
  }

  Future<void> deletePhoto(String uid, String photoId) async {
    try {
      final ref = _storage.ref('photos/$uid/$photoId.jpg');
      await ref.delete();
    } catch (e) {
      throw PhotoException('写真の削除に失敗しました: $e');
    }
  }
}

class PhotoException extends AppException {
  PhotoException(String message, {String? code}) : super(message, code: code);
}

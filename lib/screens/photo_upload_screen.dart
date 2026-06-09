import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/photo_post.dart';
import '../providers/auth_provider.dart';
import '../providers/location_provider.dart';
import '../providers/photo_provider.dart';
import '../services/image_service.dart';

class PhotoUploadScreen extends ConsumerStatefulWidget {
  final String? routeId;

  const PhotoUploadScreen({this.routeId});

  @override
  ConsumerState<PhotoUploadScreen> createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends ConsumerState<PhotoUploadScreen> {
  File? _selectedImage;
  final _captionController = TextEditingController();
  bool _isPublic = true;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final currentLocation = ref.watch(currentLocationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('写真投稿')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Image preview
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _selectedImage != null
                  ? Image.file(_selectedImage!, fit: BoxFit.cover)
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.image, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('画像を選択してください'),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('ギャラリーから選択'),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _takePhoto,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('写真を撮影'),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 24),
            // Caption
            TextField(
              controller: _captionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'キャプション',
                hintText: '写真の説明を入力してください',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Public toggle
            CheckboxListTile(
              value: _isPublic,
              onChanged: (value) {
                setState(() => _isPublic = value ?? true);
              },
              title: const Text('公開する'),
              subtitle: const Text('他のユーザーが見ることができます'),
            ),
            const SizedBox(height: 24),
            // Upload button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedImage == null || _isUploading ? null : _uploadPhoto,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('投稿'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final imageService = ref.read(imageServiceProvider);
      final image = await imageService.pickImageFromGallery();
      if (image != null) {
        setState(() => _selectedImage = image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: $e')),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final imageService = ref.read(imageServiceProvider);
      final image = await imageService.takePhoto();
      if (image != null) {
        setState(() => _selectedImage = image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: $e')),
        );
      }
    }
  }

  Future<void> _uploadPhoto() async {
    if (_selectedImage == null) return;

    setState(() => _isUploading = true);

    try {
      final currentUser = await ref.read(currentUserProvider.future);
      final currentLocation = await ref.read(currentLocationProvider.future);
      final imageService = ref.read(imageServiceProvider);
      final photoService = ref.read(photoServiceProvider);

      if (currentUser == null || currentLocation == null) {
        throw Exception('ユーザーまたは位置情報が取得できません');
      }

      final photoId = const Uuid().v4();

      // Upload image
      final imageUrl = await imageService.uploadPhoto(
        currentUser.uid,
        photoId,
        _selectedImage!,
      );

      // Create and save photo post
      final photo = PhotoPost(
        id: photoId,
        uid: currentUser.uid,
        routeId: widget.routeId,
        imageUrl: imageUrl,
        caption: _captionController.text.isNotEmpty ? _captionController.text : null,
        latitude: currentLocation.latitude!,
        longitude: currentLocation.longitude!,
        timestamp: DateTime.now(),
        isPublic: _isPublic,
        createdAt: DateTime.now(),
      );

      await photoService.savePhoto(photo);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('投稿完了しました')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('投稿に失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }
}

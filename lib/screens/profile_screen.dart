import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../services/user_service.dart';
import '../services/image_service.dart';
import 'package:uuid/uuid.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String? userId;

  const ProfileScreen({this.userId});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  File? _selectedImage;
  bool _isEditing = false;
  bool _isUpdating = false;
  late TextEditingController _displayNameController;
  late TextEditingController _bioController;
  bool _isPrivate = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final userId = widget.userId ?? currentUser.value?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('プロフィール')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール'),
        actions: [
          if (widget.userId == null || currentUser.value?.uid == widget.userId)
            IconButton(
              icon: Icon(_isEditing ? Icons.check : Icons.edit),
              onPressed: () {
                if (_isEditing) {
                  _saveProfile();
                } else {
                  setState(() => _isEditing = true);
                }
              },
            ),
        ],
      ),
      body: currentUser.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('ユーザー情報が取得できません'));
          }

          if (_displayNameController.text.isEmpty) {
            _displayNameController.text = user.displayName;
            _bioController.text = user.bio ?? '';
            _isPrivate = user.isPrivate;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile image
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!) as ImageProvider
                          : user.photoUrl != null
                              ? NetworkImage(user.photoUrl!)
                              : null,
                      child: _selectedImage == null && user.photoUrl == null
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                    if (_isEditing && (widget.userId == null || currentUser.value?.uid == widget.userId))
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          radius: 20,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                            onPressed: _pickProfileImage,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                // Display name
                if (_isEditing && (widget.userId == null || currentUser.value?.uid == widget.userId))
                  TextField(
                    controller: _displayNameController,
                    decoration: InputDecoration(
                      labelText: '表示名',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )
                else
                  Text(
                    user.displayName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                const SizedBox(height: 8),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                const SizedBox(height: 24),
                // Bio
                if (_isEditing && (widget.userId == null || currentUser.value?.uid == widget.userId))
                  TextField(
                    controller: _bioController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: '自己紹介',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )
                else if (user.bio != null && user.bio!.isNotEmpty)
                  Text(
                    user.bio!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 24),
                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('ルート', user.routeCount.toString()),
                    _buildStatCard('写真', user.photoCount.toString()),
                    _buildStatCard('フォロワー', user.followerCount.toString()),
                  ],
                ),
                const SizedBox(height: 24),
                // Private toggle
                if (_isEditing && (widget.userId == null || currentUser.value?.uid == widget.userId))
                  CheckboxListTile(
                    value: _isPrivate,
                    onChanged: (value) {
                      setState(() => _isPrivate = value ?? false);
                    },
                    title: const Text('プロフィールを非公開にする'),
                    subtitle: const Text('フォロワーのみプロフィールを見ることができます'),
                  ),
                const SizedBox(height: 24),
                // Follow/Unfollow button
                if (widget.userId != null && currentUser.value?.uid != widget.userId)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement follow/unfollow
                      },
                      child: const Text('フォローする'),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('エラー: $error')),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }

  Future<void> _pickProfileImage() async {
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

  Future<void> _saveProfile() async {
    setState(() => _isUpdating = true);

    try {
      final currentUser = await ref.read(currentUserProvider.future);
      if (currentUser == null) throw Exception('ユーザーが見つかりません');

      final userService = ref.read(userServiceProvider);
      String? photoUrl = currentUser.photoUrl;

      // Upload profile image if selected
      if (_selectedImage != null) {
        final imageService = ref.read(imageServiceProvider);
        photoUrl = await imageService.uploadProfileImage(
          currentUser.uid,
          _selectedImage!,
        );
      }

      // Update user info
      final updatedUser = currentUser.copyWith(
        displayName: _displayNameController.text,
        bio: _bioController.text.isNotEmpty ? _bioController.text : null,
        photoUrl: photoUrl,
        isPrivate: _isPrivate,
        updatedAt: DateTime.now(),
      );

      await userService.updateUserInfo(updatedUser);

      if (mounted) {
        setState(() {
          _isEditing = false;
          _selectedImage = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('プロフィールを更新しました')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新に失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}

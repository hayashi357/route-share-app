import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('RouteShare'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authService = ref.read(authServiceProvider);
              await authService.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: currentUser.when(
          data: (user) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (user?.photoUrl != null)
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(user!.photoUrl!),
                )
              else
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
              const SizedBox(height: 16),
              Text(
                'ようこそ、${user?.displayName}さん',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                user?.email ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              const Text('このアプリは現在開発中です。'),
              const SizedBox(height: 16),
              const Text('以下の機能が実装予定です：'),
              const SizedBox(height: 8),
              const Column(
                children: [
                  Text('📍 地図表示'),
                  Text('📷 写真投稿'),
                  Text('🚴 ルート記録'),
                  Text('🔗 ルート共有'),
                ],
              ),
            ],
          ),
          loading: () => const CircularProgressIndicator(),
          error: (err, stack) => Text('エラー: $err'),
        ),
      ),
    );
  }
}

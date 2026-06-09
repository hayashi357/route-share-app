import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/recorded_route.dart';
import '../providers/auth_provider.dart';
import '../providers/route_provider.dart';
import '../utils/route_calculator.dart';
import 'map_screen.dart';

class RouteHistoryScreen extends ConsumerWidget {
  const RouteHistoryScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ルート履歴')),
      body: currentUser.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('ユーザー情報が取得できません'));
          }

          final routes = ref.watch(userRoutesProvider(user.uid));

          return routes.when(
            data: (routeList) {
              if (routeList.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('ルート履歴がありません'),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: routeList.length,
                itemBuilder: (context, index) {
                  final route = routeList[index];
                  return _buildRouteCard(context, route);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('エラー: $error')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('エラー: $error')),
      ),
    );
  }

  Widget _buildRouteCard(BuildContext context, RecordedRoute route) {
    final distance = RouteCalculator.formatDistance(route.totalDistance);
    final speed = RouteCalculator.formatSpeed(route.averageSpeed);
    final duration = _formatDuration(route.duration);
    final date = _formatDate(route.createdAt);

    return Card(
      margin: const EdgeInsets.all(12),
      child: ListTile(
        leading: const Icon(Icons.route),
        title: Text(route.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('距離: $distance | 時間: $duration'),
            Text('平均速度: $speed'),
            Text(
              date,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.info),
          onPressed: () => _showRouteDetails(context, route),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MapScreen(route: route),
            ),
          );
        },
      ),
    );
  }

  void _showRouteDetails(BuildContext context, RecordedRoute route) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              route.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            if (route.description != null) ...
              [
                Text(
                  'セクション:
${route.description}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
              ],
            _buildDetailRow('距離', RouteCalculator.formatDistance(route.totalDistance)),
            _buildDetailRow('時間', _formatDuration(route.duration)),
            _buildDetailRow('平均速度', RouteCalculator.formatSpeed(route.averageSpeed)),
            _buildDetailRow('ポイント数', '${route.points.length}'),
            _buildDetailRow('写真', '${route.photoIds.length}'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('閉じる'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日 ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/recorded_route.dart';
import '../models/photo_post.dart';
import '../providers/photo_provider.dart';
import '../providers/route_provider.dart';
import '../utils/route_calculator.dart';
import 'map_screen.dart';

class RouteDetailScreen extends ConsumerWidget {
  final RecordedRoute route;

  const RouteDetailScreen({required this.route});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(routePhotosProvider(route.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(route.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // TODO: Implement delete
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Map preview
            SizedBox(
              height: 300,
              child: MapScreen(route: route),
            ),
            // Route stats
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (route.description != null) ...
                    [
                      const SizedBox(height: 8),
                      Text(
                        route.description!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatTile(
                        '距離',
                        RouteCalculator.formatDistance(route.totalDistance),
                      ),
                      _buildStatTile(
                        '時間',
                        _formatDuration(route.duration),
                      ),
                      _buildStatTile(
                        '速度',
                        RouteCalculator.formatSpeed(route.averageSpeed),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Photos section
                  Text(
                    '写真',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  photos.when(
                    data: (photoList) {
                      if (photoList.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('写真がありません'),
                          ),
                        );
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: photoList.length,
                        itemBuilder: (context, index) {
                          final photo = photoList[index];
                          return GestureDetector(
                            onTap: () {
                              // TODO: Show photo detail
                            },
                            child: Card(
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    photo.imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      color: Colors.black.withOpacity(0.5),
                                      padding: const EdgeInsets.all(8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              photo.caption ?? '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(color: Colors.white),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.favorite,
                                                color: Colors.red,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                photo.likeCount.toString(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(child: Text('エラー: $error')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
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
}

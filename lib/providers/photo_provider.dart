import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/photo_post.dart';
import '../services/image_service.dart';
import '../services/photo_service.dart';

final imageServiceProvider = Provider((ref) => ImageService());
final photoServiceProvider = Provider((ref) => PhotoService());

final userPhotosProvider = FutureProvider.family<List<PhotoPost>, String>((ref, uid) async {
  final service = ref.watch(photoServiceProvider);
  return await service.getUserPhotos(uid);
});

final routePhotosProvider = FutureProvider.family<List<PhotoPost>, String>((ref, routeId) async {
  final service = ref.watch(photoServiceProvider);
  return await service.getRoutePhotos(routeId);
});

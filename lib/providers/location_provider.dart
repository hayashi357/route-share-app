import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/location_point.dart';
import '../services/location_service.dart';

final locationServiceProvider = Provider((ref) => LocationService());

final currentLocationProvider = FutureProvider((ref) async {
  final service = ref.watch(locationServiceProvider);
  return await service.getCurrentLocation();
});

final locationStreamProvider = StreamProvider((ref) {
  final service = ref.watch(locationServiceProvider);
  return service.getLocationStream();
});

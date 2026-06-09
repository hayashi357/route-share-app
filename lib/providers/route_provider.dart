import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/recorded_route.dart';
import '../services/route_service.dart';

final routeServiceProvider = Provider((ref) => RouteService());

final userRoutesProvider = FutureProvider.family<List<RecordedRoute>, String>((ref, uid) async {
  final service = ref.watch(routeServiceProvider);
  return await service.getUserRoutes(uid);
});

final recordingRouteStateProvider = StateNotifierProvider<RecordingRouteNotifier, RecordedRoute?>(
  (ref) => RecordingRouteNotifier(),
);

class RecordingRouteNotifier extends StateNotifier<RecordedRoute?> {
  RecordingRouteNotifier() : super(null);

  void setRoute(RecordedRoute? route) {
    state = route;
  }
}

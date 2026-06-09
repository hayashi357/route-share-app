import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import '../models/location_point.dart';
import '../models/recorded_route.dart';
import '../utils/app_exceptions.dart';
import '../utils/route_calculator.dart';

class RouteService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  static const uuid = Uuid();

  Future<void> saveRoute(RecordedRoute route) async {
    try {
      await _database.ref('routes/${route.id}').set(route.toMap());
    } catch (e) {
      throw RouteException('ルートの保存に失敗しました: $e');
    }
  }

  Future<RecordedRoute?> getRoute(String routeId) async {
    try {
      final snapshot = await _database.ref('routes/$routeId').get();
      if (!snapshot.exists) return null;
      return RecordedRoute.fromMap(snapshot.value as Map, routeId);
    } catch (e) {
      throw RouteException('ルートの取得に失敗しました: $e');
    }
  }

  Future<List<RecordedRoute>> getUserRoutes(String uid, {int limit = 50}) async {
    try {
      final snapshot = await _database
          .ref('routes')
          .orderByChild('uid')
          .equalTo(uid)
          .limitToLast(limit)
          .get();

      if (!snapshot.exists) return [];

      final routes = <RecordedRoute>[];
      for (final entry in (snapshot.value as Map).entries) {
        routes.add(RecordedRoute.fromMap(entry.value as Map, entry.key));
      }
      return routes.reversed.toList();
    } catch (e) {
      throw RouteException('ルート一覧の取得に失敗しました: $e');
    }
  }

  Future<void> deleteRoute(String routeId) async {
    try {
      await _database.ref('routes/$routeId').remove();
    } catch (e) {
      throw RouteException('ルートの削除に失敗しました: $e');
    }
  }

  Future<void> updateRoutePublicStatus(String routeId, bool isPublic) async {
    try {
      await _database.ref('routes/$routeId').update({
        'isPublic': isPublic,
      });
    } catch (e) {
      throw RouteException('ルートの公開状態の更新に失敗しました: $e');
    }
  }

  RecordedRoute createNewRoute({
    required String uid,
    required String title,
    String? description,
  }) {
    final now = DateTime.now();
    return RecordedRoute(
      id: uuid.v4(),
      uid: uid,
      title: title,
      description: description,
      points: [],
      photoIds: [],
      startTime: now,
      totalDistance: 0,
      averageSpeed: 0,
      createdAt: now,
    );
  }

  RecordedRoute updateRouteWithPoints(
    RecordedRoute route,
    List<LocationPoint> points,
  ) {
    final totalDistance = RouteCalculator.getTotalDistance(points);
    final averageSpeed = RouteCalculator.getAverageSpeed(points);

    return route.copyWith(
      points: points,
      totalDistance: totalDistance,
      averageSpeed: averageSpeed,
    );
  }

  RecordedRoute finishRoute(RecordedRoute route) {
    return route.copyWith(
      endTime: DateTime.now(),
    );
  }
}

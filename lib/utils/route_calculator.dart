import 'dart:math';
import '../models/location_point.dart';

class RouteCalculator {
  static const double earthRadiusMeters = 6371000;

  /// Calculate distance between two points using Haversine formula
  static double calculateDistance(LocationPoint p1, LocationPoint p2) {
    final lat1 = p1.latitude * pi / 180;
    final lat2 = p2.latitude * pi / 180;
    final dLat = (p2.latitude - p1.latitude) * pi / 180;
    final dLng = (p2.longitude - p1.longitude) * pi / 180;

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  /// Calculate total distance of route
  static double getTotalDistance(List<LocationPoint> points) {
    if (points.length < 2) return 0;

    double total = 0;
    for (int i = 0; i < points.length - 1; i++) {
      total += calculateDistance(points[i], points[i + 1]);
    }
    return total;
  }

  /// Calculate average speed in m/s
  static double getAverageSpeed(List<LocationPoint> points) {
    if (points.length < 2) return 0;

    final distance = getTotalDistance(points);
    final duration = points.last.timestamp.difference(points.first.timestamp);

    if (duration.inSeconds <= 0) return 0;
    return distance / duration.inSeconds;
  }

  /// Calculate average speed in km/h
  static double getAverageSpeedKmh(List<LocationPoint> points) {
    return getAverageSpeed(points) * 3.6;
  }

  /// Get route bounds
  static Map<String, double> getRouteBounds(List<LocationPoint> points) {
    if (points.isEmpty) {
      return {'minLat': 0, 'maxLat': 0, 'minLng': 0, 'maxLng': 0};
    }

    double minLat = points[0].latitude;
    double maxLat = points[0].latitude;
    double minLng = points[0].longitude;
    double maxLng = points[0].longitude;

    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return {'minLat': minLat, 'maxLat': maxLat, 'minLng': minLng, 'maxLng': maxLng};
  }

  /// Format distance for display
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)}m';
    } else {
      final km = meters / 1000;
      return '${km.toStringAsFixed(2)}km';
    }
  }

  /// Format speed for display
  static String formatSpeed(double msPerSecond) {
    final kmh = msPerSecond * 3.6;
    return '${kmh.toStringAsFixed(1)}km/h';
  }
}

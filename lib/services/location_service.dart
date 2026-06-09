import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/location_point.dart';
import '../utils/app_exceptions.dart';

class LocationService {
  final Location _location = Location();

  Future<bool> requestLocationPermission() async {
    try {
      final status = await Permission.location.request();
      return status.isGranted;
    } catch (e) {
      throw AppException('位置情報許可のリクエストに失敗しました: $e');
    }
  }

  Future<bool> isLocationServiceEnabled() async {
    try {
      return await _location.serviceEnabled();
    } catch (e) {
      throw AppException('位置情報サービスの確認に失敗しました: $e');
    }
  }

  Future<LocationData?> getCurrentLocation() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        throw AppException('位置情報の許可が得られていません');
      }

      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw AppException('位置情報サービスが無効です');
      }

      return await _location.getLocation();
    } catch (e) {
      throw AppException('現在地の取得に失敗しました: $e');
    }
  }

  Stream<LocationData> getLocationStream() {
    return _location.onLocationChanged;
  }

  LocationPoint locationDataToPoint(LocationData data) {
    return LocationPoint(
      latitude: data.latitude ?? 0.0,
      longitude: data.longitude ?? 0.0,
      accuracy: data.accuracy,
      altitude: data.altitude,
      speed: data.speed,
      timestamp: DateTime.now(),
    );
  }
}

typedef LocationData = ({double? latitude, double? longitude, double? accuracy, double? altitude, double? speed, double? heading, double? time});

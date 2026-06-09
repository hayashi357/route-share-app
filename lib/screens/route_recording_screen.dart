import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:location/location.dart';
import '../models/location_point.dart';
import '../models/recorded_route.dart';
import '../providers/auth_provider.dart';
import '../providers/location_provider.dart';
import '../providers/route_provider.dart';
import '../services/location_service.dart';
import '../services/route_service.dart';
import '../utils/route_calculator.dart';

class RouteRecordingScreen extends ConsumerStatefulWidget {
  const RouteRecordingScreen();

  @override
  ConsumerState<RouteRecordingScreen> createState() => _RouteRecordingScreenState();
}

class _RouteRecordingScreenState extends ConsumerState<RouteRecordingScreen> {
  GoogleMapController? _mapController;
  RecordedRoute? _currentRoute;
  List<LocationPoint> _routePoints = [];
  bool _isRecording = false;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeRoute();
  }

  void _initializeRoute() async {
    final currentUser = await ref.read(currentUserProvider.future);
    if (currentUser == null) return;

    final routeService = ref.read(routeServiceProvider);
    final newRoute = routeService.createNewRoute(
      uid: currentUser.uid,
      title: 'New Route',
    );

    setState(() => _currentRoute = newRoute);
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation = ref.watch(currentLocationProvider);
    final locationStream = ref.watch(locationStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ルート記録'),
        actions: [
          if (_isRecording)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  _routePoints.length.toString(),
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: currentLocation.when(
        data: (location) {
          if (location == null || _currentRoute == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final initialCameraPosition = CameraPosition(
            target: LatLng(location.latitude!, location.longitude!),
            zoom: 15,
          );

          return Stack(
            children: [
              GoogleMap(
                onMapCreated: (controller) => _mapController = controller,
                initialCameraPosition: initialCameraPosition,
                polylines: _buildPolylines(),
                markers: _buildMarkers(),
                myLocationEnabled: true,
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ルート統計',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '距離: ${RouteCalculator.formatDistance(RouteCalculator.getTotalDistance(_routePoints))}',
                        ),
                        Text(
                          '時間: ${_getDurationString()}',
                        ),
                        Text(
                          '速度: ${RouteCalculator.formatSpeed(RouteCalculator.getAverageSpeed(_routePoints))}',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  children: [
                    if (!_isRecording) _buildRouteInputForm(),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isRecording ? _stopRecording : _startRecording,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: _isRecording ? Colors.red : Colors.green,
                        ),
                        child: Text(
                          _isRecording ? '記録停止' : '記録開始',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('エラー: $error')),
      ),
    );
  }

  Widget _buildRouteInputForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'ルートタイトル',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: '説明（オプション）',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Set<Polyline> _buildPolylines() {
    if (_routePoints.length < 2) return {};

    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: _routePoints
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList(),
        color: Colors.blue,
        width: 5,
        geodesic: true,
      ),
    };
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    if (_routePoints.isNotEmpty) {
      markers.add(
        Marker(
          markerId: const MarkerId('start'),
          position: LatLng(_routePoints.first.latitude, _routePoints.first.longitude),
          infoWindow: const InfoWindow(title: 'スタート'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );

      if (_routePoints.length > 1) {
        markers.add(
          Marker(
            markerId: const MarkerId('current'),
            position: LatLng(_routePoints.last.latitude, _routePoints.last.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
      }
    }

    return markers;
  }

  Future<void> _startRecording() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ルートタイトルを入力してください')),
      );
      return;
    }

    setState(() => _isRecording = true);
    _routePoints.clear();

    final locationService = ref.read(locationServiceProvider);
    final subscription = locationService.getLocationStream().listen((location) {
      final point = LocationPoint(
        latitude: location.latitude ?? 0.0,
        longitude: location.longitude ?? 0.0,
        accuracy: location.accuracy,
        altitude: location.altitude,
        speed: location.speed,
        timestamp: DateTime.now(),
      );

      setState(() {
        _routePoints.add(point);
      });
    });

    // Store subscription for later cleanup
    if (!mounted) return;
    await Future.delayed(const Duration(hours: 1));
    subscription.cancel();
  }

  Future<void> _stopRecording() async {
    setState(() => _isRecording = false);

    if (_currentRoute == null) return;

    try {
      final routeService = ref.read(routeServiceProvider);
      final title = _titleController.text.isNotEmpty ? _titleController.text : 'Unnamed Route';
      final description = _descriptionController.text.isNotEmpty ? _descriptionController.text : null;

      final finishedRoute = _currentRoute!.copyWith(
        title: title,
        description: description,
        points: _routePoints,
        endTime: DateTime.now(),
        totalDistance: RouteCalculator.getTotalDistance(_routePoints),
        averageSpeed: RouteCalculator.getAverageSpeed(_routePoints),
      );

      await routeService.saveRoute(finishedRoute);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ルートを保存しました')),
        );
        Navigator.pop(context, finishedRoute);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: $e')),
        );
      }
    }
  }

  String _getDurationString() {
    if (_routePoints.length < 2) return '0分';
    final duration = _routePoints.last.timestamp.difference(_routePoints.first.timestamp);
    return '${duration.inMinutes}分';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

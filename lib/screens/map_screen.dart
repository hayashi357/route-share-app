import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/location_provider.dart';
import '../providers/route_provider.dart';
import '../models/recorded_route.dart';

class MapScreen extends ConsumerStatefulWidget {
  final RecordedRoute? route;

  const MapScreen({this.route});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  Widget build(BuildContext context) {
    final currentLocation = ref.watch(currentLocationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('地図'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              // Show route details
            },
          ),
        ],
      ),
      body: currentLocation.when(
        data: (location) {
          if (location == null) {
            return const Center(child: Text('位置情報を取得中...'));
          }

          final initialCameraPosition = CameraPosition(
            target: LatLng(location.latitude!, location.longitude!),
            zoom: 15,
          );

          _updateMarkersAndPolylines();

          return GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: initialCameraPosition,
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            zoomControlsEnabled: true,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('エラー: $error')),
      ),
      floatingActionButton: widget.route != null
          ? FloatingActionButton(
              onPressed: () {
                _centerMapOnRoute();
              },
              child: const Icon(Icons.center_focus_strong),
            )
          : null,
    );
  }

  void _updateMarkersAndPolylines() {
    if (widget.route == null) return;

    final route = widget.route!;

    // Clear existing markers and polylines
    _markers.clear();
    _polylines.clear();

    // Add start and end markers
    if (route.points.isNotEmpty) {
      _markers.add(
        Marker(
          markerId: const MarkerId('start'),
          position: LatLng(route.points.first.latitude, route.points.first.longitude),
          infoWindow: const InfoWindow(title: 'スタート'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );

      if (route.points.length > 1) {
        _markers.add(
          Marker(
            markerId: const MarkerId('end'),
            position: LatLng(route.points.last.latitude, route.points.last.longitude),
            infoWindow: const InfoWindow(title: 'ゴール'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
      }

      // Add route polyline
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: route.points
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList(),
          color: Colors.blue,
          width: 5,
          geodesic: true,
        ),
      );
    }

    setState(() {});
  }

  void _centerMapOnRoute() {
    if (widget.route == null || widget.route!.points.isEmpty) return;

    final route = widget.route!;
    final points = route.points.map((p) => LatLng(p.latitude, p.longitude)).toList();

    if (points.isEmpty) return;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = minLat > point.latitude ? point.latitude : minLat;
      maxLat = maxLat < point.latitude ? point.latitude : maxLat;
      minLng = minLng > point.longitude ? point.longitude : minLng;
      maxLng = maxLng < point.longitude ? point.longitude : maxLng;
    }

    _mapController?.animateCamera(
      CameraUpdateOptions(
        bounds: LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
      ),
    );
  }
}

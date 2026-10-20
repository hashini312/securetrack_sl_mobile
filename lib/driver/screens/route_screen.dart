import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/shipment_model.dart';
import '../services/shipment_service.dart';

class RouteScreen extends StatefulWidget {
  final ShipmentModel? initialShipment;

  const RouteScreen({super.key, this.initialShipment});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  late final MapController _mapController;

  // Default coordinates (Colombo Port -> Orugodawatte Depot)
  static const LatLng _defaultStartPoint = LatLng(6.9400, 79.8500);
  static const LatLng _defaultEndPoint = LatLng(6.9450, 79.8800);

  static const List<LatLng> _defaultRoutePoints = [
    _defaultStartPoint,
    LatLng(6.9380, 79.8650),
    LatLng(6.9420, 79.8720),
    _defaultEndPoint,
  ];

  // Tracking state as per SRS Activity Diagram (Figure 6: vehicle Tracking)
  bool _isTracking = false;
  int _currentPathIndex = 0;
  Timer? _trackingTimer;
  late LatLng _currentVehiclePosition;
  double _currentSpeed = 0.0; // km/h

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentVehiclePosition = _defaultRoutePoints[0];
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    super.dispose();
  }

  List<LatLng> _getRoutePoints(ShipmentModel? shipment) {
    if (shipment == null) {
      return _defaultRoutePoints;
    }

    List<LatLng> points = [shipment.startPoint];
    if (shipment.waypoints.isNotEmpty) {
      points.addAll(shipment.waypoints);
    } else {
      // Default intermediate point if none provided
      points.add(LatLng(
        (shipment.startLatitude + shipment.endLatitude) / 2,
        (shipment.startLongitude + shipment.endLongitude) / 2,
      ));
    }
    points.add(shipment.endPoint);
    return points;
  }

  void _toggleTracking(List<LatLng> routePoints) {
    setState(() {
      _isTracking = !_isTracking;
    });

    if (_isTracking) {
      _currentSpeed = 42.0; // Normal transit speed in corridor
      _trackingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (!mounted) return;
        setState(() {
          _currentPathIndex = (_currentPathIndex + 1) % routePoints.length;
          _currentVehiclePosition = routePoints[_currentPathIndex];
        });

        // Optionally animate map to current vehicle position
        try {
          _mapController.move(_currentVehiclePosition, _mapController.camera.zoom);
        } catch (_) {}
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vehicle GPS tracking started. Within authorized corridor.'),
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      _trackingTimer?.cancel();
      _currentSpeed = 0.0;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vehicle tracking paused.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder<ShipmentModel?>(
      valueListenable: ShipmentService.activeShipmentNotifier,
      builder: (context, activeShipment, _) {
        final currentShipment = widget.initialShipment ?? activeShipment;
        final routePoints = _getRoutePoints(currentShipment);

        final LatLng startPoint = routePoints.first;
        final LatLng endPoint = routePoints.last;

        final LatLng mapCenter = LatLng(
          (startPoint.latitude + endPoint.latitude) / 2,
          (startPoint.longitude + endPoint.longitude) / 2,
        );

        final String originName =
            currentShipment?.origin ?? 'Colombo Port';
        final String destinationName =
            currentShipment?.destination ?? 'Orugodawatte Depot';
        final String distance = currentShipment?.distance ?? '12 km';
        final String estimatedTime =
            currentShipment?.estimatedTime ?? '1h 15m';

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Map Container
              Expanded(
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      // Free Interactive Map (OpenStreetMap)
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: mapCenter,
                          initialZoom: 13.5,
                        ),
                        children: [
                          // Map Layer
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.driver_app',
                          ),

                          // Dynamic Geofence Corridor Buffer (SRS Module 2: Authorized Travel Corridor)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: routePoints,
                                strokeWidth: 26.0,
                                color: const Color(0x330284C7),
                              ),
                            ],
                          ),

                          // Assigned Route Polyline Line
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: routePoints,
                                strokeWidth: 5.0,
                                color: const Color(0xFF0284C7),
                              ),
                            ],
                          ),

                          // Markers: Start Point, End Point, and Live Vehicle Marker
                          MarkerLayer(
                            markers: [
                              // Start Location (Green Pin)
                              Marker(
                                point: startPoint,
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.green,
                                  size: 36,
                                ),
                              ),

                              // End Location (Red Pin)
                              Marker(
                                point: endPoint,
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 36,
                                ),
                              ),

                              // Real-Time Vehicle GPS Marker
                              Marker(
                                point: _currentVehiclePosition,
                                width: 44,
                                height: 44,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E3A8A),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.5,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.local_shipping,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Geofence Compliance Tag
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF0F172A).withValues(alpha: 0.9)
                                : Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.shield, color: Color(0xFF10B981), size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'corridor_compliant'.tr(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Center on Vehicle / Route Button
                      Positioned(
                        top: 12,
                        right: 12,
                        child: FloatingActionButton.small(
                          heroTag: 'recenter_map_btn',
                          backgroundColor:
                              isDark ? const Color(0xFF1E293B) : Colors.white,
                          foregroundColor: const Color(0xFF1E3A8A),
                          elevation: 2,
                          onPressed: () {
                            _mapController.move(
                              _currentVehiclePosition,
                              14.0,
                            );
                          },
                          child: const Icon(Icons.my_location, size: 20),
                        ),
                      ),

                      // Route Name Header Overlay (Exact design preserved)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: isDark
                              ? const Color(0xFF1E293B).withValues(alpha: 0.95)
                              : Colors.white.withValues(alpha: 0.9),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                          child: Text(
                            '$originName  ➔  $destinationName',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Bottom Details Display Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 14.0, horizontal: 16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.route, color: Color(0xFF10B981)),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('distance'.tr(),
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 12)),
                                  Text(distance,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                            child: VerticalDivider(
                                thickness: 1, color: Colors.grey),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.access_time_filled,
                                  color: Colors.blue),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('estimated_time'.tr(),
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 12)),
                                  Text(estimatedTime,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                            child: VerticalDivider(
                                thickness: 1, color: Colors.grey),
                          ),
                          Row(
                            children: [
                              Icon(Icons.speed, color: Colors.orange.shade700),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('speed'.tr(),
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 12)),
                                  Text(
                                    _isTracking
                                        ? '${_currentSpeed.toInt()} km/h'
                                        : '0 km/h',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Start/Pause Tracking Button
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isTracking
                                ? Colors.orange.shade700
                                : const Color(0xFF1E3A8A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => _toggleTracking(routePoints),
                          icon: Icon(
                            _isTracking
                                ? Icons.pause_circle_outline
                                : Icons.play_circle_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                          label: Text(
                            _isTracking
                                ? 'pause_tracking'.tr()
                                : 'start_tracking'.tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
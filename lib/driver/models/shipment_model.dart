import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class ShipmentModel {
  final String id;
  final String shipmentId;
  final String containerId;
  final String? driverId;
  final String driverName;
  final String vehicleNo;
  final String origin;
  final String destination;
  final String status; // 'Active', 'Pending', 'Completed'
  final String assignedRoute;
  final String sealNumber;
  final String iotDeviceId;
  final String type;
  final String weight;
  final String cargoDescription;
  final String eta;
  final String distance;
  final String estimatedTime;
  final double startLatitude;
  final double startLongitude;
  final double endLatitude;
  final double endLongitude;
  final List<LatLng> waypoints;
  final String tamperStatus; // 'Secure', 'Tamper Detected'
  final String geofenceStatus; // 'Inside Corridor', 'Deviated'
  final DateTime? createdAt;

  ShipmentModel({
    required this.id,
    required this.shipmentId,
    required this.containerId,
    this.driverId,
    required this.driverName,
    required this.vehicleNo,
    required this.origin,
    required this.destination,
    required this.status,
    required this.assignedRoute,
    required this.sealNumber,
    required this.iotDeviceId,
    required this.type,
    required this.weight,
    required this.cargoDescription,
    required this.eta,
    required this.distance,
    required this.estimatedTime,
    required this.startLatitude,
    required this.startLongitude,
    required this.endLatitude,
    required this.endLongitude,
    this.waypoints = const [],
    this.tamperStatus = 'Secure',
    this.geofenceStatus = 'Inside Corridor',
    this.createdAt,
  });

  LatLng get startPoint => LatLng(startLatitude, startLongitude);
  LatLng get endPoint => LatLng(endLatitude, endLongitude);

  factory ShipmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};

    List<LatLng> parsedWaypoints = [];
    if (data['waypoints'] != null && data['waypoints'] is List) {
      for (var wp in data['waypoints']) {
        if (wp is Map) {
          final lat = (wp['latitude'] as num?)?.toDouble() ?? 0.0;
          final lng = (wp['longitude'] as num?)?.toDouble() ?? 0.0;
          parsedWaypoints.add(LatLng(lat, lng));
        }
      }
    }

    DateTime? created;
    if (data['createdAt'] is Timestamp) {
      created = (data['createdAt'] as Timestamp).toDate();
    }

    return ShipmentModel(
      id: doc.id,
      shipmentId: data['shipmentId'] ?? doc.id,
      containerId: data['containerId'] ?? 'CONT-001',
      driverId: data['driverId'],
      driverName: data['driverName'] ?? 'Unassigned Driver',
      vehicleNo: data['vehicleNo'] ?? 'N/A',
      origin: data['origin'] ?? 'Colombo Port',
      destination: data['destination'] ?? 'Orugodawatte Depot',
      status: data['status'] ?? 'Active',
      assignedRoute: data['assignedRoute'] ?? 'Colombo Port - Orugodawatte Corridor',
      sealNumber: data['sealNumber'] ?? 'SL-CUS-884912',
      iotDeviceId: data['iotDeviceId'] ?? 'ESP32-ST-0042',
      type: data['type'] ?? 'Standard 40ft',
      weight: data['weight'] ?? '24,500 kg',
      cargoDescription: data['cargoDescription'] ?? 'General Cargo',
      eta: data['eta'] ?? 'Today, 4:30 PM',
      distance: data['distance'] ?? '12 km',
      estimatedTime: data['estimatedTime'] ?? '1h 15m',
      startLatitude: (data['startLatitude'] as num?)?.toDouble() ?? 6.9400,
      startLongitude: (data['startLongitude'] as num?)?.toDouble() ?? 79.8500,
      endLatitude: (data['endLatitude'] as num?)?.toDouble() ?? 6.9450,
      endLongitude: (data['endLongitude'] as num?)?.toDouble() ?? 79.8800,
      waypoints: parsedWaypoints,
      tamperStatus: data['tamperStatus'] ?? 'Secure',
      geofenceStatus: data['geofenceStatus'] ?? 'Inside Corridor',
      createdAt: created,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'shipmentId': shipmentId,
      'containerId': containerId,
      'driverId': driverId,
      'driverName': driverName,
      'vehicleNo': vehicleNo,
      'origin': origin,
      'destination': destination,
      'status': status,
      'assignedRoute': assignedRoute,
      'sealNumber': sealNumber,
      'iotDeviceId': iotDeviceId,
      'type': type,
      'weight': weight,
      'cargoDescription': cargoDescription,
      'eta': eta,
      'distance': distance,
      'estimatedTime': estimatedTime,
      'startLatitude': startLatitude,
      'startLongitude': startLongitude,
      'endLatitude': endLatitude,
      'endLongitude': endLongitude,
      'waypoints': waypoints
          .map((wp) => {'latitude': wp.latitude, 'longitude': wp.longitude})
          .toList(),
      'tamperStatus': tamperStatus,
      'geofenceStatus': geofenceStatus,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toContainerDetailsMap() {
    return {
      'containerId': containerId,
      'status': status == 'Active' ? 'In Transit' : status,
      'origin': origin,
      'destination': destination,
      'weight': weight,
      'sealNumber': sealNumber,
      'type': type,
      'eta': eta,
      'distance': distance,
      'estimatedTime': estimatedTime,
      'assignedRoute': assignedRoute,
      'iotDeviceId': iotDeviceId,
      'cargoDescription': cargoDescription,
      'startPoint': startPoint,
      'endPoint': endPoint,
      'waypoints': waypoints,
    };
  }
}

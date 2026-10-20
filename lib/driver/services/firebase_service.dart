import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../models/shipment_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fallback Constants
  static const String defaultVehicleNo = 'WP-DA-4821';
  static const String defaultDriverName = 'Driver';
  static const String defaultLicenseNo = 'B8392014';
  static const String defaultCompany = 'Customs Bonded Carrier Ltd';
  static const String defaultPhone = '+94 77 123 4567';

  /// Customs Shipments Dataset
  static List<ShipmentModel> get allCustomsShipments => [
        // ACTIVE
        ShipmentModel(
          id: 'SHP-2026-001',
          shipmentId: 'SHP-2026-001',
          containerId: 'CONT-001',
          driverName: 'Saman Kumara',
          vehicleNo: 'WP-DD-6556',
          origin: 'Colombo Port',
          destination: 'Orugodawatta Main Yard',
          status: 'Active',
          assignedRoute: 'Colombo Port - Orugodawatta Main Yard',
          sealNumber: 'SL-CUS-884912',
          iotDeviceId: 'ESP32-ST-0042',
          type: 'Standard 40ft High Cube',
          weight: '24,500 kg',
          cargoDescription: 'Industrial Electronics & Telecommunication Units',
          eta: 'Today, 4:30 PM',
          distance: '12 km',
          estimatedTime: '1h 15m',
          startLatitude: 6.9400,
          startLongitude: 79.8500,
          endLatitude: 6.9450,
          endLongitude: 79.8800,
          waypoints: const [
            LatLng(6.9380, 79.8650),
            LatLng(6.9420, 79.8720),
          ],
          tamperStatus: 'Secure',
          geofenceStatus: 'Inside Corridor',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        ShipmentModel(
          id: 'SHP-2026-002',
          shipmentId: 'SHP-2026-002',
          containerId: 'CONT-002',
          driverName: 'Amal Silva',
          vehicleNo: 'WP-DD-3468',
          origin: 'Colombo Port',
          destination: 'Grayline I',
          status: 'Active',
          assignedRoute: 'Colombo Port - Grayline I Corridor',
          sealNumber: 'SL-CUS-884920',
          iotDeviceId: 'ESP32-ST-0048',
          type: 'Standard 20ft Dry Box',
          weight: '16,800 kg',
          cargoDescription: 'Automotive Spare Parts & Heavy Engines',
          eta: 'Today, 5:15 PM',
          distance: '9.8 km',
          estimatedTime: '50 mins',
          startLatitude: 6.9400,
          startLongitude: 79.8500,
          endLatitude: 6.9550,
          endLongitude: 79.8950,
          waypoints: const [
            LatLng(6.9450, 79.8700),
          ],
          tamperStatus: 'Secure',
          geofenceStatus: 'Inside Corridor',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        ShipmentModel(
          id: 'SHP-2026-003',
          shipmentId: 'SHP-2026-003',
          containerId: 'CONT-003',
          driverName: 'Nimal Bandara',
          vehicleNo: 'WP-DA-4821',
          origin: 'Colombo Port',
          destination: 'Grayline II',
          status: 'Active',
          assignedRoute: 'Colombo Port - Grayline II Corridor',
          sealNumber: 'SL-CUS-884925',
          iotDeviceId: 'ESP32-ST-0056',
          type: '40ft Refrigerated (Reefer)',
          weight: '22,400 kg',
          cargoDescription: 'Frozen Seafood & Cold-Chain Goods',
          eta: 'Today, 6:00 PM',
          distance: '11.2 km',
          estimatedTime: '1h 00m',
          startLatitude: 6.9400,
          startLongitude: 79.8500,
          endLatitude: 6.9650,
          endLongitude: 79.9050,
          waypoints: const [
            LatLng(6.9500, 79.8800),
          ],
          tamperStatus: 'Secure',
          geofenceStatus: 'Inside Corridor',
          createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        ),
        ShipmentModel(
          id: 'SHP-2026-004',
          shipmentId: 'SHP-2026-004',
          containerId: 'CONT-004',
          driverName: 'Kasun Perera',
          vehicleNo: 'WP-DA-4821',
          origin: 'Colombo Port',
          destination: 'Orugodawatta Main Yard',
          status: 'Active',
          assignedRoute: 'Colombo Port - Orugodawatta Main Yard',
          sealNumber: 'SL-CUS-884913',
          iotDeviceId: 'ESP32-ST-0045',
          type: 'Standard 20ft Dry Box',
          weight: '18,200 kg',
          cargoDescription: 'Imported Garment Raw Materials & Textiles',
          eta: 'Tomorrow, 09:30 AM',
          distance: '8.5 km',
          estimatedTime: '45 mins',
          startLatitude: 6.9400,
          startLongitude: 79.8500,
          endLatitude: 6.9450,
          endLongitude: 79.8800,
          waypoints: const [
            LatLng(6.9420, 79.8650),
          ],
          tamperStatus: 'Secure',
          geofenceStatus: 'Inside Corridor',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),

        // PENDING
        ShipmentModel(
          id: 'SHP-2026-005',
          shipmentId: 'SHP-2026-005',
          containerId: 'CONT-005',
          driverName: 'Saman Kumara',
          vehicleNo: 'WP-DD-6556',
          origin: 'Colombo Port',
          destination: 'Grayline I',
          status: 'Pending',
          assignedRoute: 'Colombo Port - Grayline I Transit',
          sealNumber: 'SL-CUS-884914',
          iotDeviceId: 'ESP32-ST-0051',
          type: '40ft Refrigerated (Reefer)',
          weight: '21,000 kg',
          cargoDescription: 'Temperature-Controlled Essential Pharmaceuticals',
          eta: 'Tomorrow, 02:00 PM',
          distance: '10.0 km',
          estimatedTime: '50 mins',
          startLatitude: 6.9400,
          startLongitude: 79.8500,
          endLatitude: 6.9550,
          endLongitude: 79.8950,
          waypoints: const [
            LatLng(6.9480, 79.8700),
          ],
          tamperStatus: 'Secure',
          geofenceStatus: 'Inside Corridor',
          createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        ),
        ShipmentModel(
          id: 'SHP-2026-006',
          shipmentId: 'SHP-2026-006',
          containerId: 'CONT-006',
          driverName: 'Amal Silva',
          vehicleNo: 'WP-DD-3468',
          origin: 'Colombo Port',
          destination: 'Grayline II',
          status: 'Pending',
          assignedRoute: 'Colombo Port - Grayline II Transit',
          sealNumber: 'SL-CUS-884940',
          iotDeviceId: 'ESP32-ST-0071',
          type: 'Standard 40ft High Cube',
          weight: '26,300 kg',
          cargoDescription: 'Solar Power Panels & Inverter Batteries',
          eta: 'Tomorrow, 11:00 AM',
          distance: '11.5 km',
          estimatedTime: '1h 05m',
          startLatitude: 6.9400,
          startLongitude: 79.8500,
          endLatitude: 6.9650,
          endLongitude: 79.9050,
          waypoints: const [
            LatLng(6.9500, 79.8800),
          ],
          tamperStatus: 'Secure',
          geofenceStatus: 'Inside Corridor',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        ShipmentModel(
          id: 'SHP-2026-012',
          shipmentId: 'SHP-2026-012',
          containerId: 'CONT-012',
          driverName: 'Nimal Bandara',
          vehicleNo: 'WP-DA-4821',
          origin: 'Colombo Port',
          destination: 'Grayline I',
          status: 'Pending',
          assignedRoute: 'A6 - Ambepussa Transit Corridor',
          sealNumber: 'SL-CUS-884895',
          iotDeviceId: 'ESP32-ST-0012',
          type: 'Standard 40ft High Cube',
          weight: '27,000 kg',
          cargoDescription: 'Export Refined Minerals & Industrial Silica',
          eta: 'Delivered (Oct 05)',
          distance: '260 km',
          estimatedTime: '50 mins',
          startLatitude: 6.9400,
          startLongitude: 79.8500,
          endLatitude: 6.9550,
          endLongitude: 79.8950,
          waypoints: const [
            LatLng(6.9450, 79.8700),
          ],
          tamperStatus: 'Secure',
          geofenceStatus: 'Inside Corridor',
          createdAt: DateTime.now().subtract(const Duration(days: 6)),
        ),

        // COMPLETED
        ShipmentModel(
          id: 'SHP-2026-007',
          shipmentId: 'SHP-2026-007',
          containerId: 'CONT-007',
          driverName: 'Nimal Bandara',
          vehicleNo: 'WP-DA-4821',
          origin: 'Colombo Port',
          destination: 'Orugodawatta Main Yard',
          status: 'Completed',
          assignedRoute: 'Colombo Port - Orugodawatta Main Yard',
          sealNumber: 'SL-CUS-884910',
          iotDeviceId: 'ESP32-ST-0038',
          type: 'Standard 40ft High Cube',
          weight: '15,800 kg',
          cargoDescription: 'Apparel Exports - Inspected & Cleared',
          eta: 'Delivered (Yesterday)',
          distance: '12 km',
          estimatedTime: '1h 15m',
          startLatitude: 6.9400,
          startLongitude: 79.8500,
          endLatitude: 6.9450,
          endLongitude: 79.8800,
          waypoints: const [
            LatLng(6.9420, 79.8650),
          ],
          tamperStatus: 'Secure',
          geofenceStatus: 'Inside Corridor',
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        ShipmentModel(
          id: 'SHP-2026-008',
          shipmentId: 'SHP-2026-008',
          containerId: 'CONT-008',
          driverName: 'Kasun Perera',
          vehicleNo: 'WP-DA-4821',
          origin: 'Colombo Port',
          destination: 'Grayline I',
          status: 'Completed',
          assignedRoute: 'Colombo Port - Grayline I Corridor',
          sealNumber: 'SL-CUS-884908',
          iotDeviceId: 'ESP32-ST-0022',
          type: '40ft Heavy Duty Flat Rack',
          weight: '28,700 kg',
          cargoDescription: 'Heavy Industrial Harbour Maintenance Equipment',
          eta: 'Delivered (Oct 08)',
          distance: '9.8 km',
          estimatedTime: '50 mins',
          startLatitude: 6.9400,
          startLongitude: 79.8500,
          endLatitude: 6.9550,
          endLongitude: 79.8950,
          waypoints: const [
            LatLng(6.9480, 79.8700),
          ],
          tamperStatus: 'Secure',
          geofenceStatus: 'Inside Corridor',
          createdAt: DateTime.now().subtract(const Duration(hours: 7)),
        ),
        ShipmentModel(
          id: 'SHP-2026-009',
          shipmentId: 'SHP-2026-009',
          containerId: 'CONT-009',
          driverName: 'Kasun Perera',
          vehicleNo: 'WP-DA-4821',
          origin: 'Colombo Port',
          destination: 'Grayline I',
          status: 'Completed',
          assignedRoute: 'Colombo Port - Grayline I Corridor',
          sealNumber: 'SL-CUS-884908',
          iotDeviceId: 'ESP32-ST-0022',
          type: '40ft Heavy Duty Flat Rack',
          weight: '28,700 kg',
          cargoDescription: 'Heavy Industrial Harbour Maintenance Equipment',
          eta: 'Delivered (Oct 08)',
          distance: '9.8 km',
          estimatedTime: '50 mins',
          startLatitude: 6.9400,
          startLongitude: 79.8500,
          endLatitude: 6.9550,
          endLongitude: 79.8950,
          waypoints: const [
            LatLng(6.9480, 79.8700),
          ],
          tamperStatus: 'Secure',
          geofenceStatus: 'Inside Corridor',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        ShipmentModel(
          id: 'SHP-2026-010',
          shipmentId: 'SHP-2026-010',
          containerId: 'CONT-010',
          driverName: 'Amal Silva',
          vehicleNo: 'WP-DD-3468',
          origin: 'Colombo Port',
          destination: 'Grayline I',
          status: 'Completed',
          assignedRoute: 'Colombo Port - Grayline I Corridor',
          sealNumber: 'SL-CUS-884908',
          iotDeviceId: 'ESP32-ST-0022',
          type: '40ft Heavy Duty Flat Rack',
          weight: '28,700 kg',
          cargoDescription: 'Heavy Industrial Harbour Maintenance Equipment',
          eta: 'Delivered (Oct 08)',
          distance: '240 km',
          estimatedTime: '3h 30m',
          startLatitude: 6.9400,
          startLongitude: 79.8500,
          endLatitude: 6.9550,
          endLongitude: 79.8950,
          waypoints: const [
            LatLng(6.9450, 79.8700),
          ],
          tamperStatus: 'Secure',
          geofenceStatus: 'Inside Corridor',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        ShipmentModel(
          id: 'SHP-2026-011',
          shipmentId: 'SHP-2026-011',
          containerId: 'CONT-011',
          driverName: 'Saman Kumara',
          vehicleNo: 'WP-DD-6556',
          origin: 'Colombo Port',
          destination: 'Orugodawatta Main Yard',
          status: 'Completed',
          assignedRoute: 'Colombo Port - Orugodawatta Main Yard',
          sealNumber: 'SL-CUS-884902',
          iotDeviceId: 'ESP32-ST-0019',
          type: 'Standard 20ft Dry Box',
          weight: '17,400 kg',
          cargoDescription: 'Precision Electronic Machinery Components',
          eta: 'Delivered (Oct 07)',
          distance: '52 km',
          estimatedTime: '1h 15m',
          startLatitude: 6.9400,
          startLongitude: 79.8500,
          endLatitude: 6.9450,
          endLongitude: 79.8800,
          waypoints: const [
            LatLng(6.9380, 79.8650),
            LatLng(6.9420, 79.8720),
          ],
          tamperStatus: 'Secure',
          geofenceStatus: 'Inside Corridor',
          createdAt: DateTime.now().subtract(const Duration(days: 4)),
        ),
      ];

  /// Alerts Dataset
  static List<Map<String, dynamic>> get defaultCustomsAlerts => [
        {
          'id': 'alert_001',
          'title': 'Smart Seal Tamper Alert - CONT-001',
          'description': 'Dual-factor sensor trigger: Magnetic reed switch disengaged unexpectedly near corridor.',
          'type': 'tamper',
          'priority': 'critical',
          'isRead': false,
          'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 12))),
        },
        {
          'id': 'alert_002',
          'title': 'Route Corridor Deviation Warning',
          'description': 'Vehicle deviated outside approved geofence corridor.',
          'type': 'deviation',
          'priority': 'high',
          'isRead': false,
          'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 35))),
        },
        {
          'id': 'alert_003',
          'title': 'Customs Speed Threshold Exceeded',
          'description': 'Speed limit (60 km/h) exceeded on transit sector.',
          'type': 'instruction',
          'priority': 'important',
          'isRead': false,
          'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 1, minutes: 15))),
        },
        {
          'id': 'alert_004',
          'title': 'New Container Assigned',
          'description': 'Inspector paired container successfully with Smart Lock.',
          'type': 'shipment',
          'priority': 'normal',
          'isRead': true,
          'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2, minutes: 30))),
        },
        {
          'id': 'alert_005',
          'title': 'Customs Checkpoint Directive',
          'description': 'Mandatory security scan scheduled at gate checkpoint before depot entry.',
          'type': 'instruction',
          'priority': 'important',
          'isRead': true,
          'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 3))),
        },
        {
          'id': 'alert_006',
          'title': 'Delivery Confirmed & Seal Disarmed',
          'description': 'Shipment delivery logged and RFID seal unlocked by Inspector.',
          'type': 'completed',
          'priority': 'normal',
          'isRead': true,
          'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
        },
      ];

  /// Clears existing collection and seeds exactly 12 shipments with fixed IDs & correct driver mappings
  static Future<void> seedAllCollections() async {
    try {
      debugPrint('Cleaning and re-seeding Firestore collections...');

      final Map<String, Map<String, String>> drivers = {
        'NLLVf64UNCTtQqqVWoFbISNXANi2': {
          'name': 'Saman Kumara',
          'email': 'samankumara@gmail.com',
          'phone': '0774568925',
          'vehicleNo': 'WP-DD-6556',
          'company': 'Expolanka Logistics',
        },
        'aVXAL9vEk6amKpcBaAgHzyQbptO2': {
          'name': 'Amal Silva',
          'email': 'amal@gmail.com',
          'phone': '0768965984',
          'vehicleNo': 'WP-DD-3468',
          'company': 'DCD Logistics',
        },
        'lXEXEJuJXPOvUuOzyVrmcLBQkG03': {
          'name': 'Nimal Bandara',
          'email': 'nimalbandara28@gmail.com',
          'phone': '+94 77 456 4567',
          'vehicleNo': 'WP-DA-5588',
          'company': 'Customs Bonded Carrier Ltd',
        },
        'o9z4RdvhWys5YHgrFg1bcZkG03a2': {
          'name': 'Kasun Perera',
          'email': 'kasunperera@gmail.com',
          'phone': '+94 77 123 4567',
          'vehicleNo': 'WP-DA-4821',
          'company': 'Customs Bonded Carrier Ltd',
        },
      };

      final List<String> driverIds = drivers.keys.toList();

      // Delete all old documents in shipments collection to remove duplicates
      final oldShipments = await _firestore.collection('shipments').get();
      final deleteBatch = _firestore.batch();
      for (var doc in oldShipments.docs) {
        deleteBatch.delete(doc.reference);
      }
      await deleteBatch.commit();
      debugPrint('Cleared all existing old shipments.');

      // Seed Clean Shipments with Fixed Doc IDs (e.g., SHP-2026-001)
      final seedBatch = _firestore.batch();

      // Driver Name to UID mapping for exact consistency
      final Map<String, String> nameToUid = {
        'Saman Kumara': 'NLLVf64UNCTtQqqVWoFbISNXANi2',
        'Amal Silva': 'aVXAL9vEk6amKpcBaAgHzyQbptO2',
        'Nimal Bandara': 'lXEXEJuJXPOvUuOzyVrmcLBQkG03',
        'Kasun Perera': 'o9z4RdvhWys5YHgrFg1bcZkG03a2',
      };

      for (int i = 0; i < allCustomsShipments.length; i++) {
        final shipment = allCustomsShipments[i];
        final assignedDriverId = nameToUid[shipment.driverName] ?? driverIds[i % driverIds.length];
        final assignedDriverDetails = drivers[assignedDriverId] ?? drivers[driverIds[0]]!;

        // Use fixed ID from dataset so it never duplicates on sync
        final docRef = _firestore.collection('shipments').doc(shipment.id);

        final shipmentData = shipment.toFirestore()
          ..['id'] = shipment.id
          ..['driverId'] = assignedDriverId
          ..['driverName'] = assignedDriverDetails['name']!
          ..['vehicleNo'] = assignedDriverDetails['vehicleNo']!;

        seedBatch.set(docRef, shipmentData);
      }

      // Seed/Update Users Collection for Authorized Drivers
      for (var entry in drivers.entries) {
        final uid = entry.key;
        final details = entry.value;
        final userDocRef = _firestore.collection('users').doc(uid);

        seedBatch.set(
          userDocRef,
          {
            'uid': uid,
            'fullName': details['name'],
            'fullname': details['name'],
            'email': details['email'],
            'phone': details['phone'],
            'vehicleNo': details['vehicleNo'],
            'company': details['company'],
            'role': 'DRIVER',
            'vehicleType': 'Tata Prima 4928.S (Heavy Prime Mover)',
            'trailerType': '40ft Tri-Axle Skeletal Trailer',
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      // Seed Alerts with clean driverId distribution
      for (int i = 0; i < defaultCustomsAlerts.length; i++) {
        final alert = defaultCustomsAlerts[i];
        final assignedDriverId = driverIds[i % driverIds.length];
        final alertDocRef = _firestore.collection('alerts').doc(alert['id']);

        seedBatch.set(
          alertDocRef,
          {
            ...alert,
            'driverId': assignedDriverId,
          },
          SetOptions(merge: true),
        );
      }

      await seedBatch.commit();
      debugPrint('Successfully seeded shipments, authorized users, and alerts collections!');
    } catch (e) {
      debugPrint('Error seeding Firebase collections: $e');
      rethrow;
    }
  }

  /// Automatically seeds all collections if shipments or users collection is empty
  static Future<void> seedInitialDataIfEmpty() async {
    try {
      return;
    } catch (e) {
      debugPrint('Error checking/seeding collections: $e');
    }
  }
}
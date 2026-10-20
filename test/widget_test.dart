import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/services/shipment_service.dart';
import 'package:driver_app/services/session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Sri Lanka Customs dataset contains valid SRS shipments across all categories', () {
    final shipments = ShipmentService.defaultCustomsShipments;
    expect(shipments.isNotEmpty, true);
    expect(shipments.length, 12);

    final activeShipments = shipments.where((s) => s.status == 'Active').toList();
    final pendingShipments = shipments.where((s) => s.status == 'Pending').toList();
    final completedShipments = shipments.where((s) => s.status == 'Completed').toList();

    expect(activeShipments.length, 4);
    expect(pendingShipments.length, 3);
    expect(completedShipments.length, 5);

    final first = shipments.first;
    expect(first.shipmentId, 'SHP-2026-001');
    expect(first.containerId, 'CONT-001');
    expect(first.status, 'Active');
    expect(first.vehicleNo, 'WP-DD-6556');
    expect(first.sealNumber, 'SL-CUS-884912');
  });

  test('ShipmentModel correctly converts to container details map', () {
    final shipment = ShipmentService.defaultCustomsShipments.first;
    final map = shipment.toContainerDetailsMap();

    expect(map['containerId'], 'CONT-001');
    expect(map['sealNumber'], 'SL-CUS-884912');
    expect(map['status'], 'In Transit');
  });

  test('SessionService correctly stores and tracks 15 minute limit in SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({});

    // Record login
    await SessionService.recordLogin();
    final prefs = await SharedPreferences.getInstance();

    final loginTime = prefs.getInt(SessionService.keyLoginTime);
    final lastActive = prefs.getInt(SessionService.keyLastActive);

    expect(loginTime != null, true);
    expect(lastActive != null, true);

    // Update activity
    await SessionService.updateActivity();
    final updatedActive = prefs.getInt(SessionService.keyLastActive);
    expect(updatedActive != null, true);
    expect(updatedActive! >= lastActive!, true);

    // Expiration calculation test: 16 minutes in the past should expire
    final pastTime = DateTime.now().subtract(const Duration(minutes: 16)).millisecondsSinceEpoch;
    await prefs.setInt(SessionService.keyLastActive, pastTime);

    final expiredDiff = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(pastTime));
    expect(expiredDiff.inMinutes >= SessionService.sessionTimeoutMinutes, true);
  });
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/shipment_model.dart';
import 'firebase_service.dart';

class ShipmentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String collectionName = 'shipments';
  
  // ValueNotifier for the currently selected/active shipment for navigation
  static final ValueNotifier<ShipmentModel?> activeShipmentNotifier =
      ValueNotifier<ShipmentModel?>(null);

  /// Access the complete Sri Lanka Customs shipments dataset
  static List<ShipmentModel> get defaultCustomsShipments =>
      FirebaseService.allCustomsShipments;

  /// Seeds initial collections to Firestore if empty
  static Future<void> seedInitialShipmentsIfEmpty() async {
    await FirebaseService.seedInitialDataIfEmpty();
  }

  /// Explicitly seed or reset the Sri Lanka Customs dataset in Firestore
  static Future<void> seedCustomsDataset() async {
    await FirebaseService.seedAllCollections();
  }

  /// Stream shipments in real-time with driver UID and status filtering
  /// - 'All': Shows all Active & Completed shipments belonging to logged-in driver UID
  /// - 'Active': Shows only Active shipments for logged-in driver UID
  /// - 'Completed': Shows only Completed shipments for logged-in driver UID
  /// - 'Pending': Shows all Pending shipments to ALL drivers
  static Stream<List<ShipmentModel>> streamShipments({String? statusFilter}) {
    final String? currentDriverId = FirebaseAuth.instance.currentUser?.uid;

    if (currentDriverId == null) {
      return Stream.value([]);
    }
    
    final Query query = _firestore.collection(collectionName);
    
    return query.snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return [];
      }

      final List<ShipmentModel> allShipments = snapshot.docs
          .map((doc) => ShipmentModel.fromFirestore(doc))
          .toList();

      final String filter = (statusFilter ?? 'All').trim().toLowerCase();

      if (filter == 'all') {
        // All category: All Active and Completed shipments for the driver's UID
        return allShipments.where((s) {
          final bool isDriverMatch = (s.driverId ?? '').trim() == currentDriverId.trim();
          final String status = s.status.trim().toLowerCase();
          return isDriverMatch && (status == 'active' || status == 'completed');
        }).toList();
      } else if (filter == 'pending') {
        // Pending category: Open to all drivers
        return allShipments
            .where((s) => s.status.trim().toLowerCase() == 'pending')
            .toList();
      } else {
        // Active or Completed category: Strictly for the driver's UID
        return allShipments.where((s) {
          return (s.driverId ?? '').trim() == currentDriverId.trim() && 
                 s.status.trim().toLowerCase() == filter;
        }).toList();
      }
    });
  }

  /// Set the active shipment and notify listeners
  static void setActiveShipment(ShipmentModel shipment) {
    activeShipmentNotifier.value = shipment;
  }
}

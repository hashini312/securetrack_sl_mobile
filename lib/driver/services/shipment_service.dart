import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shipment_model.dart';
import 'firebase_service.dart';

class ShipmentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String collectionName = 'shipments';
  
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

  /// Stream shipments in real-time
  /// Shows all Active, Completed, or Pending Customs shipments seamlessly.
  static Stream<List<ShipmentModel>> streamShipments({String? statusFilter}) {
    final Query query = _firestore.collection(collectionName);
    
    return query.snapshots().map((snapshot) {
      List<ShipmentModel> list = [];

      if (snapshot.docs.isNotEmpty) {
        list = snapshot.docs
            .map((doc) => ShipmentModel.fromFirestore(doc))
            .toList();
      }

      // If Firestore is empty, fallback to the pre-configured customs fleet dataset
      if (list.isEmpty) {
        list = defaultCustomsShipments;
      }

      final String filter = (statusFilter ?? 'All').trim().toLowerCase();

      if (filter == 'all') {
        return list;
      } else {
        return list.where((s) => s.status.trim().toLowerCase() == filter).toList();
      }
    });
  }

  /// Set the active shipment and notify listeners
  static void setActiveShipment(ShipmentModel shipment) {
    activeShipmentNotifier.value = shipment;
  }
}

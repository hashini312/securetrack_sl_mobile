import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

class ContainerDetailsScreen extends StatefulWidget {
  final VoidCallback onStartRoute;
  final Map<String, dynamic>? containerData;

  const ContainerDetailsScreen({
    super.key,
    required this.onStartRoute,
    this.containerData,
  });

  @override
  State<ContainerDetailsScreen> createState() => _ContainerDetailsScreenState();
}

class _ContainerDetailsScreenState extends State<ContainerDetailsScreen> {
  String driverVehicleNo = "Loading...";

  @override
  void initState() {
    super.initState();
    _getVehicleNoByUID();
  }

  Future<void> _getVehicleNoByUID() async {
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          var data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            driverVehicleNo = data['vehicleNo'] ?? FirebaseService.defaultVehicleNo;
          });
        }
      }
    } catch (e) {
      setState(() {
        driverVehicleNo = FirebaseService.defaultVehicleNo;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final String containerId = widget.containerData?['containerId'] ?? 'CONT-001';
    final String status = widget.containerData?['status'] ?? 'In Transit';
    final String origin = widget.containerData?['origin'] ?? 'Colombo Port';
    final String destination = widget.containerData?['destination'] ?? 'Orugodawatte Yard';
    final String weight = widget.containerData?['weight'] ?? '24,500 kg';
    final String eta = widget.containerData?['eta'] ?? 'Today, 4:30 PM';
    final String cargo = widget.containerData?['cargoDescription'] ?? 'Industrial Electronics & Equipment';
    final String? sealNumber = widget.containerData?['sealNumber'] ?? 'SL-CUS-884912';
    
    Color statusBgColor;
    switch (status.toLowerCase()) {
      case 'active':
      case 'in transit':
        statusBgColor = Color(0xFF10A34E);
        break;
      case 'completed':
      case 'delivered':
        statusBgColor = const Color(0xFF2563EB);
        break;
      case 'pending':
        statusBgColor = Colors.orange.shade700;
        break;
      default:
        statusBgColor = const Color(0xFF2563EB);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : const Color(0xFF1E3A8A),
          onPressed: () => Navigator.pop(context),
       ),
       title: Text(
        'Container Details',
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : const Color(0xFF1E3A8A),
          fontWeight: FontWeight.bold,
        ),
       ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.inventory_2,
                        size: 45,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            containerId,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                            ),
                          ),
                          const SizedBox(height: 6),


                          // Status Badge
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusBgColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: statusBgColor, width: 1.2),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: statusBgColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                           ),
                          ),

                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 6),
                          
                          // Journey Route Text
                          Text(
                            '$origin → $destination',
                            style: TextStyle(
                              color: isDark ? Colors.grey.shade300 : const Color(0xFF1E3A8A),
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                // Pickup Location
                _buildDetailRow(
                  context: context,
                  icon: Icons.location_on,
                  title: '${'pickup_origin'.tr()}:',
                  value: origin,
                ),
                const SizedBox(height: 16),

                // Delivery Location
                _buildDetailRow(
                  context: context,
                  icon: Icons.local_shipping,
                  title: '${'delivery_destination'.tr()}:',
                  value: destination,
                ),
                const SizedBox(height: 16),

                // Cargo Contents
                _buildDetailRow(
                  context: context,
                  icon: Icons.description_outlined,
                  title: '${'cargo_contents'.tr()}:',
                  value: cargo,
                ),
                const SizedBox(height: 16),

                // ETA
                _buildDetailRow(
                  context: context,
                  icon: Icons.access_time_filled,
                  title: '${'estimated_arrival'.tr()}:',
                  value: eta,
                ),
                const SizedBox(height: 16),

                // Vehicle Details & Weight
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailRow(
                        context: context,
                        icon: Icons.directions_car,
                        title: '${'vehicle_details'.tr()}:',
                        value: driverVehicleNo,
                      ),
                    ),
                    Expanded(
                      child: _buildDetailRow(
                        context: context,
                        icon: Icons.scale_rounded,
                        title: '${'gross_weight'.tr()}:',
                        value: weight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                //Seal Number
                _buildDetailRow(
                  context: context,
                  icon: Icons.lock,
                  title: '${'seal_number'.tr()}:',
                  value: sealNumber ?? 'N/A',
                ),
                const SizedBox(height: 16),

                // Start Route Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onStartRoute();
                    },
                    icon: const Icon(Icons.navigation, color: Colors.white),
                    label: Text(
                      'start_navigation'.tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? const Color.fromARGB(255, 43, 70, 132) : Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isDark ? Colors.blue.shade300 : const Color(0xFF1E3A8A),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.white : const Color(0xFF1E40AF),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
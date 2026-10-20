import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/screens/container_details_screen.dart';
import 'package:driver_app/screens/shipments_screen.dart';
import 'package:driver_app/services/shipment_service.dart';
import 'package:driver_app/services/firebase_service.dart';
import 'package:driver_app/models/shipment_model.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const HomeScreen({
    super.key,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder<DocumentSnapshot>(
      stream: currentUser != null
          ? FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .snapshots()
          : null,
      builder: (context, snapshot) {
        String userName = FirebaseService.defaultDriverName;
        String vehicleNo = FirebaseService.defaultVehicleNo;

        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
          final userData = snapshot.data!.data() as Map<String, dynamic>?;

          if (userData != null) {
            userName = userData['fullName'] ?? userData['fullname'] ?? FirebaseService.defaultDriverName;
            vehicleNo = userData['vehicleNo'] ?? FirebaseService.defaultVehicleNo;
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'hello'.tr(),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                        ),
                      ),
                    ],
                  ),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? Colors.blue.shade700 : const Color(0xFF1E3A8A).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.directions_car,
                          size: 16,
                          color: isDark ? Colors.blue.shade300 : const Color(0xFF1E3A8A),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          vehicleNo,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Assigned Container Card
              StreamBuilder<List<ShipmentModel>>(
                stream: ShipmentService.streamShipments(statusFilter: 'Active'),
                builder: (context, shipmentSnapshot) {
                  final activeShipments = shipmentSnapshot.data ?? [];

                  if (activeShipments.isEmpty) {
                    return Card(
                      color: isDark ? const Color(0xFF1F2937) : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Center(
                          child: Text(
                            'No Active Container Assigned',
                            style: TextStyle(
                              color: isDark ? Colors.grey.shade400 : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  final ShipmentModel activeShipment = activeShipments.first;

                  return Card(
                    color: isDark ? const Color(0xFF1F2937) : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'assigned_container'.tr(),
                                style: TextStyle(
                                  color: isDark ? Colors.grey.shade400 : Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10A34E).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'filter_active'.tr(),
                                  style: const TextStyle(
                                    color: Color(0xFF10A34E),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E3A8A),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.inventory_2,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activeShipment.containerId,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                                      ),
                                    ),
                                    Text(
                                      '${activeShipment.origin} -> ${activeShipment.destination}',
                                      style: TextStyle(
                                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E3A8A),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ContainerDetailsScreen(
                                      containerData: activeShipment.toContainerDetailsMap(),
                                      onStartRoute: () {
                                        ShipmentService.setActiveShipment(activeShipment);
                                        onNavigate(1);
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                'view_details'.tr(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Quick Actions Section
              Text(
                'quick_actions'.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              _buildQuickAction(
                context,
                Icons.location_on,
                'view_route'.tr(),
                Colors.green,
                () {
                  onNavigate(1);
                },
                isDark,
              ),
              _buildQuickAction(
                context,
                Icons.inventory_2_outlined,
                'my_shipments'.tr(),
                const Color(0xFF1E3A8A),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShipmentsScreen(
                        onNavigateTab: onNavigate,
                      ),
                    ),
                  );
                },
                isDark,
              ),
              _buildQuickAction(
                context,
                Icons.phone,
                'contact_customs'.tr(),
                Colors.purple,
                () {
                  _showContactCustomsDialog(context, isDark);
                },
                isDark,
              ),
              _buildQuickAction(
                context,
                Icons.warning_amber_rounded,
                'report_issue'.tr(),
                Colors.red,
                () {
                  _showReportIssueDialog(context, isDark);
                },
                isDark,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
    bool isDark,
  ) {
    return Card(
      color: isDark ? const Color(0xFF1F2937) : null,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.grey.shade800 : Colors.transparent,
        ),
      ),
      elevation: 0.5,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDark ? Colors.grey.shade400 : Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showContactCustomsDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F2937) : null,
        title: Row(
          children: [
            const Icon(Icons.shield, color: Color(0xFF1E3A8A)),
            const SizedBox(width: 8),
            Text(
              'contact_customs'.tr(),
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SecureTrack SL Emergency Operations Centre',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade300 : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildPhoneRow(context, 'Customs Hotline', '+94112221300', '+94 11 222 1300', isDark),
            const SizedBox(height: 8),
            _buildPhoneRow(context, 'Control Room', '+94112478888', '+94 11 247 8888', isDark),
            const SizedBox(height: 8),
            _buildPhoneRow(context, 'Rapid Response Unit', '1933', '1933', isDark),
            const SizedBox(height: 12),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('close'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneRow(BuildContext context, String label, String rawNumber, String displayNumber, bool isDark) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () async {
        final Uri launchUri = Uri(
          scheme: 'tel',
          path: rawNumber,
        );
        try {
          if (await canLaunchUrl(launchUri)) {
            await launchUrl(launchUri, mode: LaunchMode.externalApplication);
          } else {
            await launchUrl(launchUri);
          }
        } catch (_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not launch phone dialer')),
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? Colors.blue.shade900 : Colors.blue.shade100,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.phone, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    displayNumber,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'CALL',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportIssueDialog(BuildContext context, bool isDark) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F2937) : null,
        title: Text(
          'report_issue'.tr(),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Submit incident report directly to Sri Lanka Customs monitoring officers:',
              style: TextStyle(
                color: isDark ? Colors.grey.shade300 : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              maxLines: 3,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Describe issue (e.g. breakdown, road blocked, tamper alert)...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null && textController.text.trim().isNotEmpty) {
                try {
                  await FirebaseFirestore.instance.collection('alerts').add({
                    'driverId': user.uid,
                    'title': 'Driver Incident Report',
                    'description': textController.text.trim(),
                    'type': 'emergency',
                    'priority': 'high',
                    'timestamp': FieldValue.serverTimestamp(),
                    'isRead': false,
                  });
                } catch (_) {}
              }
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Incident reported to Customs Control Room.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('submit'.tr(), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
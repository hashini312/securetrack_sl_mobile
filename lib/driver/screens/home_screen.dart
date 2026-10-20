import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:securetrack_sl/owner/components.dart';
import 'package:securetrack_sl/driver/models/shipment_model.dart';
import 'package:securetrack_sl/driver/screens/container_details_screen.dart';
import 'package:securetrack_sl/driver/screens/shipments_screen.dart';
import 'package:securetrack_sl/driver/services/shipment_service.dart';
import 'package:securetrack_sl/driver/services/firebase_service.dart';
import 'package:securetrack_sl/driver/driver_sos_dialog.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const HomeScreen({
    super.key,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Driver Profile Banner Card matching Owner App UI
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.accentBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Center(
                        child: Icon(Icons.person, color: Colors.white, size: 30),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Authorized Haulier',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            userName,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.local_shipping, size: 14, color: AppColors.skyBlue),
                              const SizedBox(width: 4),
                              Text(
                                vehicleNo,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.skyBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // SOS Emergency Button in Header
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => DriverSosDialog(
                            containerId: 'Active Container',
                            vehicleNo: vehicleNo,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.dangerRed,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.emergency_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              'SOS',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Section Header: Active Assigned Transit
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Consignment',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShipmentsScreen(onNavigateTab: onNavigate),
                        ),
                      );
                    },
                    icon: const Icon(Icons.history, size: 16, color: AppColors.accentBlue),
                    label: Text(
                      'All Cargo',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentBlue,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Active Shipment Card matching Owner Container Card UI
              StreamBuilder<List<ShipmentModel>>(
                stream: ShipmentService.streamShipments(statusFilter: 'Active'),
                builder: (context, shipmentSnapshot) {
                  final activeShipments = shipmentSnapshot.data ?? [];

                  if (activeShipments.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textLight),
                          const SizedBox(height: 12),
                          Text(
                            'No Active Container Assigned',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isDark ? Colors.white70 : AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Wait for Customs Operations to arm an e-lock trip',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final ShipmentModel active = activeShipments.first;
                  final isTampered = active.tamperStatus.toLowerCase().contains('tamper');
                  final isInside = active.geofenceStatus.toLowerCase().contains('inside');

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ContainerDetailsScreen(
                            onStartRoute: () => onNavigate(1),
                            containerData: {
                              'containerId': active.containerId,
                              'sealNumber': active.sealNumber,
                              'origin': active.origin,
                              'destination': active.destination,
                              'cargoDescription': active.cargoDescription,
                              'weight': active.weight,
                              'type': active.type,
                              'status': active.status,
                              'iotDeviceId': active.iotDeviceId,
                              'eta': active.eta,
                              'distance': active.distance,
                            },
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isTampered
                              ? AppColors.dangerRed
                              : AppColors.borderLight,
                          width: isTampered ? 1.5 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row: Container ID & Status Badges
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    active.containerId,
                                    style: GoogleFonts.poppins(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : AppColors.textDark,
                                    ),
                                  ),
                                  Text(
                                    'Seal: ${active.sealNumber}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isTampered ? AppColors.dangerLight : AppColors.successLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isTampered ? Icons.warning_rounded : Icons.lock_outline,
                                      size: 14,
                                      color: isTampered ? AppColors.dangerRed : AppColors.successGreen,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isTampered ? 'Tamper Alert' : 'Secure',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isTampered ? AppColors.dangerRed : AppColors.successGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Transit Corridor info
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.route, size: 20, color: AppColors.primaryBlue),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${active.origin}  ➔  ${active.destination}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white70 : AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Status indicators (Geofence & IoT Telemetry)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isInside ? Icons.check_circle : Icons.error,
                                    size: 15,
                                    color: isInside ? AppColors.successGreen : AppColors.warningOrange,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    active.geofenceStatus,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isInside ? AppColors.successGreen : AppColors.warningOrange,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.developer_board, size: 15, color: AppColors.primaryBlue),
                                  const SizedBox(width: 6),
                                  Text(
                                    active.iotDeviceId,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const Divider(height: 24),

                          // Quick Action: Open GPS Corridor Navigation
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => onNavigate(1),
                              icon: const Icon(Icons.navigation_rounded, size: 18),
                              label: Text(
                                'Start GPS Navigation',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // SRS Quick Guidance Cards
              Text(
                'Transit Guidelines & Safety',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _buildGuidelineCard(
                      icon: Icons.alt_route,
                      title: 'Stay in Corridor',
                      subtitle: '50m deviation triggers Customs breach',
                      color: AppColors.infoBlue,
                      bgColor: AppColors.infoLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGuidelineCard(
                      icon: Icons.lock_clock,
                      title: 'Intact Seal',
                      subtitle: 'Do not detach RFID bolt seal',
                      color: AppColors.warningOrange,
                      bgColor: AppColors.warningLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGuidelineCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

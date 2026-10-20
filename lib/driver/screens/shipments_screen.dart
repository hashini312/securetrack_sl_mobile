import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:securetrack_sl/owner/components.dart';
import '../models/shipment_model.dart';
import '../services/shipment_service.dart';
import 'container_details_screen.dart';

class ShipmentsScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const ShipmentsScreen({super.key, this.onNavigateTab});

  @override
  State<ShipmentsScreen> createState() => _ShipmentsScreenState();
}

class _ShipmentsScreenState extends State<ShipmentsScreen> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSeeding = false;

  @override
  void initState() {
    super.initState();
    ShipmentService.seedInitialShipmentsIfEmpty();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleSeedData() async {
    setState(() => _isSeeding = true);
    try {
      await ShipmentService.seedCustomsDataset();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customs consignment dataset synchronized successfully!'),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync error: $e'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.successGreen;
      case 'pending':
        return AppColors.warningOrange;
      case 'completed':
        return AppColors.accentBlue;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<String> filters = ['All', 'Active', 'Pending', 'Completed'];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
      appBar: AppBar(
        title: Text(
          'Customs Consignments',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Sync Customs Dataset',
            icon: _isSeeding
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
                  )
                : const Icon(Icons.cloud_sync_rounded, color: AppColors.primaryBlue),
            onPressed: _isSeeding ? null : _handleSeedData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            child: Column(
              children: [
                // Modern Search Bar
                TextField(
                  controller: _searchController,
                  style: GoogleFonts.poppins(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search Container ID, Seal No, Destination...',
                    hintStyle: GoogleFonts.poppins(color: AppColors.textLight, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.primaryBlue),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.borderLight),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val.trim().toLowerCase());
                  },
                ),
                const SizedBox(height: 12),

                // Category Filter Chips matching Owner Tab bar style
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: filters.map((f) {
                      final bool isSelected = _selectedFilter == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(
                            f,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : AppColors.textMedium),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primaryBlue,
                          backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primaryBlue
                                  : AppColors.borderLight,
                            ),
                          ),
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedFilter = f);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Shipment List
          Expanded(
            child: StreamBuilder<List<ShipmentModel>>(
              stream: ShipmentService.streamShipments(
                statusFilter: _selectedFilter == 'All' ? null : _selectedFilter,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<ShipmentModel> shipments = snapshot.data ?? [];

                // Fallback to offline customs dataset if empty
                if (shipments.isEmpty && _selectedFilter == 'All' && _searchQuery.isEmpty) {
                  shipments = ShipmentService.defaultCustomsShipments;
                }

                // Filter by search query if entered
                if (_searchQuery.isNotEmpty) {
                  shipments = shipments.where((s) {
                    return s.containerId.toLowerCase().contains(_searchQuery) ||
                        s.shipmentId.toLowerCase().contains(_searchQuery) ||
                        s.destination.toLowerCase().contains(_searchQuery) ||
                        s.origin.toLowerCase().contains(_searchQuery) ||
                        s.sealNumber.toLowerCase().contains(_searchQuery) ||
                        s.cargoDescription.toLowerCase().contains(_searchQuery) ||
                        s.vehicleNo.toLowerCase().contains(_searchQuery);
                  }).toList();
                }

                if (shipments.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 56, color: AppColors.textLight),
                          const SizedBox(height: 14),
                          Text(
                            'No Consignments Found ($_selectedFilter)',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh, size: 16),
                            label: Text('Sync Sri Lanka Customs Fleet', style: GoogleFonts.poppins(fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _handleSeedData,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: shipments.length,
                  itemBuilder: (context, index) {
                    final shipment = shipments[index];
                    return _buildShipmentCard(context, shipment, isDark);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShipmentCard(BuildContext context, ShipmentModel shipment, bool isDark) {
    final statusColor = _getStatusColor(shipment.status);
    final isTampered = shipment.tamperStatus.toLowerCase().contains('tamper');

    return Container(
      margin: const EdgeInsets.only(bottom: 14.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isTampered ? AppColors.dangerRed : AppColors.borderLight,
          width: isTampered ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContainerDetailsScreen(
                onStartRoute: () {
                  Navigator.pop(context);
                  widget.onNavigateTab?.call(1);
                },
                containerData: {
                  'containerId': shipment.containerId,
                  'sealNumber': shipment.sealNumber,
                  'origin': shipment.origin,
                  'destination': shipment.destination,
                  'cargoDescription': shipment.cargoDescription,
                  'weight': shipment.weight,
                  'type': shipment.type,
                  'status': shipment.status,
                  'iotDeviceId': shipment.iotDeviceId,
                  'eta': shipment.eta,
                  'distance': shipment.distance,
                },
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Container ID + Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.skyBlue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.all_inbox_rounded, color: AppColors.primaryBlue, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shipment.containerId,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.textDark,
                            ),
                          ),
                          Text(
                            'Seal: ${shipment.sealNumber}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      shipment.status.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Route representation
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.route, size: 16, color: AppColors.primaryBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${shipment.origin}  ➔  ${shipment.destination}',
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

              const SizedBox(height: 10),

              // Cargo & IoT details
              Text(
                shipment.cargoDescription,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
              ),

              const SizedBox(height: 12),

              // Bottom Info Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 14, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Text(
                        shipment.eta,
                        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.developer_board, size: 14, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Text(
                        shipment.iotDeviceId,
                        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, size: 18, color: AppColors.primaryBlue),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

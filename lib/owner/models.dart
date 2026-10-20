import 'package:flutter/material.dart';

/// Container data representation
class ContainerModel {
  final String id;
  final String owner;
  final String ownerEmail;
  final String isoContainerNo;
  final String cusdecNumber;
  final String billOfLading;
  final String vesselName;
  final String cargoDescription;
  final String route;
  final String currentLocation;
  final String destination;
  final String estimatedArrival;
  final String driverName;
  final String driverPhone;
  final String sealStatus;
  final String sealId;
  final int batteryLevel;
  final double temperature;
  final double latitude;
  final double longitude;
  final int speed;
  final String status; // 'On Track', 'Arrived'
  final String gpsStatus; // 'GPS Active', 'Last Known Safe Point'
  final Color containerColor;
  final String assetImage;

  const ContainerModel({
    required this.id,
    required this.owner,
    this.ownerEmail = 'owner@cargooverseas.lk',
    this.isoContainerNo = 'MSCU 782910 4',
    this.cusdecNumber = 'CUSDEC-2026-COL-049182',
    this.billOfLading = 'MSCU-COL-892104',
    this.vesselName = 'MSC ALTAIR V-264E',
    this.cargoDescription = 'General Merchandise',
    required this.route,
    required this.currentLocation,
    required this.destination,
    required this.estimatedArrival,
    required this.driverName,
    this.driverPhone = '+94 77 987 6543',
    required this.sealStatus,
    this.sealId = 'ESEAL-SL-90821',
    required this.batteryLevel,
    this.temperature = 28.5,
    this.latitude = 6.9455,
    this.longitude = 79.8510,
    this.speed = 42,
    required this.status,
    this.gpsStatus = 'GPS Active',
    required this.containerColor,
    required this.assetImage,
  });

  static List<ContainerModel> get sampleContainers => const [
        ContainerModel(
          id: 'CONT-001',
          owner: 'Cargo Overseas Freight Pvt Ltd',
          ownerEmail: 'owner@cargooverseas.lk',
          isoContainerNo: 'MSCU 782910 4',
          cusdecNumber: 'CUSDEC-2026-COL-049182',
          billOfLading: 'MSCU-COL-892104',
          vesselName: 'MSC ALTAIR V-264E',
          cargoDescription: 'Automotive Spare Parts & Heavy Machinery',
          route: 'Colombo Port Gate 04 ➔ Orugodawatta Customs Yard (RCT)',
          currentLocation: 'Baseline Road, Colombo',
          destination: 'Orugodawatta Examination Yard (RCT)',
          estimatedArrival: '12 Sep 2026 , 10.00 AM',
          driverName: 'S.A. Gamage',
          sealStatus: 'Intact',
          sealId: 'ESEAL-SL-90821',
          batteryLevel: 75,
          temperature: 28.4,
          latitude: 6.9455,
          longitude: 79.8510,
          speed: 42,
          status: 'On Track',
          containerColor: Color(0xFF10B981), // Green
          assetImage: 'assets/images/cont_green.png',
        ),
        ContainerModel(
          id: 'CONT-002',
          owner: 'Cargo Overseas Freight Pvt Ltd',
          ownerEmail: 'owner@cargooverseas.lk',
          isoContainerNo: 'CMAU 492018 2',
          cusdecNumber: 'CUSDEC-2026-COL-051839',
          billOfLading: 'CMAU-COL-391084',
          vesselName: 'CMA CGM COLOMBO V-102N',
          cargoDescription: 'Industrial Electrical Panels & Switchgear Units',
          route: 'Colombo Port Gate 02 ➔ Grayline 1 (GL1) Yard (Grandpass)',
          currentLocation: 'Prince of Wales Ave, Colombo 14',
          destination: 'Grayline 1 (GL1) Examination Yard',
          estimatedArrival: '12 Sep 2026 , 11.30 AM',
          driverName: 'K.D. Kumara',
          sealStatus: 'Intact',
          sealId: 'ESEAL-SL-90822',
          batteryLevel: 20,
          temperature: 29.1,
          latitude: 6.9410,
          longitude: 79.8525,
          speed: 35,
          status: 'On Track',
          containerColor: Color(0xFFD97706), // Brown/Amber
          assetImage: 'assets/images/cont_brown.png',
        ),
        ContainerModel(
          id: 'CONT-003',
          owner: 'Cargo Overseas Freight Pvt Ltd',
          ownerEmail: 'owner@cargooverseas.lk',
          isoContainerNo: 'HLCU 982019 5',
          cusdecNumber: 'CUSDEC-2026-COL-038291',
          billOfLading: 'HLCU-COL-992105',
          vesselName: 'HAPAG LLOYD EXPRESS V-509',
          cargoDescription: 'Garment Accessories & Textile Raw Fabrics',
          route: 'Colombo Port Gate 05 ➔ Grayline 2 (GL2) Yard (Peliyagoda)',
          currentLocation: 'Grayline 2 Yard Terminal, Peliyagoda',
          destination: 'Grayline 2 (GL2) Examination Yard',
          estimatedArrival: '10 Sep 2026 , 02.00 PM',
          driverName: 'R.M. Perera',
          sealStatus: 'Intact',
          sealId: 'ESEAL-SL-90823',
          batteryLevel: 92,
          temperature: 27.5,
          latitude: 6.9580,
          longitude: 79.8650,
          speed: 0,
          status: 'Arrived',
          containerColor: Color(0xFF2563EB), // Blue
          assetImage: 'assets/images/cont_blue.png',
        ),
        ContainerModel(
          id: 'CONT-004',
          owner: 'Ceylon Global Freight & Logistics Ltd',
          ownerEmail: 'kasun.fernando@ceylonlogistics.lk',
          isoContainerNo: 'MEDU 839201 9',
          cusdecNumber: 'CUSDEC-2026-COL-071829',
          billOfLading: 'MEDU-COL-409182',
          vesselName: 'MAERSK COLOMBO V-88',
          cargoDescription: 'Pharmaceutical Goods & Medical Supplies (Cold Chain)',
          route: 'Colombo Port Gate 04 ➔ Orugodawatta Customs Yard (RCT)',
          currentLocation: 'Ingurukade Junction Corridor',
          destination: 'Orugodawatta Customs Yard (RCT)',
          estimatedArrival: '12 Sep 2026 , 11.45 AM',
          driverName: 'M.T. Bandara',
          sealStatus: 'Intact',
          sealId: 'ESEAL-SL-90824',
          batteryLevel: 88,
          temperature: 4.2,
          latitude: 6.9420,
          longitude: 79.8580,
          speed: 38,
          status: 'On Track',
          containerColor: Color(0xFF0284C7),
          assetImage: 'assets/images/cont_blue.png',
        ),
        ContainerModel(
          id: 'CONT-005',
          owner: 'Lanka Maritime Forwarders Pvt Ltd',
          ownerEmail: 'anura.wijesinghe@lankaforwarding.lk',
          isoContainerNo: 'ONEU 392019 4',
          cusdecNumber: 'CUSDEC-2026-COL-062910',
          billOfLading: 'ONEU-COL-551029',
          vesselName: 'ONE HARBOUR V-33E',
          cargoDescription: 'Chemical Reagents & Industrial Resins',
          route: 'Colombo Port Gate 02 ➔ Grayline 1 (GL1) Yard Grandpass',
          currentLocation: 'Kochchikade Terminal Gate',
          destination: 'Grayline 1 (GL1) Yard Grandpass',
          estimatedArrival: '12 Sep 2026 , 12.00 PM',
          driverName: 'N.H. Rathnayake',
          sealStatus: 'Intact',
          sealId: 'ESEAL-SL-90825',
          batteryLevel: 85,
          temperature: 28.0,
          latitude: 6.9470,
          longitude: 79.8620,
          speed: 30,
          status: 'On Track',
          containerColor: Color(0xFF10B981),
          assetImage: 'assets/images/cont_green.png',
        ),
        ContainerModel(
          id: 'CONT-006',
          owner: 'Ceylon Global Freight & Logistics Ltd',
          ownerEmail: 'kasun.fernando@ceylonlogistics.lk',
          isoContainerNo: 'TGHU 928104 1',
          cusdecNumber: 'CUSDEC-2026-COL-083912',
          billOfLading: 'TGHU-COL-772910',
          vesselName: 'EVER GIVEN V-114W',
          cargoDescription: 'High-Grade Ceylon Tea Machinery & Packaging Equipment',
          route: 'Colombo Port Gate 05 ➔ Grayline 2 (GL2) Yard Peliyagoda',
          currentLocation: 'Sugathadasa / Prince of Wales Ave Corridor',
          destination: 'Grayline 2 (GL2) Examination Yard',
          estimatedArrival: '12 Sep 2026 , 10.45 AM',
          driverName: 'K.A. Jayalath',
          sealStatus: 'Intact',
          sealId: 'ESEAL-SL-90826',
          batteryLevel: 95,
          temperature: 27.8,
          latitude: 6.9540,
          longitude: 79.8690,
          speed: 36,
          status: 'On Track',
          containerColor: Color(0xFFD97706),
          assetImage: 'assets/images/cont_brown.png',
        ),
        ContainerModel(
          id: 'CONT-007',
          owner: 'Ceylon Global Freight & Logistics Ltd',
          ownerEmail: 'kasun.fernando@ceylonlogistics.lk',
          isoContainerNo: 'MSKU 102948 3',
          cusdecNumber: 'CUSDEC-2026-COL-091820',
          billOfLading: 'MSKU-COL-301948',
          vesselName: 'MAERSK MC-KINNEY V-90',
          cargoDescription: 'Apparel Fabrics & High-Value Electronic Components',
          route: 'Colombo Port Gate 02 ➔ Grayline 1 (GL1) Yard Grandpass',
          currentLocation: 'Grayline 1 (GL1) Yard Grandpass',
          destination: 'Grayline 1 (GL1) Examination Yard',
          estimatedArrival: '11 Sep 2026 , 08.15 AM',
          driverName: 'P.B. Senaratne',
          sealStatus: 'Intact',
          sealId: 'ESEAL-SL-90827',
          batteryLevel: 82,
          temperature: 28.1,
          latitude: 6.9525,
          longitude: 79.8730,
          speed: 0,
          status: 'Arrived',
          containerColor: Color(0xFF10B981),
          assetImage: 'assets/images/cont_green.png',
        ),
        ContainerModel(
          id: 'CONT-008',
          owner: 'Lanka Maritime Forwarders Pvt Ltd',
          ownerEmail: 'anura.wijesinghe@lankaforwarding.lk',
          isoContainerNo: 'CLLU 782019 0',
          cusdecNumber: 'CUSDEC-2026-COL-044912',
          billOfLading: 'CLLU-COL-662910',
          vesselName: 'COSCO ASIA V-402E',
          cargoDescription: 'Industrial Steel Beams & Construction Fasteners',
          route: 'Colombo Port Gate 04 ➔ Orugodawatta Customs Yard (RCT)',
          currentLocation: 'Ingurukade Junction Terminal',
          destination: 'Orugodawatta Customs Yard (RCT)',
          estimatedArrival: '12 Sep 2026 , 11.30 AM',
          driverName: 'W.M. Dharmadasa',
          sealStatus: 'Intact',
          sealId: 'ESEAL-SL-90828',
          batteryLevel: 91,
          temperature: 29.0,
          latitude: 6.9460,
          longitude: 79.8650,
          speed: 40,
          status: 'On Track',
          containerColor: Color(0xFF0284C7),
          assetImage: 'assets/images/cont_blue.png',
        ),
        ContainerModel(
          id: 'CONT-009',
          owner: 'Lanka Maritime Forwarders Pvt Ltd',
          ownerEmail: 'anura.wijesinghe@lankaforwarding.lk',
          isoContainerNo: 'TEMU 640192 8',
          cusdecNumber: 'CUSDEC-2026-COL-058913',
          billOfLading: 'TEMU-COL-189204',
          vesselName: 'YANG MING EXPRESS V-22',
          cargoDescription: 'Solar Inverters & Lithium Battery Energy Storage Systems',
          route: 'Colombo Port Gate 05 ➔ Grayline 2 (GL2) Yard Peliyagoda',
          currentLocation: 'Peliyagoda New Kelani Bridge Corridor',
          destination: 'Grayline 2 (GL2) Examination Yard',
          estimatedArrival: '12 Sep 2026 , 11.50 AM',
          driverName: 'H.K. Samarasinghe',
          sealStatus: 'Intact',
          sealId: 'ESEAL-SL-90829',
          batteryLevel: 76,
          temperature: 27.2,
          latitude: 6.9590,
          longitude: 79.8750,
          speed: 32,
          status: 'On Track',
          containerColor: Color(0xFFD97706),
          assetImage: 'assets/images/cont_brown.png',
        ),
      ];
}

/// Alert notification item model
class AlertItem {
  final String id;
  final String title;
  final String containerId;
  final String ownerEmail;
  final String timestamp;
  final String category; // 'Security', 'Location', 'Battery'
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String description;
  final String severity; // 'critical', 'warning', 'info'
  final bool isRead;
  final String? isoContainerNo;
  final String? location;

  const AlertItem({
    required this.id,
    required this.title,
    required this.containerId,
    this.ownerEmail = 'owner@cargooverseas.lk',
    required this.timestamp,
    required this.category,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    this.description = '',
    this.severity = 'info',
    this.isRead = true,
    this.isoContainerNo,
    this.location,
  });

  /// Automatically generate contextual Sri Lanka Customs alerts from active containers
  static List<AlertItem> generateFromContainers(List<ContainerModel> containers) {
    final List<AlertItem> list = [];
    for (final c in containers) {
      final isTampered = c.sealStatus.trim().toLowerCase() == 'tampered';
      final isLowBattery = c.batteryLevel < 50;
      final isArrived = c.status.trim().toLowerCase() == 'arrived';
      final isDeviated = c.status.trim().toLowerCase() == 'deviated';

      // 1. Seal Tamper Alert (Security - Critical)
      if (isTampered) {
        list.add(
          AlertItem(
            id: 'ALT-TMP-${c.id}',
            title: 'e-Seal Tamper Detected!',
            containerId: c.id,
            ownerEmail: c.ownerEmail,
            timestamp: 'Just now',
            category: 'Security',
            icon: Icons.gpp_maybe_rounded,
            iconColor: const Color(0xFFDC2626),
            bgColor: const Color(0xFFFEE2E2),
            description: 'Critical electronic seal breach detected on container ${c.isoContainerNo}. Sri Lanka Customs ECTS intervention required.',
            severity: 'critical',
            isRead: false,
            isoContainerNo: c.isoContainerNo,
            location: c.currentLocation,
          ),
        );
      } else {
        list.add(
          AlertItem(
            id: 'ALT-SEC-${c.id}',
            title: 'e-Seal Loop Verified Intact',
            containerId: c.id,
            ownerEmail: c.ownerEmail,
            timestamp: 'Today, 07:15 AM',
            category: 'Security',
            icon: Icons.lock_outline_rounded,
            iconColor: const Color(0xFF16A34A),
            bgColor: const Color(0xFFDCFCE7),
            description: 'Optical fiber wire loop and electronic lock telemetry status intact (Seal: ${c.sealId}).',
            severity: 'info',
            isRead: true,
            isoContainerNo: c.isoContainerNo,
            location: c.currentLocation,
          ),
        );
      }

      // 2. Battery Alert (< 50% per SRS, < 25% critical)
      if (isLowBattery) {
        final isCritical = c.batteryLevel < 25;
        list.add(
          AlertItem(
            id: 'ALT-BAT-${c.id}',
            title: isCritical ? 'Critical Low Battery (${c.batteryLevel}%)' : 'e-Seal Low Battery Warning (${c.batteryLevel}%)',
            containerId: c.id,
            ownerEmail: c.ownerEmail,
            timestamp: '15 mins ago',
            category: 'Battery',
            icon: Icons.battery_alert_rounded,
            iconColor: isCritical ? const Color(0xFFDC2626) : const Color(0xFFD97706),
            bgColor: isCritical ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7),
            description: 'IoT tracking unit battery is at ${c.batteryLevel}%. Please ensure recharge before next corridor transit checkpoint (SRS 4.1.2).',
            severity: isCritical ? 'critical' : 'warning',
            isRead: false,
            isoContainerNo: c.isoContainerNo,
            location: c.currentLocation,
          ),
        );
      } else {
        list.add(
          AlertItem(
            id: 'ALT-BAT-OK-${c.id}',
            title: 'e-Seal Battery Normal (${c.batteryLevel}%)',
            containerId: c.id,
            ownerEmail: c.ownerEmail,
            timestamp: 'Today, 08:30 AM',
            category: 'Battery',
            icon: Icons.battery_charging_full_rounded,
            iconColor: const Color(0xFF16A34A),
            bgColor: const Color(0xFFDCFCE7),
            description: 'IoT battery level optimal at ${c.batteryLevel}% for active corridor movement.',
            severity: 'info',
            isRead: true,
            isoContainerNo: c.isoContainerNo,
            location: c.currentLocation,
          ),
        );
      }

      // 3. Location / Transit Alert
      if (isDeviated) {
        list.add(
          AlertItem(
            id: 'ALT-DEV-${c.id}',
            title: 'Route Deviation Alert (>400m)',
            containerId: c.id,
            ownerEmail: c.ownerEmail,
            timestamp: '25 mins ago',
            category: 'Location',
            icon: Icons.wrong_location_rounded,
            iconColor: const Color(0xFFDC2626),
            bgColor: const Color(0xFFFEE2E2),
            description: 'Container diverted outside Sri Lanka Customs designated transit corridor.',
            severity: 'critical',
            isRead: false,
            isoContainerNo: c.isoContainerNo,
            location: c.currentLocation,
          ),
        );
      } else if (isArrived) {
        list.add(
          AlertItem(
            id: 'ALT-ARR-${c.id}',
            title: 'Yard Arrival Confirmed',
            containerId: c.id,
            ownerEmail: c.ownerEmail,
            timestamp: 'Today, 02:15 PM',
            category: 'Location',
            icon: Icons.check_circle_rounded,
            iconColor: const Color(0xFF16A34A),
            bgColor: const Color(0xFFDCFCE7),
            description: 'Container has reached destination yard: ${c.destination}. Final gate scan completed.',
            severity: 'info',
            isRead: true,
            isoContainerNo: c.isoContainerNo,
            location: c.destination,
          ),
        );
      } else {
        list.add(
          AlertItem(
            id: 'ALT-LOC-${c.id}',
            title: 'Corridor Transit Milestone',
            containerId: c.id,
            ownerEmail: c.ownerEmail,
            timestamp: 'Today, 07:38 AM',
            category: 'Location',
            icon: Icons.location_on_rounded,
            iconColor: const Color(0xFF0284C7),
            bgColor: const Color(0xFFE0F2FE),
            description: 'Container in transit at ${c.currentLocation} at speed ${c.speed} km/h.',
            severity: 'info',
            isRead: true,
            isoContainerNo: c.isoContainerNo,
            location: c.currentLocation,
          ),
        );
      }
    }
    return list;
  }

  static List<AlertItem> get sampleAlerts => const [
        // --- Cargo Overseas Freight Pvt Ltd ---
        AlertItem(
          id: 'ALT-001',
          title: 'Low Battery Warning (20%)',
          containerId: 'CONT-002',
          isoContainerNo: 'MSKU 892019 1',
          ownerEmail: 'owner@cargooverseas.lk',
          timestamp: 'Today, 08:30 AM',
          category: 'Battery',
          icon: Icons.battery_alert_rounded,
          iconColor: Color(0xFFD97706),
          bgColor: Color(0xFFFEF3C7),
          description: 'e-Seal battery dropped to 20% on Colombo Port Gate 05 ➔ Grayline 2 corridor (SRS Req 4.1.2).',
          severity: 'critical',
          isRead: false,
          location: 'Colombo Port Gate 05 Corridor',
        ),
        AlertItem(
          id: 'ALT-002',
          title: 'Ingurukade RFID Gate Scanned',
          containerId: 'CONT-001',
          isoContainerNo: 'HLCU 902184 5',
          ownerEmail: 'owner@cargooverseas.lk',
          timestamp: 'Today, 07:38 AM',
          category: 'Location',
          icon: Icons.location_on_rounded,
          iconColor: Color(0xFF0284C7),
          bgColor: Color(0xFFE0F2FE),
          description: 'Automated RFID gateway confirmed valid corridor entry pass.',
          severity: 'info',
          isRead: true,
          location: 'Ingurukade RFID Gate 02',
        ),
        AlertItem(
          id: 'ALT-003',
          title: 'Final Yard Arrival Confirmed',
          containerId: 'CONT-003',
          isoContainerNo: 'HLCU 982019 5',
          ownerEmail: 'owner@cargooverseas.lk',
          timestamp: 'Today, 02:15 PM',
          category: 'Location',
          icon: Icons.check_circle_rounded,
          iconColor: Color(0xFF16A34A),
          bgColor: Color(0xFFDCFCE7),
          description: 'Customs Grayline 2 Yard gate clearance and discharge completed.',
          severity: 'info',
          isRead: true,
          location: 'Grayline 2 (GL2) Examination Yard',
        ),
        AlertItem(
          id: 'ALT-004',
          title: 'Electronic Seal (e-Seal) Health Normal',
          containerId: 'CONT-001',
          isoContainerNo: 'HLCU 902184 5',
          ownerEmail: 'owner@cargooverseas.lk',
          timestamp: 'Today, 07:15 AM',
          category: 'Security',
          icon: Icons.lock_outline_rounded,
          iconColor: Color(0xFF16A34A),
          bgColor: Color(0xFFDCFCE7),
          description: 'Optical wire loop and tamper sensors verified active and secure.',
          severity: 'info',
          isRead: true,
          location: 'Colombo Port Gate 04',
        ),
        AlertItem(
          id: 'ALT-012',
          title: 'Corridor Route Deviation Warning',
          containerId: 'CONT-001',
          isoContainerNo: 'HLCU 902184 5',
          ownerEmail: 'owner@cargooverseas.lk',
          timestamp: 'Today, 09:10 AM',
          category: 'Location',
          icon: Icons.alt_route_rounded,
          iconColor: Color(0xFFD97706),
          bgColor: Color(0xFFFEF3C7),
          description: 'Vehicle speed reduced below threshold near Prince of Wales Avenue.',
          severity: 'warning',
          isRead: false,
          location: 'Prince of Wales Avenue',
        ),
        // --- Ceylon Global Freight & Logistics Ltd ---
        AlertItem(
          id: 'ALT-005',
          title: 'Cold-Chain Temperature Normal (4.2°C)',
          containerId: 'CONT-004',
          isoContainerNo: 'MEDU 839201 9',
          ownerEmail: 'kasun.fernando@ceylonlogistics.lk',
          timestamp: 'Today, 09:15 AM',
          category: 'Security',
          icon: Icons.lock_outline_rounded,
          iconColor: Color(0xFF16A34A),
          bgColor: Color(0xFFDCFCE7),
          description: 'Reefer pharmaceutical container maintaining optimal temperature setpoint.',
          severity: 'info',
          isRead: true,
          location: 'Ingurukade Junction Corridor',
        ),
        AlertItem(
          id: 'ALT-006',
          title: 'Sugathadasa RFID Checkpoint Passed',
          containerId: 'CONT-006',
          isoContainerNo: 'TGHU 928104 1',
          ownerEmail: 'kasun.fernando@ceylonlogistics.lk',
          timestamp: 'Today, 09:40 AM',
          category: 'Location',
          icon: Icons.location_on_rounded,
          iconColor: Color(0xFF0284C7),
          bgColor: Color(0xFFE0F2FE),
          description: 'Transit corridor checkpoint passed with intact electronic seal telemetry.',
          severity: 'info',
          isRead: true,
          location: 'Sugathadasa / Prince of Wales Ave',
        ),
        AlertItem(
          id: 'ALT-007',
          title: 'GL1 Yard Final Gate Check Passed',
          containerId: 'CONT-007',
          isoContainerNo: 'MSKU 102948 3',
          ownerEmail: 'kasun.fernando@ceylonlogistics.lk',
          timestamp: 'Today, 08:20 AM',
          category: 'Location',
          icon: Icons.check_circle_rounded,
          iconColor: Color(0xFF16A34A),
          bgColor: Color(0xFFDCFCE7),
          description: 'Container arrived at Grayline 1 (GL1) examination terminal.',
          severity: 'info',
          isRead: true,
          location: 'Grayline 1 (GL1) Yard Grandpass',
        ),
        AlertItem(
          id: 'ALT-011',
          title: 'e-Seal Battery Optimal (95%)',
          containerId: 'CONT-006',
          isoContainerNo: 'TGHU 928104 1',
          ownerEmail: 'kasun.fernando@ceylonlogistics.lk',
          timestamp: 'Today, 08:35 AM',
          category: 'Battery',
          icon: Icons.battery_charging_full_rounded,
          iconColor: Color(0xFF16A34A),
          bgColor: Color(0xFFDCFCE7),
          description: 'e-Seal battery capacity optimal for extended corridor transit.',
          severity: 'info',
          isRead: true,
          location: 'Colombo Port Gate 05',
        ),
        // --- Lanka Maritime Forwarders Pvt Ltd ---
        AlertItem(
          id: 'ALT-008',
          title: 'e-Seal Optical Wire Loop Verified',
          containerId: 'CONT-005',
          isoContainerNo: 'ONEU 392019 4',
          ownerEmail: 'anura.wijesinghe@lankaforwarding.lk',
          timestamp: 'Today, 10:35 AM',
          category: 'Security',
          icon: Icons.lock_outline_rounded,
          iconColor: Color(0xFF16A34A),
          bgColor: Color(0xFFDCFCE7),
          description: 'Optical fiber wire loop and electronic lock telemetry status intact.',
          severity: 'info',
          isRead: true,
          location: 'Kochchikade Terminal Gate',
        ),
        AlertItem(
          id: 'ALT-009',
          title: 'Orugodawatta RCT Transit In Progress',
          containerId: 'CONT-008',
          isoContainerNo: 'CLLU 782019 0',
          ownerEmail: 'anura.wijesinghe@lankaforwarding.lk',
          timestamp: 'Today, 10:10 AM',
          category: 'Location',
          icon: Icons.alt_route_rounded,
          iconColor: Color(0xFF0284C7),
          bgColor: Color(0xFFE0F2FE),
          description: 'In-transit tracking on Colombo Port Gate 04 corridor.',
          severity: 'info',
          isRead: true,
          location: 'Ingurukade Junction Terminal',
        ),
        AlertItem(
          id: 'ALT-010',
          title: 'IoT Battery Warning (18%)',
          containerId: 'CONT-009',
          isoContainerNo: 'TEMU 640192 8',
          ownerEmail: 'anura.wijesinghe@lankaforwarding.lk',
          timestamp: 'Today, 10:05 AM',
          category: 'Battery',
          icon: Icons.battery_alert_rounded,
          iconColor: Color(0xFFD97706),
          bgColor: Color(0xFFFEF3C7),
          description: 'Battery dropped below 20%. Sri Lanka Customs low battery warning logged.',
          severity: 'warning',
          isRead: false,
          location: 'Peliyagoda New Kelani Bridge',
        ),
      ];
}

/// User details model
class UserModel {
  final String name;
  final String email;
  final String phone;
  final String role; // 'Owner', 'Driver'
  final String company;
  final String companyId;

  const UserModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.company = 'Cargo Overseas Freight Pvt Ltd',
    this.companyId = 'COMP-COF-2024',
  });

  static const UserModel defaultOwner = UserModel(
    name: 'Tharindu Perera',
    email: 'owner@cargooverseas.lk',
    phone: '+94 77 123 4567',
    role: 'Owner',
    company: 'Cargo Overseas Freight Pvt Ltd',
    companyId: 'COMP-COF-2024',
  );
}

/// Driver Trip details model (SRS Pages 11 & 12)
class DriverTripModel {
  final String tripId;
  final String containerId;
  final String status; // 'On Route', 'Deviated', 'Completed'
  final String startLocation;
  final String startTime;
  final String destination;
  final String expectedTime;
  final String distanceLeft;
  final String eta;
  final double progressPercent;
  final String sealStatus;
  final String weight;
  final String containerType;
  final String nextTurnDistance;
  final String nextTurnInstruction;
  final String totalTrips;
  final String onTimeRate;
  final String totalDistance;
  final bool isDeviated;
  final bool isEmergencyActive;

  const DriverTripModel({
    required this.tripId,
    required this.containerId,
    required this.status,
    required this.startLocation,
    required this.startTime,
    required this.destination,
    required this.expectedTime,
    required this.distanceLeft,
    required this.eta,
    required this.progressPercent,
    required this.sealStatus,
    required this.weight,
    required this.containerType,
    required this.nextTurnDistance,
    required this.nextTurnInstruction,
    this.totalTrips = '24',
    this.onTimeRate = '98%',
    this.totalDistance = '3.2k km',
    this.isDeviated = false,
    this.isEmergencyActive = false,
  });

  static const DriverTripModel sampleTrip = DriverTripModel(
    tripId: 'TRP-8473',
    containerId: 'CTR-2024-8473',
    status: 'On Route',
    startLocation: 'Katunayake Export Processing Zone',
    startTime: 'Today at 6:00 AM',
    destination: 'Port of Colombo',
    expectedTime: 'Today at 11:30 AM',
    distanceLeft: '142 km',
    eta: '2h 30m',
    progressPercent: 0.60,
    sealStatus: 'Closed',
    weight: '18,500 kg',
    containerType: '40ft HC',
    nextTurnDistance: 'In 2.3 km',
    nextTurnInstruction: 'Turn right onto A1 Highway',
  );
}

/// Customs Inspector Log & Audit Record (SRS Pages 9, 20-23)
class InspectionLogModel {
  final String id;
  final String containerId;
  final String action;
  final String inspectorName;
  final String timestamp;
  final String status;
  final String sealTag;
  final int batteryLevel;

  const InspectionLogModel({
    required this.id,
    required this.containerId,
    required this.action,
    required this.inspectorName,
    required this.timestamp,
    required this.status,
    required this.sealTag,
    required this.batteryLevel,
  });

  static List<InspectionLogModel> get sampleLogs => const [
        InspectionLogModel(
          id: 'INSP-101',
          containerId: 'CONT-001',
          action: 'Smart Seal Locked & Initialized (UC-01)',
          inspectorName: 'Officer K. Silva',
          timestamp: '12 Sep 2026, 08:30 AM',
          status: 'Active & Locked',
          sealTag: 'TAG-ESP32-8473',
          batteryLevel: 98,
        ),
        InspectionLogModel(
          id: 'INSP-102',
          containerId: 'CONT-003',
          action: 'Destination Arrival & Seal Unlocked (UC-03)',
          inspectorName: 'Officer K. Silva',
          timestamp: '10 Sep 2026, 02:15 PM',
          status: 'Completed & Unlocked',
          sealTag: 'TAG-ESP32-1120',
          batteryLevel: 91,
        ),
        InspectionLogModel(
          id: 'INSP-103',
          containerId: 'CONT-002',
          action: 'Low Battery & Sensor Check',
          inspectorName: 'Officer K. Silva',
          timestamp: '09 Sep 2026, 06:20 PM',
          status: 'Warning Logged',
          sealTag: 'TAG-ESP32-6721',
          batteryLevel: 20,
        ),
      ];
}

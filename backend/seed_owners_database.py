#!/usr/bin/env python3
"""
SecureTrack SL: Production-Grade Container Owners & Freight Consignees Database
Project ID: track-sl
Ecosystem: Sri Lanka Customs - Container Owner Monitoring Framework
"""
import urllib.request
import json
import ssl
import sys

PROJECT_ID = "track-sl"
BASE_URL = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents"

# 1. CONTAINER OWNERS & LOGISTICS IMPORTERS (Multiple Real Sri Lankan Consignees)
owners_users_data = [
    {
        "doc_id": "owner@cargooverseas.lk",
        "name": "Tharindu Perera",
        "email": "owner@cargooverseas.lk",
        "phone": "+94 77 123 4567",
        "role": "Container Owner",
        "company": "Cargo Overseas Freight Pvt Ltd",
        "companyRegistrationNo": "PV-84920",
        "tinNumber": "TIN-104928190",
        "customsImporterCode": "SLC-IMP-40918",
        "address": "No. 45, World Trade Center, Echelon Square, Colombo 01",
        "totalContainers": 14,
        "activeContainers": 3,
        "deliveredContainers": 11,
        "accountTier": "Tier 1 Verified Importer",
        "status": "Active"
    },
    {
        "doc_id": "kasun.fernando@ceylonlogistics.lk",
        "name": "Kasun Fernando",
        "email": "kasun.fernando@ceylonlogistics.lk",
        "phone": "+94 71 892 3451",
        "role": "Container Owner",
        "company": "Ceylon Global Freight & Logistics Ltd",
        "companyRegistrationNo": "PV-67204",
        "tinNumber": "TIN-209481729",
        "customsImporterCode": "SLC-IMP-38912",
        "address": "Level 12, West Tower, World Trade Center, Colombo 01",
        "totalContainers": 28,
        "activeContainers": 5,
        "deliveredContainers": 23,
        "accountTier": "Tier 1 Verified Importer",
        "status": "Active"
    },
    {
        "doc_id": "anura.wijesinghe@lankaforwarding.lk",
        "name": "Anura Wijesinghe",
        "email": "anura.wijesinghe@lankaforwarding.lk",
        "phone": "+94 77 345 6789",
        "role": "Container Owner",
        "company": "Lanka Maritime Forwarders Pvt Ltd",
        "companyRegistrationNo": "PV-58291",
        "tinNumber": "TIN-301928471",
        "customsImporterCode": "SLC-IMP-29481",
        "address": "No. 182, Vauxhall Street, Colombo 02",
        "totalContainers": 19,
        "activeContainers": 2,
        "deliveredContainers": 17,
        "accountTier": "Authorized Economic Operator (AEO)",
        "status": "Active"
    },
    {
        "doc_id": "dilani.senanayake@islandfreight.lk",
        "name": "Dilani Senanayake",
        "email": "dilani.senanayake@islandfreight.lk",
        "phone": "+94 76 543 2198",
        "role": "Container Owner",
        "company": "Island Express Cargo Solutions",
        "companyRegistrationNo": "PV-91028",
        "tinNumber": "TIN-409182736",
        "customsImporterCode": "SLC-IMP-50192",
        "address": "No. 64, D.R. Wijewardena Mawatha, Colombo 10",
        "totalContainers": 12,
        "activeContainers": 2,
        "deliveredContainers": 10,
        "accountTier": "Tier 1 Verified Importer",
        "status": "Active"
    },
    {
        "doc_id": "rohan.de.silva@transocean.lk",
        "name": "Rohan De Silva",
        "email": "rohan.de.silva@transocean.lk",
        "phone": "+94 72 456 1234",
        "role": "Container Owner",
        "company": "Transoceanic Shipping & Logistics Pvt Ltd",
        "companyRegistrationNo": "PV-44912",
        "tinNumber": "TIN-502918374",
        "customsImporterCode": "SLC-IMP-19402",
        "address": "No. 235, George R. De Silva Mawatha, Colombo 13",
        "totalContainers": 45,
        "activeContainers": 6,
        "deliveredContainers": 39,
        "accountTier": "Authorized Economic Operator (AEO)",
        "status": "Active"
    }
]

# 2. RICH CONTAINERS DATASET (Full Sri Lanka Customs Examination Corridors)
containers_data = [
    {
        "doc_id": "CONT-001",
        "id": "CONT-001",
        "isoContainerNo": "MSCU 782910 4",
        "containerType": "40ft High Cube (40HC)",
        "owner": "Cargo Overseas Freight Pvt Ltd",
        "ownerEmail": "owner@cargooverseas.lk",
        "billOfLading": "MSCU-COL-892104",
        "declarationNo": "CUSDEC-2026-COL-049182",
        "customsEntryNo": "CE-2026-90412",
        "vesselName": "MSC ALTAIR V-264E",
        "origin": "Colombo Port Gate 04",
        "destination": "Orugodawatta Customs Yard (RCT)",
        "route": "Colombo Port Gate 04 ➔ Orugodawatta Customs Yard (RCT)",
        "currentLocation": "Peliyagoda / Baseline Corridor",
        "cargoDescription": "Automotive Spare Parts & Heavy Machinery Components",
        "grossWeightKg": 24500,
        "declaredValueLKR": "LKR 48,500,000",
        "customsDutyStatus": "Paid / Release Order Issued",
        "departureTime": "07:15 AM",
        "estimatedArrival": "10:30 AM",
        "driverName": "S.A. Gamage",
        "driverPhone": "+94 77 987 6543",
        "vehicleNo": "WP LY-4829 (Prime Mover)",
        "sealId": "ESEAL-SL-90821",
        "sealStatus": "Secure",
        "sealBattery": 94,
        "batteryLevel": 75,
        "temperature": 28.4,
        "humidity": 65,
        "status": "On Track",
        "latitude": 6.9455,
        "longitude": 79.8510,
        "speed": 42
    },
    {
        "doc_id": "CONT-002",
        "id": "CONT-002",
        "isoContainerNo": "CMAU 492018 2",
        "containerType": "20ft Standard Dry (20GP)",
        "owner": "Cargo Overseas Freight Pvt Ltd",
        "ownerEmail": "owner@cargooverseas.lk",
        "billOfLading": "CMAU-COL-391084",
        "declarationNo": "CUSDEC-2026-COL-051839",
        "customsEntryNo": "CE-2026-91823",
        "vesselName": "CMA CGM COLOMBO V-102N",
        "origin": "Colombo Port Gate 02",
        "destination": "Grayline 1 (GL1) Yard Grandpass",
        "route": "Colombo Port Gate 02 ➔ Grayline 1 (GL1) Yard Grandpass",
        "currentLocation": "Prince of Wales Avenue Corridor",
        "cargoDescription": "Industrial Electrical Panels & Switchgear Units",
        "grossWeightKg": 16200,
        "declaredValueLKR": "LKR 32,800,000",
        "customsDutyStatus": "Under Assessment",
        "departureTime": "08:00 AM",
        "estimatedArrival": "11:15 AM",
        "driverName": "K.D. Kumara",
        "driverPhone": "+94 71 456 7890",
        "vehicleNo": "WP LY-5912 (Prime Mover)",
        "sealId": "ESEAL-SL-90822",
        "sealStatus": "Secure",
        "sealBattery": 88,
        "batteryLevel": 20,
        "temperature": 29.1,
        "humidity": 62,
        "status": "On Track",
        "latitude": 6.9410,
        "longitude": 79.8525,
        "speed": 35
    },
    {
        "doc_id": "CONT-003",
        "id": "CONT-003",
        "isoContainerNo": "HLCU 982019 5",
        "containerType": "40ft High Cube (40HC)",
        "owner": "Cargo Overseas Freight Pvt Ltd",
        "ownerEmail": "owner@cargooverseas.lk",
        "billOfLading": "HLCU-COL-992105",
        "declarationNo": "CUSDEC-2026-COL-038291",
        "customsEntryNo": "CE-2026-88210",
        "vesselName": "HAPAG LLOYD EXPRESS V-509",
        "origin": "Colombo Port Gate 05",
        "destination": "Grayline 2 (GL2) Yard Peliyagoda",
        "route": "Colombo Port Gate 05 ➔ Grayline 2 (GL2) Yard Peliyagoda",
        "currentLocation": "Grayline 2 (GL2) Cargo Terminal",
        "cargoDescription": "Garment Accessories & Textile Raw Fabrics",
        "grossWeightKg": 21800,
        "declaredValueLKR": "LKR 64,200,000",
        "customsDutyStatus": "Cleared / Unloaded",
        "departureTime": "01:15 PM",
        "estimatedArrival": "02:30 PM",
        "driverName": "R.M. Perera",
        "driverPhone": "+94 76 890 1234",
        "vehicleNo": "WP LZ-1082 (Prime Mover)",
        "sealId": "ESEAL-SL-90823",
        "sealStatus": "Secure",
        "sealBattery": 96,
        "batteryLevel": 92,
        "temperature": 27.5,
        "humidity": 68,
        "status": "Arrived",
        "latitude": 6.9580,
        "longitude": 79.8650,
        "speed": 0
    },
    {
        "doc_id": "CONT-004",
        "id": "CONT-004",
        "isoContainerNo": "MEDU 839201 9",
        "containerType": "40ft Reefer Temperature-Controlled",
        "owner": "Ceylon Global Freight & Logistics Ltd",
        "ownerEmail": "kasun.fernando@ceylonlogistics.lk",
        "billOfLading": "MEDU-COL-409182",
        "declarationNo": "CUSDEC-2026-COL-071829",
        "customsEntryNo": "CE-2026-94018",
        "vesselName": "MAERSK COLOMBO V-88",
        "origin": "Colombo Port Gate 04",
        "destination": "Orugodawatta Customs Yard (RCT)",
        "route": "Colombo Port Gate 04 ➔ Orugodawatta RCT",
        "currentLocation": "Ingurukade Junction Corridor",
        "cargoDescription": "Pharmaceutical Goods & Medical Supplies (Cold Chain)",
        "grossWeightKg": 18400,
        "declaredValueLKR": "LKR 112,000,000",
        "customsDutyStatus": "Priority Fast Track",
        "departureTime": "09:00 AM",
        "estimatedArrival": "11:45 AM",
        "driverName": "M.T. Bandara",
        "driverPhone": "+94 71 333 4444",
        "vehicleNo": "WP LY-8901",
        "sealId": "ESEAL-SL-90824",
        "sealStatus": "Secure",
        "sealBattery": 98,
        "batteryLevel": 88,
        "temperature": 4.2,
        "humidity": 45,
        "status": "On Track",
        "latitude": 6.9420,
        "longitude": 79.8580,
        "speed": 38
    },
    {
        "doc_id": "CONT-005",
        "id": "CONT-005",
        "isoContainerNo": "ONEU 392019 4",
        "containerType": "20ft Standard Dry (20GP)",
        "owner": "Lanka Maritime Forwarders Pvt Ltd",
        "ownerEmail": "anura.wijesinghe@lankaforwarding.lk",
        "billOfLading": "ONEU-COL-551029",
        "declarationNo": "CUSDEC-2026-COL-062910",
        "customsEntryNo": "CE-2026-92109",
        "vesselName": "ONE HARBOUR V-33E",
        "origin": "Colombo Port Gate 02",
        "destination": "Grayline 1 (GL1) Yard Grandpass",
        "route": "Colombo Port Gate 02 ➔ Grayline 1 GL1",
        "currentLocation": "Kochchikade Terminal Gate",
        "cargoDescription": "Chemical Reagents & Industrial Resins",
        "grossWeightKg": 19200,
        "declaredValueLKR": "LKR 28,400,000",
        "customsDutyStatus": "Duty Paid",
        "departureTime": "10:30 AM",
        "estimatedArrival": "12:00 PM",
        "driverName": "N.H. Rathnayake",
        "driverPhone": "+94 77 444 5555",
        "vehicleNo": "WP LY-7721",
        "sealId": "ESEAL-SL-90825",
        "sealStatus": "Secure",
        "sealBattery": 91,
        "batteryLevel": 85,
        "temperature": 28.0,
        "humidity": 60,
        "status": "On Track",
        "latitude": 6.9470,
        "longitude": 79.8620,
        "speed": 30
    },
    {
        "doc_id": "CONT-006",
        "id": "CONT-006",
        "isoContainerNo": "TGHU 928104 1",
        "containerType": "20ft Standard Dry (20GP)",
        "owner": "Ceylon Global Freight & Logistics Ltd",
        "ownerEmail": "kasun.fernando@ceylonlogistics.lk",
        "billOfLading": "TGHU-COL-772910",
        "declarationNo": "CUSDEC-2026-COL-083912",
        "customsEntryNo": "CE-2026-95182",
        "vesselName": "EVER GIVEN V-114W",
        "origin": "Colombo Port Gate 05",
        "destination": "Grayline 2 (GL2) Examination Yard",
        "route": "Colombo Port Gate 05 ➔ Grayline 2 (GL2) Yard Peliyagoda",
        "currentLocation": "Sugathadasa / Prince of Wales Ave Corridor",
        "cargoDescription": "High-Grade Ceylon Tea Machinery & Packaging Equipment",
        "grossWeightKg": 15800,
        "declaredValueLKR": "LKR 42,000,000",
        "customsDutyStatus": "Under Assessment",
        "departureTime": "08:30 AM",
        "estimatedArrival": "10:45 AM",
        "driverName": "K.A. Jayalath",
        "driverPhone": "+94 71 888 9999",
        "vehicleNo": "WP LY-3342",
        "sealId": "ESEAL-SL-90826",
        "sealStatus": "Secure",
        "sealBattery": 95,
        "batteryLevel": 95,
        "temperature": 27.8,
        "humidity": 63,
        "status": "On Track",
        "latitude": 6.9540,
        "longitude": 79.8690,
        "speed": 36
    },
    {
        "doc_id": "CONT-007",
        "id": "CONT-007",
        "isoContainerNo": "MSKU 102948 3",
        "containerType": "40ft High Cube (40HC)",
        "owner": "Ceylon Global Freight & Logistics Ltd",
        "ownerEmail": "kasun.fernando@ceylonlogistics.lk",
        "billOfLading": "MSKU-COL-301948",
        "declarationNo": "CUSDEC-2026-COL-091820",
        "customsEntryNo": "CE-2026-96014",
        "vesselName": "MAERSK MC-KINNEY V-90",
        "origin": "Colombo Port Gate 02",
        "destination": "Grayline 1 (GL1) Examination Yard",
        "route": "Colombo Port Gate 02 ➔ Grayline 1 (GL1) Yard Grandpass",
        "currentLocation": "Grayline 1 (GL1) Yard Grandpass",
        "cargoDescription": "Apparel Fabrics & High-Value Electronic Components",
        "grossWeightKg": 22400,
        "declaredValueLKR": "LKR 75,500,000",
        "customsDutyStatus": "Cleared / Unloaded",
        "departureTime": "06:00 AM",
        "estimatedArrival": "08:15 AM",
        "driverName": "P.B. Senaratne",
        "driverPhone": "+94 77 222 3333",
        "vehicleNo": "WP LZ-4451",
        "sealId": "ESEAL-SL-90827",
        "sealStatus": "Secure",
        "sealBattery": 82,
        "batteryLevel": 82,
        "temperature": 28.1,
        "humidity": 59,
        "status": "Arrived",
        "latitude": 6.9525,
        "longitude": 79.8730,
        "speed": 0
    },
    {
        "doc_id": "CONT-008",
        "id": "CONT-008",
        "isoContainerNo": "CLLU 782019 0",
        "containerType": "40ft High Cube (40HC)",
        "owner": "Lanka Maritime Forwarders Pvt Ltd",
        "ownerEmail": "anura.wijesinghe@lankaforwarding.lk",
        "billOfLading": "CLLU-COL-662910",
        "declarationNo": "CUSDEC-2026-COL-044912",
        "customsEntryNo": "CE-2026-97819",
        "vesselName": "COSCO ASIA V-402E",
        "origin": "Colombo Port Gate 04",
        "destination": "Orugodawatta Customs Yard (RCT)",
        "route": "Colombo Port Gate 04 ➔ Orugodawatta Customs Yard (RCT)",
        "currentLocation": "Ingurukade Junction Terminal",
        "cargoDescription": "Industrial Steel Beams & Construction Fasteners",
        "grossWeightKg": 26800,
        "declaredValueLKR": "LKR 51,200,000",
        "customsDutyStatus": "Release Order Issued",
        "departureTime": "09:15 AM",
        "estimatedArrival": "11:30 AM",
        "driverName": "W.M. Dharmadasa",
        "driverPhone": "+94 76 111 2233",
        "vehicleNo": "WP LY-9921",
        "sealId": "ESEAL-SL-90828",
        "sealStatus": "Secure",
        "sealBattery": 91,
        "batteryLevel": 91,
        "temperature": 29.0,
        "humidity": 65,
        "status": "On Track",
        "latitude": 6.9460,
        "longitude": 79.8650,
        "speed": 40
    },
    {
        "doc_id": "CONT-009",
        "id": "CONT-009",
        "isoContainerNo": "TEMU 640192 8",
        "containerType": "40ft High Cube (40HC)",
        "owner": "Lanka Maritime Forwarders Pvt Ltd",
        "ownerEmail": "anura.wijesinghe@lankaforwarding.lk",
        "billOfLading": "TEMU-COL-189204",
        "declarationNo": "CUSDEC-2026-COL-058913",
        "customsEntryNo": "CE-2026-98124",
        "vesselName": "YANG MING EXPRESS V-22",
        "origin": "Colombo Port Gate 05",
        "destination": "Grayline 2 (GL2) Examination Yard",
        "route": "Colombo Port Gate 05 ➔ Grayline 2 (GL2) Yard Peliyagoda",
        "currentLocation": "Peliyagoda New Kelani Bridge Corridor",
        "cargoDescription": "Solar Inverters & Lithium Battery Energy Storage Systems",
        "grossWeightKg": 20100,
        "declaredValueLKR": "LKR 89,000,000",
        "customsDutyStatus": "Duty Paid",
        "departureTime": "10:00 AM",
        "estimatedArrival": "11:50 AM",
        "driverName": "H.K. Samarasinghe",
        "driverPhone": "+94 72 333 8888",
        "vehicleNo": "WP LZ-5519",
        "sealId": "ESEAL-SL-90829",
        "sealStatus": "Secure",
        "sealBattery": 76,
        "batteryLevel": 76,
        "temperature": 27.2,
        "humidity": 58,
        "status": "On Track",
        "latitude": 6.9590,
        "longitude": 79.8750,
        "speed": 32
    }
]

# 3. COMPREHENSIVE OWNER-SPECIFIC ALERTS & AUDIT TRAIL
alerts_data = [
    # --- Cargo Overseas Freight Pvt Ltd (owner@cargooverseas.lk) ---
    {
        "doc_id": "ALT-001",
        "id": "ALT-001",
        "containerId": "CONT-002",
        "ownerEmail": "owner@cargooverseas.lk",
        "title": "Low Battery Warning (20%)",
        "message": "IoT Tracker battery on CONT-002 (CMAU 492018 2) dropped to 20%. Device recharging recommended upon arrival at Grayline 1 Yard.",
        "category": "Battery",
        "severity": "Warning",
        "timestamp": "Today, 08:30 AM",
        "isRead": False
    },
    {
        "doc_id": "ALT-002",
        "id": "ALT-002",
        "containerId": "CONT-001",
        "ownerEmail": "owner@cargooverseas.lk",
        "title": "Ingurukade RFID Gate Scanned",
        "message": "Container CONT-001 verified by Sri Lanka Customs RFID scanner at Ingurukade Junction Terminal corridor. Route progression on schedule.",
        "category": "Location",
        "severity": "Info",
        "timestamp": "Today, 07:38 AM",
        "isRead": True
    },
    {
        "doc_id": "ALT-003",
        "id": "ALT-003",
        "containerId": "CONT-003",
        "ownerEmail": "owner@cargooverseas.lk",
        "title": "Final Yard Arrival Confirmed",
        "message": "Container CONT-003 safely arrived at Grayline 2 (GL2) Peliyagoda. Cargo unlocked and destuffed under Customs inspection supervision.",
        "category": "Location",
        "severity": "Success",
        "timestamp": "Today, 02:15 PM",
        "isRead": True
    },
    {
        "doc_id": "ALT-004",
        "id": "ALT-004",
        "containerId": "CONT-001",
        "ownerEmail": "owner@cargooverseas.lk",
        "title": "Electronic Seal (e-Seal) Health Normal",
        "message": "e-Seal ESEAL-SL-90821 integrity diagnostic passed. Anti-tamper optical wire loop is active with zero breach attempts.",
        "category": "Security",
        "severity": "Info",
        "timestamp": "Today, 07:15 AM",
        "isRead": True
    },
    # --- Ceylon Global Freight & Logistics Ltd (kasun.fernando@ceylonlogistics.lk) ---
    {
        "doc_id": "ALT-005",
        "id": "ALT-005",
        "containerId": "CONT-004",
        "ownerEmail": "kasun.fernando@ceylonlogistics.lk",
        "title": "Cold-Chain Temperature Normal (4.2°C)",
        "message": "Reefer container CONT-004 (Pharmaceuticals) temperature telemetry within acceptable range of 2.0°C - 6.0°C.",
        "category": "Security",
        "severity": "Success",
        "timestamp": "Today, 09:15 AM",
        "isRead": True
    },
    {
        "doc_id": "ALT-006",
        "id": "ALT-006",
        "containerId": "CONT-006",
        "ownerEmail": "kasun.fernando@ceylonlogistics.lk",
        "title": "Sugathadasa RFID Checkpoint Passed",
        "message": "Container CONT-006 passed Sugathadasa corridor checkpoint. e-Seal verified intact by Customs RFID receiver.",
        "category": "Location",
        "severity": "Info",
        "timestamp": "Today, 09:40 AM",
        "isRead": True
    },
    {
        "doc_id": "ALT-007",
        "id": "ALT-007",
        "containerId": "CONT-007",
        "ownerEmail": "kasun.fernando@ceylonlogistics.lk",
        "title": "GL1 Yard Final Gate Check Passed",
        "message": "Container CONT-007 destination arrival confirmed at Grayline 1 (GL1) Yard Grandpass. Status changed to Cleared.",
        "category": "Location",
        "severity": "Success",
        "timestamp": "Today, 08:20 AM",
        "isRead": True
    },
    {
        "doc_id": "ALT-011",
        "id": "ALT-011",
        "containerId": "CONT-006",
        "ownerEmail": "kasun.fernando@ceylonlogistics.lk",
        "title": "e-Seal Battery Optimal (95%)",
        "message": "Smart seal ESEAL-SL-90826 on CONT-006 battery level is optimal at 95% with active solar trickle charging.",
        "category": "Battery",
        "severity": "Success",
        "timestamp": "Today, 08:35 AM",
        "isRead": True
    },
    # --- Lanka Maritime Forwarders Pvt Ltd (anura.wijesinghe@lankaforwarding.lk) ---
    {
        "doc_id": "ALT-008",
        "id": "ALT-008",
        "containerId": "CONT-005",
        "ownerEmail": "anura.wijesinghe@lankaforwarding.lk",
        "title": "e-Seal Optical Wire Loop Verified",
        "message": "Electronic seal ESEAL-SL-90825 self-test completed. Optical loop continuity 100% intact.",
        "category": "Security",
        "severity": "Info",
        "timestamp": "Today, 10:35 AM",
        "isRead": True
    },
    {
        "doc_id": "ALT-009",
        "id": "ALT-009",
        "containerId": "CONT-008",
        "ownerEmail": "anura.wijesinghe@lankaforwarding.lk",
        "title": "Orugodawatta RCT Transit In Progress",
        "message": "Container CONT-008 moving along Baseline corridor at 40 km/h. Expected at Orugodawatta RCT within 25 minutes.",
        "category": "Location",
        "severity": "Info",
        "timestamp": "Today, 10:10 AM",
        "isRead": True
    },
    {
        "doc_id": "ALT-010",
        "id": "ALT-010",
        "containerId": "CONT-009",
        "ownerEmail": "anura.wijesinghe@lankaforwarding.lk",
        "title": "IoT Battery Warning (18%)",
        "message": "IoT Sensor battery on container CONT-009 (TEMU 640192 8) dropped to 18%. Recharging scheduled upon arrival at Grayline 2 Yard.",
        "category": "Battery",
        "severity": "Warning",
        "timestamp": "Today, 10:05 AM",
        "isRead": False
    }
]

# 4. CUSTOMS EXAMINATION YARDS
yards_data = [
    {
        "doc_id": "YARD-RCT",
        "name": "Orugodawatta Inland Clearance Depot (RCT)",
        "code": "LKCMB-RCT",
        "location": "Baseline Road, Orugodawatta, Colombo",
        "contactPhone": "+94 11 269 1937",
        "capacityTEU": 3500,
        "operatingHours": "24 Hours / 7 Days",
        "latitude": 6.9380,
        "longitude": 79.8820
    },
    {
        "doc_id": "YARD-GL1",
        "name": "Grayline 1 (GL1) Examination Yard",
        "code": "LKCMB-GL1",
        "location": "Bloemendhal Road / Grandpass, Colombo 14",
        "contactPhone": "+94 11 243 5821",
        "capacityTEU": 2200,
        "operatingHours": "06:00 AM - 10:00 PM",
        "latitude": 6.9525,
        "longitude": 79.8730
    },
    {
        "doc_id": "YARD-GL2",
        "name": "Grayline 2 (GL2) Logistics Depot",
        "code": "LKCMB-GL2",
        "location": "Peliyagoda / Kelani Bridge Corridor",
        "contactPhone": "+94 11 291 3044",
        "capacityTEU": 1800,
        "operatingHours": "06:00 AM - 10:00 PM",
        "latitude": 6.9580,
        "longitude": 79.8650
    }
]

def to_firestore_fields(data: dict) -> dict:
    fields = {}
    for k, v in data.items():
        if k == "doc_id":
            continue
        if isinstance(v, bool):
            fields[k] = {"booleanValue": v}
        elif isinstance(v, int):
            fields[k] = {"integerValue": str(v)}
        elif isinstance(v, float):
            fields[k] = {"doubleValue": v}
        else:
            fields[k] = {"stringValue": str(v)}
    return fields

def upload_collection(collection_name: str, items: list):
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE

    print(f"\n=======================================================")
    print(f"[*] Seeding collection: '{collection_name}' ({len(items)} documents)...")
    print(f"=======================================================")

    success_count = 0
    for item in items:
        doc_id = item.get("doc_id", "doc")
        url = f"{BASE_URL}/{collection_name}/{doc_id}"
        fields = to_firestore_fields(item)
        body = json.dumps({"fields": fields}).encode("utf-8")
        req = urllib.request.Request(url, data=body, method="PATCH", headers={"Content-Type": "application/json"})

        try:
            with urllib.request.urlopen(req, context=ctx) as resp:
                print(f"  [+] Document '{collection_name}/{doc_id}' written successfully! (HTTP {resp.status})")
                success_count += 1
        except Exception as e:
            print(f"  [-] Failed to write '{doc_id}': {e}")

    print(f"[OK] Completed '{collection_name}': {success_count}/{len(items)} written.")

def delete_unwanted_doc(collection_name: str, doc_id: str):
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE
    url = f"{BASE_URL}/{collection_name}/{doc_id}"
    req = urllib.request.Request(url, method="DELETE")
    try:
        with urllib.request.urlopen(req, context=ctx) as resp:
            print(f"  [x] Removed non-owner doc '{collection_name}/{doc_id}'")
    except Exception:
        pass

def main():
    print("=================================================================")
    print(f" SecureTrack SL: Seeding Container Owners Database for: {PROJECT_ID}")
    print("=================================================================")

    # Clean up non-owner accounts
    delete_unwanted_doc("users", "customs.inspector@customs.gov.lk")
    delete_unwanted_doc("users", "driver@cargooverseas.lk")

    # Upload rich owner datasets
    upload_collection("users", owners_users_data)
    upload_collection("containers", containers_data)
    upload_collection("alerts", alerts_data)
    upload_collection("customs_yards", yards_data)

    print("\n[SUCCESS] CONTAINER OWNERS DATABASE SEEDING COMPLETED!")
    print("All collections in Firebase Console (track-sl) now contain rich Container Owner data.")

if __name__ == "__main__":
    main()

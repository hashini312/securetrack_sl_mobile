#!/usr/bin/env python3
"""
SecureTrack SL - Production Database Seeder for Cloud Firestore
Project ID: track-sl
Ecosystem: Sri Lanka Customs & Container Owner Anti-Theft Framework
"""
import urllib.request
import json
import ssl
import sys

PROJECT_ID = "track-sl"
BASE_URL = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents"

# 1. USERS COLLECTION (Container Owners, Drivers, Customs Inspectors)
users_data = [
    {
        "doc_id": "owner@cargooverseas.lk",
        "name": "Tharindu Perera",
        "email": "owner@cargooverseas.lk",
        "phone": "+94 77 123 4567",
        "role": "Owner",
        "company": "Cargo Overseas Freight Pvt Ltd",
        "companyId": "COF-SL-2026",
        "tinNumber": "TIN-104928190",
        "customsRegisteredId": "SLC-IMP-40918",
        "address": "No. 45, World Trade Center, Echelon Square, Colombo 01",
        "status": "Active"
    },
    {
        "doc_id": "driver@cargooverseas.lk",
        "name": "S.A. Gamage",
        "email": "driver@cargooverseas.lk",
        "phone": "+94 77 987 6543",
        "role": "Driver",
        "company": "Cargo Overseas Freight Pvt Ltd",
        "vehicleNo": "WP LY-4829 (Prime Mover)",
        "drivingLicenseNo": "B-49201948",
        "status": "On Duty"
    },
    {
        "doc_id": "customs.inspector@customs.gov.lk",
        "name": "C.K. Senanayake",
        "email": "customs.inspector@customs.gov.lk",
        "phone": "+94 11 222 1937",
        "role": "Customs Inspector",
        "department": "ICT & Risk Management Directorate",
        "station": "Orugodawatta RCT Yard",
        "status": "Active"
    }
]

# 2. CONTAINERS COLLECTION (Real Customs Inland Depots: Orugodawatta, Grayline 1, Grayline 2)
containers_data = [
    {
        "doc_id": "CONT-001",
        "id": "CONT-001",
        "owner": "Cargo Overseas Freight Pvt Ltd",
        "ownerEmail": "owner@cargooverseas.lk",
        "billOfLading": "MSCU-COL-892104",
        "declarationNo": "CUSDEC-2026-COL-049182",
        "vesselName": "MSC ALTAIR V-264E",
        "origin": "Colombo Port Gate 04",
        "destination": "Orugodawatta Customs Yard (RCT)",
        "route": "Colombo Port Gate 04 ➔ Orugodawatta Customs Yard (RCT)",
        "currentLocation": "Peliyagoda / Baseline Corridor",
        "estimatedArrival": "10:30 AM",
        "departureTime": "07:15 AM",
        "driverName": "S.A. Gamage",
        "driverPhone": "+94 77 987 6543",
        "vehicleNo": "WP LY-4829",
        "sealId": "ESEAL-SL-90821",
        "sealStatus": "Secure",
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
        "owner": "Cargo Overseas Freight Pvt Ltd",
        "ownerEmail": "owner@cargooverseas.lk",
        "billOfLading": "CMAU-COL-391084",
        "declarationNo": "CUSDEC-2026-COL-051839",
        "vesselName": "CMA CGM COLOMBO V-102N",
        "origin": "Colombo Port Gate 02",
        "destination": "Grayline 1 (GL1) Yard Grandpass",
        "route": "Colombo Port Gate 02 ➔ Grayline 1 (GL1) Yard Grandpass",
        "currentLocation": "Prince of Wales Avenue Corridor",
        "estimatedArrival": "11:15 AM",
        "departureTime": "08:00 AM",
        "driverName": "K.D. Kumara",
        "driverPhone": "+94 71 456 7890",
        "vehicleNo": "WP LY-5912",
        "sealId": "ESEAL-SL-90822",
        "sealStatus": "Secure",
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
        "owner": "Cargo Overseas Freight Pvt Ltd",
        "ownerEmail": "owner@cargooverseas.lk",
        "billOfLading": "HLCU-COL-992105",
        "declarationNo": "CUSDEC-2026-COL-038291",
        "vesselName": "HAPAG LLOYD EXPRESS V-509",
        "origin": "Colombo Port Gate 05",
        "destination": "Grayline 2 (GL2) Yard Peliyagoda",
        "route": "Colombo Port Gate 05 ➔ Grayline 2 (GL2) Yard Peliyagoda",
        "currentLocation": "Grayline 2 (GL2) Cargo Terminal",
        "estimatedArrival": "02:30 PM",
        "departureTime": "01:15 PM",
        "driverName": "R.M. Perera",
        "driverPhone": "+94 76 890 1234",
        "vehicleNo": "WP LZ-1082",
        "sealId": "ESEAL-SL-90823",
        "sealStatus": "Secure",
        "batteryLevel": 92,
        "temperature": 27.5,
        "humidity": 68,
        "status": "Arrived",
        "latitude": 6.9580,
        "longitude": 79.8650,
        "speed": 0
    }
]

# 3. ALERTS COLLECTION
alerts_data = [
    {
        "doc_id": "ALT-001",
        "id": "ALT-001",
        "containerId": "CONT-002",
        "title": "Low Battery Warning (20%)",
        "message": "Tracker battery level dropped below threshold on container CONT-002. Recharging recommended upon GL1 yard arrival.",
        "category": "Battery",
        "severity": "Warning",
        "timestamp": "Today, 08:30 AM",
        "isRead": False
    },
    {
        "doc_id": "ALT-002",
        "id": "ALT-002",
        "containerId": "CONT-001",
        "title": "Ingurukade RFID Gate Scanned",
        "message": "Container CONT-001 verified by Sri Lanka Customs RFID scanner at Ingurukade Junction Terminal corridor.",
        "category": "Location",
        "severity": "Info",
        "timestamp": "Today, 07:38 AM",
        "isRead": True
    },
    {
        "doc_id": "ALT-003",
        "id": "ALT-003",
        "containerId": "CONT-003",
        "title": "Final Yard Arrival Confirmed",
        "message": "Container CONT-003 safely arrived at Grayline 2 (GL2) Peliyagoda. Cargo unlocked under Customs supervision.",
        "category": "Location",
        "severity": "Success",
        "timestamp": "Today, 02:15 PM",
        "isRead": True
    },
    {
        "doc_id": "ALT-004",
        "id": "ALT-004",
        "containerId": "CONT-001",
        "title": "Electronic Seal (e-Seal) Health Normal",
        "message": "e-Seal ESEAL-SL-90821 integrity check passed with zero tampering incidents reported.",
        "category": "Security",
        "severity": "Info",
        "timestamp": "Today, 07:15 AM",
        "isRead": True
    }
]

# 4. CUSTOMS EXAMINATION YARDS COLLECTION (Sri Lanka Customs Reference)
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
                print(f"  [+] Document '{collection_name}/{doc_id}' successfully written! (HTTP {resp.status})")
                success_count += 1
        except Exception as e:
            print(f"  [-] Failed to write '{doc_id}': {e}")

    print(f"[OK] Completed '{collection_name}': {success_count}/{len(items)} written.")

def main():
    print("=================================================================")
    print(f" SecureTrack SL: Seeding Real Database for Project: {PROJECT_ID}")
    print("=================================================================")

    upload_collection("users", users_data)
    upload_collection("containers", containers_data)
    upload_collection("alerts", alerts_data)
    upload_collection("customs_yards", yards_data)

    print("\n[SUCCESS] DATABASE SEEDING COMPLETED SUCCESSFULLY!")
    print("All collections are now active in Firebase Console (track-sl).")

if __name__ == "__main__":
    main()

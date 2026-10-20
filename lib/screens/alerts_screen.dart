import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum PriorityLevel {
  normal,
  important,
  high,
  critical,
}

extension PriorityExtension on PriorityLevel {
  String get localizedLabel {
    switch (this) {
      case PriorityLevel.normal:
        return 'normal'.tr();
      case PriorityLevel.important:
        return 'important'.tr();
      case PriorityLevel.high:
        return 'high'.tr();
      case PriorityLevel.critical:
        return 'critical'.tr();
    }
  }

  Color get color {
    switch (this) {
      case PriorityLevel.normal:
        return Colors.green;
      case PriorityLevel.important:
        return Colors.orange;
      case PriorityLevel.high:
        return Colors.red;
      case PriorityLevel.critical:
        return Colors.purple.shade800;
    }
  }

  static PriorityLevel priorityFromString(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'important':
        return PriorityLevel.important;
      case 'high':
        return PriorityLevel.high;
      case 'critical':
        return PriorityLevel.critical;
      case 'normal':
      default:
        return PriorityLevel.normal;
    }
  }
}

class AlertItem {
  final String? id;
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final PriorityLevel priority;
  final bool isRead;

  const AlertItem({
    this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.priority,
    this.isRead = true,
  });

  factory AlertItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = (doc.data() as Map<String, dynamic>?) ?? {};

    PriorityLevel priorityEnum = PriorityExtension.priorityFromString(
      data['priority'] ?? 'normal',
    );

    IconData alertIcon;
    switch (data['type']) {
      case 'route':
        alertIcon = Icons.map_rounded;
        break;
      case 'deviation':
        alertIcon = Icons.alt_route_rounded;
        break;
      case 'geofence':
        alertIcon = Icons.wrong_location_rounded;
        break;
      case 'shipment':
        alertIcon = Icons.inventory_2_rounded;
        break;
      case 'chat':
        alertIcon = Icons.mark_chat_unread_rounded;
        break;
      case 'instruction':
        alertIcon = Icons.campaign_rounded;
        break;
      case 'issue_response':
        alertIcon = Icons.build_circle_rounded;
        break;
      case 'issue_resolved':
        alertIcon = Icons.check_circle_rounded;
        break;
      case 'tamper':
      case 'security':
        alertIcon = Icons.gpp_maybe_rounded;
        break;
      case 'emergency':
        alertIcon = Icons.notification_important_rounded;
        break;
      case 'schedule':
        alertIcon = Icons.update_rounded;
        break;
      case 'completed':
        alertIcon = Icons.task_alt_rounded;
        break;
      case 'trip':
      default:
        alertIcon = Icons.local_shipping_rounded;
        break;
    }

    String formattedTime = 'Just now';
    if (data['timestamp'] != null) {
      Timestamp timestamp = data['timestamp'] as Timestamp;
      DateTime dateTime = timestamp.toDate();
      Duration diff = DateTime.now().difference(dateTime);

      if (diff.inMinutes < 1) {
        formattedTime = 'Just now';
      } else if (diff.inMinutes < 60) {
        formattedTime = '${diff.inMinutes} mins ago';
      } else if (diff.inHours < 24) {
        formattedTime = '${diff.inHours} hrs ago';
      } else if (diff.inDays == 1) {
        formattedTime = 'Yesterday';
      } else {
        formattedTime = '${diff.inDays} days ago';
      }
    }

    return AlertItem(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      time: formattedTime,
      icon: alertIcon,
      priority: priorityEnum,
      isRead: data['isRead'] ?? false,
    );
  }

  factory AlertItem.fromMap(Map<String, dynamic> data) {
    PriorityLevel priorityEnum = PriorityExtension.priorityFromString(
      data['priority'] ?? 'normal',
    );

    IconData alertIcon = Icons.notifications;
    switch (data['type']) {
      case 'tamper':
        alertIcon = Icons.gpp_maybe_rounded;
        break;
      case 'deviation':
        alertIcon = Icons.alt_route_rounded;
        break;
      case 'instruction':
        alertIcon = Icons.campaign_rounded;
        break;
      case 'shipment':
        alertIcon = Icons.inventory_2_rounded;
        break;
      case 'completed':
        alertIcon = Icons.task_alt_rounded;
        break;
      default:
        alertIcon = Icons.local_shipping_rounded;
    }

    return AlertItem(
      id: data['id'],
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      time: 'Today',
      icon: alertIcon,
      priority: priorityEnum,
      isRead: data['isRead'] ?? true,
    );
  }
}

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final driverId = currentUser?.uid ?? '';

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('alerts')
            .where('driverId', isEqualTo: driverId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // If firestore has items, display them
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            final alertDocs = snapshot.data!.docs;
            return ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: alertDocs.length,
              itemBuilder: (context, index) {
                final doc = alertDocs[index];
                final alert = AlertItem.fromFirestore(doc);
                return _buildAlertCard(
                  alert,
                  onTap: () async {
                    if (!alert.isRead) {
                      try {
                        await doc.reference.update({'isRead': true});
                      } catch (e) {
                        debugPrint("Error updating alert read state: $e");
                      }
                    }
                  },
                );
              },
            );
          }

          // Fallback to default Sri Lanka Customs alerts if empty
          final fallbackAlerts = FirebaseService.defaultCustomsAlerts;
          if (fallbackAlerts.isNotEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: fallbackAlerts.length,
              itemBuilder: (context, index) {
                final alert = AlertItem.fromMap(fallbackAlerts[index]);
                return _buildAlertCard(alert);
              },
            );
          }

          return Center(
            child: Text(
              'no_alerts'.tr(),
              style: const TextStyle(color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlertCard(AlertItem alert, {VoidCallback? onTap}) {
    final priorityColor = alert.priority.color;

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: priorityColor.withValues(alpha: 0.12),
            radius: 24,
            child: Icon(alert.icon, color: priorityColor, size: 24),
          ),
          title: Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    alert.title,
                    style: TextStyle(
                      fontWeight: alert.isRead ? FontWeight.w600 : FontWeight.bold,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  alert.time,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                alert.description,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: priorityColor.withValues(alpha: 0.5), width: 0.8),
                ),
                child: Text(
                  alert.priority.localizedLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: priorityColor,
                  ),
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!alert.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                ),
              const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/settings_screen.dart';
import 'package:driver_app/screens/shipments_screen.dart';
import 'package:driver_app/services/session_service.dart';

class Menu extends StatelessWidget {
  final Function(int) onSelectTab;

  const Menu({super.key, required this.onSelectTab});

  @override
  Widget build(BuildContext context) {
    String currentLang = 'English';

    final currentLocale = context.locale;
    if (currentLocale.languageCode == 'si') {
      currentLang = 'සිංහල';
    } else if (currentLocale.languageCode == 'ta') {
      currentLang = 'தமிழ்';
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, authSnapshot) {
              final User? currentUser = authSnapshot.data;

              if (currentUser == null) {
                return UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: Color(0xFF1E3A8A)),
                  accountName: Text('driver'.tr()),
                  accountEmail: const Text('DRIVER'),
                );
              }

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  String userName = 'Saman Kumara';
                  String userRole = 'DRIVER';

                  if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                    var userData = snapshot.data!.data() as Map<String, dynamic>?;
                    if (userData != null) {
                      userName = userData['fullName'] ?? userData['fullname'] ?? 'Saman Kumara';
                      userRole = userData['role'] ?? 'DRIVER';
                    }
                  }

                  return UserAccountsDrawerHeader(
                    decoration: const BoxDecoration(color: Color(0xFF1E3A8A)),
                    accountName: Text(
                      userName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    accountEmail: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        userRole,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    currentAccountPicture: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: Color(0xFF1E3A8A)),
                    ),
                  );
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: Text('shipments'.tr()),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShipmentsScreen(
                    onNavigateTab: onSelectTab,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.map_outlined),
            title: Text('route'.tr()),
            onTap: () {
              Navigator.pop(context);
              onSelectTab(1); // Go to Map/Route tab
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text('profile'.tr()),
            onTap: () {
              Navigator.pop(context);
              onSelectTab(3);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text('settings'.tr()),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text('language'.tr()),
            subtitle: Text(currentLang),
            onTap: () {
              _showLanguageDialog(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text('logout'.tr(), style: const TextStyle(color: Colors.red)),
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        final activeCode = parentContext.locale.languageCode;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'select_language'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English (English)'),
                trailing: activeCode == 'en'
                    ? const Icon(Icons.check_circle, color: Color(0xFF1E3A8A))
                    : null,
                onTap: () async {
                  Navigator.pop(dialogContext);
                  if (parentContext.mounted) {
                    await parentContext.setLocale(const Locale('en'));
                  }
                },
              ),
              ListTile(
                title: const Text('සිංහල (Sinhala)'),
                trailing: activeCode == 'si'
                    ? const Icon(Icons.check_circle, color: Color(0xFF1E3A8A))
                    : null,
                onTap: () async {
                  Navigator.pop(dialogContext);
                  if (parentContext.mounted) {
                    await parentContext.setLocale(const Locale('si'));
                  }
                },
              ),
              ListTile(
                title: const Text('தமிழ் (Tamil)'),
                trailing: activeCode == 'ta'
                    ? const Icon(Icons.check_circle, color: Color(0xFF1E3A8A))
                    : null,
                onTap: () async {
                  Navigator.pop(dialogContext);
                  if (parentContext.mounted) {
                    await parentContext.setLocale(const Locale('ta'));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        title: Text('logout'.tr()),
        content: Text('confirm_logout'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
                await SessionService.logout(parentContext);
              } catch (e) {
                if (parentContext.mounted) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(content: Text('Logout Error: $e')),
                  );
                }
              }
            },
            child: Text('logout'.tr(), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String phone;
  final String email;
  final String vehicle;
  final String company;

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.phone,
    required this.email,
    required this.vehicle,
    required this.company,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _vehicleController;
  late TextEditingController _companyController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _phoneController = TextEditingController(text: widget.phone);
    _emailController = TextEditingController(text: widget.email);
    _vehicleController = TextEditingController(text: widget.vehicle);
    _companyController = TextEditingController(text: widget.company);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _vehicleController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  Widget _buildEditCard({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    required bool isDarkMode,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1F2937) : const Color.fromARGB(255, 220, 220, 224),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF1E67BF),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Color(0xFF1E3A8A),
              ),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : const Color.fromARGB(255, 114, 111, 111),
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
          elevation: 0,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
          foregroundColor: isDarkMode ? Colors.white : const Color(0xFF1E3A8A),
        ),
        body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildEditCard(
              label: 'Name',
              controller: _nameController,
              icon: Icons.person_outline_rounded,
              isDarkMode: isDarkMode,
            ),
            _buildEditCard(
              label: 'Phone',
              controller: _phoneController,
              icon: Icons.phone_outlined,
              isDarkMode: isDarkMode,
            ),
            _buildEditCard(
              label: 'E-mail',
              controller: _emailController,
              icon: Icons.email_outlined,
              readOnly: true,
              isDarkMode: isDarkMode,
            ),
            _buildEditCard(
              label: 'Vehicle Details',
              controller: _vehicleController,
              icon: Icons.directions_car_outlined,
              isDarkMode: isDarkMode,
            ),
            _buildEditCard(
              label: 'Company Details',
              controller: _companyController,
              icon: Icons.business_outlined,
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final nav = Navigator.of(context);

                        setState(() {
                          _isLoading = true;
                        });

                        try {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            // Firestore Database update logic
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .set({
                              'fullName': _nameController.text,
                              'fullname': _nameController.text,
                              'phone': _phoneController.text,
                              'vehicleNo': _vehicleController.text,
                              'company': _companyController.text,
                            }, SetOptions(merge: true));

                            if (!mounted) return;
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Profile updated successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            nav.pop();
                          }
                        } catch (e) {
                          if (!mounted) return;
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Error updating profile: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E67BF),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
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
    );
  }
}
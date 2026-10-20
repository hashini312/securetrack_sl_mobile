import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:securetrack_sl/owner/components.dart';

/// SRS Figure 6 & Section 4.1.1: Driver Emergency SOS & Incident Dispatch Dialog
class DriverSosDialog extends StatefulWidget {
  final String containerId;
  final String vehicleNo;

  const DriverSosDialog({
    super.key,
    required this.containerId,
    required this.vehicleNo,
  });

  @override
  State<DriverSosDialog> createState() => _DriverSosDialogState();
}

class _DriverSosDialogState extends State<DriverSosDialog> {
  String _selectedReason = 'Corridor Road Blockage / Traffic Jam';
  final TextEditingController _notesController = TextEditingController();
  bool _isSending = false;

  final List<String> _emergencyReasons = [
    'Corridor Road Blockage / Traffic Jam',
    'Vehicle Breakdown / Mechanical Failure',
    'Accident / Collision Incident',
    'Suspicious Activity / Tamper Threat',
    'Medical Emergency',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _dispatchAlert() async {
    setState(() => _isSending = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('alerts').add({
        'title': '🚨 DRIVER SOS: $_selectedReason',
        'message': _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : 'Driver reported $_selectedReason on transit corridor for container ${widget.containerId}.',
        'type': 'DANGER',
        'containerId': widget.containerId,
        'vehicleNo': widget.vehicleNo,
        'driverId': user?.uid ?? 'unknown',
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text('Customs Command Center notified of Emergency SOS!'),
              ),
            ],
          ),
          backgroundColor: AppColors.dangerRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to transmit SOS: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.dangerLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emergency_rounded, color: AppColors.dangerRed, size: 26),
          ),
          const SizedBox(width: 12),
          Text(
            'Emergency SOS',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transmit immediate priority alert directly to Sri Lanka Customs Operations Command.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select Emergency Reason',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderLight),
                borderRadius: BorderRadius.circular(12),
                color: AppColors.background,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedReason,
                  items: _emergencyReasons.map((r) {
                    return DropdownMenuItem(
                      value: r,
                      child: Text(r, style: GoogleFonts.poppins(fontSize: 12)),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedReason = v);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Additional Details (Optional)',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              maxLines: 2,
              style: GoogleFonts.poppins(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'e.g. Near Peliyagoda junction...',
                hintStyle: GoogleFonts.poppins(color: AppColors.textLight, fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(color: AppColors.textMuted),
          ),
        ),
        ElevatedButton(
          onPressed: _isSending ? null : _dispatchAlert,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.dangerRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isSending
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Text('Transmit SOS', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

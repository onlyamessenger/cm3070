// apps/fortify/lib/pages/player/readiness/emergency_contacts_page.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:fortify/config/emergency_contacts_data.dart';
import 'package:fortify/config/theme/admin_colors.dart';

class EmergencyContactsPage extends StatelessWidget {
  const EmergencyContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        backgroundColor: AdminColors.background,
        foregroundColor: AdminColors.onSurface,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('\u{1F4DE}', style: TextStyle(fontSize: 22)),
            SizedBox(width: 8),
            Text('Emergency Contacts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: <Widget>[
          const Text(
            'Tap a phone number to call. Keep these numbers saved for emergencies.',
            style: TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ...emergencyContacts.map((EmergencyContactData contact) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ContactCard(contact: contact, onCallTap: () => _handlePhoneTap(context, contact)),
            );
          }),
        ],
      ),
    );
  }

  void _handlePhoneTap(BuildContext context, EmergencyContactData contact) {
    final String digits = contact.phoneNumber.replaceAll(RegExp(r'\s'), '');
    if (kIsWeb) {
      _showPhoneDialog(context, contact);
    } else {
      launchUrl(Uri.parse('tel:$digits')).catchError((_) {
        if (context.mounted) _showPhoneDialog(context, contact);
        return false;
      });
    }
  }

  void _showPhoneDialog(BuildContext context, EmergencyContactData contact) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AdminColors.surfaceContainer,
          title: Text(contact.name, style: const TextStyle(color: AdminColors.onSurface, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                contact.phoneNumber,
                style: const TextStyle(color: AdminColors.primary, fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Copy this number to your phone',
                style: TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 13),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: contact.phoneNumber));
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Number copied to clipboard'), duration: Duration(seconds: 2)),
                );
              },
              child: const Text('Copy', style: TextStyle(color: AdminColors.primary)),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close', style: TextStyle(color: AdminColors.onSurfaceVariant)),
            ),
          ],
        );
      },
    );
  }
}

class _ContactCard extends StatelessWidget {
  final EmergencyContactData contact;
  final VoidCallback onCallTap;

  const _ContactCard({required this.contact, required this.onCallTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AdminColors.surfaceContainer, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AdminColors.primaryOverlay, borderRadius: BorderRadius.circular(6)),
                child: Text(
                  contact.category,
                  style: const TextStyle(color: AdminColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
              const Spacer(),
              Text(contact.operatingHours, style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            contact.name,
            style: const TextStyle(color: AdminColors.onSurface, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onCallTap,
            child: Row(
              children: <Widget>[
                const Icon(Icons.phone, color: AdminColors.success, size: 18),
                const SizedBox(width: 8),
                Text(
                  contact.phoneNumber,
                  style: const TextStyle(color: AdminColors.success, fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            contact.description,
            style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import '../services/database_service.dart';

class ActionHelper {
  // Vibrate on scan
  static Future<void> vibrateIfEnabled() async {
    final shouldVibrate = DatabaseService.getSetting('vibrate_on_scan', defaultValue: true);
    if (shouldVibrate) {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 200);
      }
    }
  }

  // Play beep sound
  static Future<void> beepIfEnabled() async {
    final shouldBeep = DatabaseService.getSetting('beep_on_scan', defaultValue: true);
    if (shouldBeep) {
      // Using a simple system sound
      await SystemSound.play(SystemSoundType.click);
    }
  }

  // Copy to clipboard
  static Future<void> copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Auto-copy if enabled
  static Future<void> autoCopyIfEnabled(String text) async {
    final shouldAutoCopy = DatabaseService.getSetting('auto_copy', defaultValue: false);
    if (shouldAutoCopy) {
      await Clipboard.setData(ClipboardData(text: text));
    }
  }

  // Open URL
  static Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // Auto-open URL if enabled
  static Future<bool> shouldAutoOpenUrl() async {
    return DatabaseService.getSetting('auto_open_links', defaultValue: false);
  }

  // Make phone call
  static Future<void> makePhoneCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // Send email
  static Future<void> sendEmail(String email, {String? subject, String? body}) async {
    String emailUrl = 'mailto:$email';
    if (subject != null || body != null) {
      emailUrl += '?';
      if (subject != null) emailUrl += 'subject=${Uri.encodeComponent(subject)}';
      if (subject != null && body != null) emailUrl += '&';
      if (body != null) emailUrl += 'body=${Uri.encodeComponent(body)}';
    }
    
    final uri = Uri.parse(emailUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // Search product on Google
  static Future<void> searchProduct(String barcode) async {
    final searchUrl = 'https://www.google.com/search?q=$barcode';
    await openUrl(searchUrl);
  }

  // Parse WiFi QR content
  static Map<String, String>? parseWiFi(String content) {
    if (!content.startsWith('WIFI:')) return null;
    
    final params = <String, String>{};
    final parts = content.substring(5).split(';');
    
    for (final part in parts) {
      if (part.isEmpty) continue;
      final colonIndex = part.indexOf(':');
      if (colonIndex > 0) {
        final key = part.substring(0, colonIndex);
        final value = part.substring(colonIndex + 1);
        params[key] = value;
      }
    }
    
    return params;
  }

  // Generate WiFi QR content
  static String generateWiFiContent({
    required String ssid,
    required String password,
    String encryption = 'WPA',
  }) {
    return 'WIFI:T:$encryption;S:$ssid;P:$password;;';
  }

  // Generate vCard content
  static String generateVCard({
    required String name,
    String? phone,
    String? email,
    String? organization,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('BEGIN:VCARD');
    buffer.writeln('VERSION:3.0');
    buffer.writeln('FN:$name');
    if (phone != null) buffer.writeln('TEL:$phone');
    if (email != null) buffer.writeln('EMAIL:$email');
    if (organization != null) buffer.writeln('ORG:$organization');
    buffer.writeln('END:VCARD');
    return buffer.toString();
  }

  // Get icon for code type
  static IconData getIconForType(String type) {
    switch (type) {
      case 'url':
        return Icons.link;
      case 'wifi':
        return Icons.wifi;
      case 'phone':
        return Icons.phone;
      case 'email':
        return Icons.email;
      case 'contact':
        return Icons.contact_page;
      case 'product':
        return Icons.shopping_cart;
      case 'text':
      default:
        return Icons.text_fields;
    }
  }

  // Get display name for type
  static String getDisplayNameForType(String type) {
    switch (type) {
      case 'url':
        return 'Website';
      case 'wifi':
        return 'Wi-Fi Network';
      case 'phone':
        return 'Phone Number';
      case 'email':
        return 'Email';
      case 'contact':
        return 'Contact';
      case 'product':
        return 'Product';
      case 'text':
      default:
        return 'Text';
    }
  }
}

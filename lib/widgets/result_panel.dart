import 'package:flutter/material.dart';
import '../utils/action_helper.dart';

class ResultPanel extends StatelessWidget {
  final String content;
  final String type;
  final VoidCallback? onClose;

  const ResultPanel({
    super.key,
    required this.content,
    required this.type,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                ActionHelper.getIconForType(type),
                color: Theme.of(context).primaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                ActionHelper.getDisplayNameForType(type),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClose ?? () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Content Display
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            constraints: const BoxConstraints(maxHeight: 150),
            child: SingleChildScrollView(
              child: SelectableText(
                content,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Action Buttons
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final buttons = <Widget>[];

    // Always show: Copy to Clipboard
    buttons.add(
      _ActionButton(
        icon: Icons.copy,
        label: 'Copy',
        onPressed: () => ActionHelper.copyToClipboard(context, content),
      ),
    );

    // Type-specific actions
    switch (type) {
      case 'url':
        buttons.add(
          _ActionButton(
            icon: Icons.open_in_browser,
            label: 'Open in Browser',
            onPressed: () => ActionHelper.openUrl(content),
          ),
        );
        break;

      case 'wifi':
        final wifiData = ActionHelper.parseWiFi(content);
        if (wifiData != null) {
          buttons.add(
            _ActionButton(
              icon: Icons.wifi,
              label: 'Connect to Wi-Fi',
              onPressed: () => _showWiFiInfo(context, wifiData),
            ),
          );
        }
        break;

      case 'phone':
        final phone = content.replaceFirst('tel:', '');
        buttons.add(
          _ActionButton(
            icon: Icons.call,
            label: 'Call',
            onPressed: () => ActionHelper.makePhoneCall(phone),
          ),
        );
        buttons.add(
          _ActionButton(
            icon: Icons.message,
            label: 'Send SMS',
            onPressed: () => ActionHelper.openUrl('sms:$phone'),
          ),
        );
        break;

      case 'email':
        final email = content.replaceFirst('mailto:', '');
        buttons.add(
          _ActionButton(
            icon: Icons.email,
            label: 'Send Email',
            onPressed: () => ActionHelper.sendEmail(email),
          ),
        );
        break;

      case 'product':
        buttons.add(
          _ActionButton(
            icon: Icons.search,
            label: 'Search on Google',
            onPressed: () => ActionHelper.searchProduct(content),
          ),
        );
        break;
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: buttons,
    );
  }

  void _showWiFiInfo(BuildContext context, Map<String, String> wifiData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wi-Fi Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow('Network:', wifiData['S'] ?? 'Unknown'),
            _InfoRow('Password:', wifiData['P'] ?? 'None'),
            _InfoRow('Security:', wifiData['T'] ?? 'None'),
            const SizedBox(height: 12),
            const Text(
              'Connect to this network manually using the information above.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              ActionHelper.copyToClipboard(context, wifiData['P'] ?? '');
              Navigator.pop(context);
            },
            child: const Text('Copy Password'),
          ),
        ],
      ),
    );
  }

  static void show(BuildContext context, String content, String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ResultPanel(
        content: content,
        type: type,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

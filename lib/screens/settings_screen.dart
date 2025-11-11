import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/database_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _vibrateOnScan = true;
  bool _beepOnScan = true;
  bool _autoCopy = false;
  bool _autoOpenLinks = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _vibrateOnScan = DatabaseService.getSetting('vibrate_on_scan', defaultValue: true);
      _beepOnScan = DatabaseService.getSetting('beep_on_scan', defaultValue: true);
      _autoCopy = DatabaseService.getSetting('auto_copy', defaultValue: false);
      _autoOpenLinks = DatabaseService.getSetting('auto_open_links', defaultValue: false);
    });
  }

  Future<void> _updateSetting(String key, bool value) async {
    await DatabaseService.setSetting(key, value);
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All History'),
        content: const Text(
          'This will permanently delete all your scan history. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear History'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseService.clearAllScans();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('History cleared')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // General Section
          const _SectionHeader(title: 'General'),
          SwitchListTile(
            title: const Text('Vibrate on Scan'),
            subtitle: const Text('Vibrate when a code is detected'),
            value: _vibrateOnScan,
            onChanged: (value) {
              setState(() => _vibrateOnScan = value);
              _updateSetting('vibrate_on_scan', value);
            },
          ),
          SwitchListTile(
            title: const Text('Beep on Scan'),
            subtitle: const Text('Play sound when a code is detected'),
            value: _beepOnScan,
            onChanged: (value) {
              setState(() => _beepOnScan = value);
              _updateSetting('beep_on_scan', value);
            },
          ),

          const Divider(),

          // Scanning Section
          const _SectionHeader(title: 'Scanning'),
          SwitchListTile(
            title: const Text('Auto-copy to Clipboard'),
            subtitle: const Text('Automatically copy scanned codes'),
            value: _autoCopy,
            onChanged: (value) {
              setState(() => _autoCopy = value);
              _updateSetting('auto_copy', value);
            },
          ),
          SwitchListTile(
            title: const Text('Auto-open Links'),
            subtitle: const Text('Automatically open URLs in browser'),
            value: _autoOpenLinks,
            onChanged: (value) {
              setState(() => _autoOpenLinks = value);
              _updateSetting('auto_open_links', value);
              
              if (value && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('⚠️ URLs will now open automatically'),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
          ),

          const Divider(),

          // History Section
          const _SectionHeader(title: 'History'),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Clear All Scan History',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text('Delete all saved scans'),
            onTap: _clearHistory,
          ),

          const Divider(),

          // About Section
          const _SectionHeader(title: 'About'),
          ListTile(
            leading: const Icon(Icons.bug_report, color: Colors.orange),
            title: const Text('Report an Error'),
            subtitle: const Text('Found a bug? Let us know!'),
            trailing: const Icon(Icons.open_in_new, size: 16),
            onTap: () async {
              final url = Uri.parse('https://wa.me/+923057468644');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open WhatsApp')),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_support, color: Colors.blue),
            title: const Text('Contact the Developer'),
            subtitle: const Text('Get in touch via WhatsApp'),
            trailing: const Icon(Icons.open_in_new, size: 16),
            onTap: () async {
              final url = Uri.parse('https://wa.me/+923057468644');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open WhatsApp')),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Rate this App'),
            subtitle: const Text('Love the app? Leave us a review!'),
            trailing: const Icon(Icons.open_in_new, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening app store...')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.open_in_new, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy policy not configured')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

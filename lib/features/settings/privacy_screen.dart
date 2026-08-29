import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        title: const Text(
          'Your Privacy',
          style: TextStyle(color: Color(0xFFE8ECF4), fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFE8ECF4)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(Icons.security, size: 64, color: Color(0xFFF5C842)),
          const SizedBox(height: 24),
          const Text(
            'We believe your data belongs to you.',
            style: TextStyle(
              color: Color(0xFFE8ECF4),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildInfoItem(
            Icons.save_alt,
            'Your data is stored on this device',
            'We don\'t store your personal sleep data on our servers.',
          ),
          _buildInfoItem(
            Icons.mic_off,
            'Voice recordings stay on your phone',
            'All audio processing happens locally on your device.',
          ),
          _buildInfoItem(
            Icons.auto_awesome,
            'Check-in text is processed by AI',
            'But it is not stored as raw text on servers.',
          ),
          _buildInfoItem(
            Icons.block,
            'No data is sold to third parties',
            'We will never sell your information.',
          ),
          const SizedBox(height: 32),
          const Divider(color: Color(0xFF8B9DC3)),
          const SizedBox(height: 16),
          const Text(
            'Permissions Overview',
            style: TextStyle(color: Color(0xFFE8ECF4), fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildPermissionItem('Microphone', 'Used for voice check-ins and custom alarm voices.'),
          _buildPermissionItem('Notifications', 'Used to trigger your morning alarm and reminders.'),
          const SizedBox(height: 32),
          const Divider(color: Color(0xFF8B9DC3)),
          const SizedBox(height: 16),
          const Text(
            'Data Management',
            style: TextStyle(color: Color(0xFFE8ECF4), fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildActionItem(
            'Delete Check-in History',
            Icons.delete_outline,
            () {},
          ),
          _buildActionItem(
            'Delete Voice Recordings',
            Icons.delete_outline,
            () {},
          ),
          _buildActionItem(
            'Delete Feedback History',
            Icons.delete_outline,
            () {},
          ),
          _buildActionItem(
            'Export My Data (Coming Soon)',
            Icons.download,
            () {},
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              _showNuclearDialog(context);
            },
            icon: const Icon(Icons.warning, color: Colors.white),
            label: const Text('Delete All Data', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFF5C842), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFFE8ECF4), fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Color(0xFF8B9DC3), fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(String name, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, color: Color(0xFF8B9DC3), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Color(0xFF8B9DC3), fontSize: 14),
                children: [
                  TextSpan(text: '$name: ', style: const TextStyle(color: Color(0xFFE8ECF4), fontWeight: FontWeight.bold)),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFF8B9DC3)),
      title: Text(title, style: const TextStyle(color: Color(0xFFE8ECF4))),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF8B9DC3)),
      onTap: onTap,
    );
  }

  void _showNuclearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F36),
        title: const Text('Delete All Data?', style: TextStyle(color: Colors.redAccent)),
        content: const Text(
          'This will permanently delete all your check-ins, sleep plans, voice recordings, and feedback. This action cannot be undone.',
          style: TextStyle(color: Color(0xFFE8ECF4)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8B9DC3))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // Perform deletion
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

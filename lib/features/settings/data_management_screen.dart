import 'package:flutter/material.dart';

class DataManagementScreen extends StatelessWidget {
  const DataManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        title: const Text(
          'Data Management',
          style: TextStyle(color: Color(0xFFE8ECF4), fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFE8ECF4)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDataCategory(
            title: 'Check-in History',
            storageInfo: '1.2 MB (42 entries)',
            onDelete: () {},
          ),
          _buildDataCategory(
            title: 'Sleep Plans',
            storageInfo: '0.8 MB (30 entries)',
            onDelete: () {},
          ),
          _buildDataCategory(
            title: 'Voice Recordings',
            storageInfo: '15.4 MB (12 clips)',
            onDelete: () {},
          ),
          _buildDataCategory(
            title: 'Feedback Analytics',
            storageInfo: '0.1 MB',
            onDelete: () {},
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.delete_sweep, color: Colors.white),
            label: const Text('Clear All Local Data', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCategory({
    required String title,
    required String storageInfo,
    required VoidCallback onDelete,
  }) {
    return Card(
      color: const Color(0xFF1A1F36),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFFE8ECF4),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    storageInfo,
                    style: const TextStyle(
                      color: Color(0xFF8B9DC3),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

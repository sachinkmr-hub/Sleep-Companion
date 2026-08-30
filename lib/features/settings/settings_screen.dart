import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neend_companion/features/demo/demo_service.dart';
import 'package:neend_companion/data/repositories/user_repository.dart';
import 'package:neend_companion/data/repositories/checkin_repository.dart';
import 'package:neend_companion/data/repositories/plan_repository.dart';
import 'package:neend_companion/data/repositories/alarm_repository.dart';
import 'package:neend_companion/data/repositories/feedback_repository.dart';
import 'package:neend_companion/data/repositories/voice_repository.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final UserRepository _userRepo = UserRepository();
  String _displayName = 'User';
  String _sleepTime = '11:00 PM';
  String _wakeTime = '07:00 AM';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _userRepo.getProfile();
    if (profile != null && mounted) {
      setState(() {
        _displayName = profile.displayName;
        _sleepTime = profile.usualSleepTime;
        _wakeTime = profile.usualWakeTime;
      });
    }
  }

  Future<void> _showDeleteConfirmDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F36),
        title: const Text('Delete All Data?', style: TextStyle(color: Colors.redAccent)),
        content: const Text(
          'This will permanently remove all your profiles, recordings, check-in history, alarms, and feedback from this device.',
          style: TextStyle(color: Color(0xFFE8ECF4)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8B9DC3))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _userRepo.deleteProfile();
      await CheckinRepository().clearAll();
      await PlanRepository().clearAll();
      await AlarmRepository().clearAll();
      await FeedbackRepository().clearAll();
      await VoiceRepository().clearAll();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data deleted successfully.')),
        );
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDemoMode = ref.watch(demoServiceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        title: const Text(
          'Settings',
          style: TextStyle(color: Color(0xFFE8ECF4), fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFE8ECF4)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Profile'),
          _buildTile(
            icon: Icons.person_outline,
            title: 'Display Name',
            subtitle: _displayName,
            onTap: () {},
          ),
          _buildTile(
            icon: Icons.bedtime_outlined,
            title: 'Default Sleep Time',
            subtitle: _sleepTime,
            onTap: () {},
          ),
          _buildTile(
            icon: Icons.wb_sunny_outlined,
            title: 'Default Wake Time',
            subtitle: _wakeTime,
            onTap: () {},
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Audio & Relaxation'),
          _buildTile(
            icon: Icons.music_note_outlined,
            title: 'Audio Assets & Soundscapes',
            subtitle: '7 real relaxing tracks loaded (Rain, Brown noise, Chimes...)',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('7 offline lossless audio soundscapes available')),
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Voice Messages'),
          _buildTile(
            icon: Icons.record_voice_over_outlined,
            title: 'Voice Library',
            subtitle: 'Manage loved-one voice recordings',
            onTap: () => context.push('/voice-library'),
          ),
          _buildTile(
            icon: Icons.mic_none_outlined,
            title: 'Record New Clip',
            subtitle: 'Record morning/night voice message',
            onTap: () => context.push('/record-voice'),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('AI & Intelligence Engine'),
          _buildTile(
            icon: Icons.auto_awesome_outlined,
            title: 'AI Engine Mode',
            subtitle: 'Free Multi-Provider (Gemini 2.0 Flash / Groq / On-Device Heuristic)',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Running on \$0-cost Free AI Engine with full offline fallback.'),
                ),
              );
            },
          ),
          SwitchListTile(
            title: const Text('Demo Mode', style: TextStyle(color: Color(0xFFE8ECF4))),
            subtitle: const Text('Use Rahul demo persona', style: TextStyle(color: Color(0xFF8B9DC3))),
            value: isDemoMode,
            activeColor: const Color(0xFFF5C842),
            onChanged: (val) {
              if (val) {
                ref.read(demoServiceProvider.notifier).enableDemo();
              } else {
                ref.read(demoServiceProvider.notifier).disableDemo();
              }
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Privacy & Data'),
          _buildTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy & Permissions',
            subtitle: 'View local data and privacy commitments',
            onTap: () => context.push('/privacy'),
          ),
          _buildTile(
            icon: Icons.storage_outlined,
            title: 'Data Management',
            subtitle: 'Inspect and clear local storage categories',
            onTap: () => context.push('/data-management'),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
            title: const Text('Delete All Data', style: TextStyle(color: Colors.redAccent)),
            subtitle: const Text('Clear all local data and reset app', style: TextStyle(color: Color(0xFF8B9DC3))),
            onTap: _showDeleteConfirmDialog,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 16.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF8B9DC3),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFF5C842)),
      title: Text(title, style: const TextStyle(color: Color(0xFFE8ECF4))),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(color: Color(0xFF8B9DC3)))
          : null,
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF8B9DC3)),
      onTap: onTap,
    );
  }
}

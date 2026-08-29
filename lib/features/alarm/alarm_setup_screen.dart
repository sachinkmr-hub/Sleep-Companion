import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neend_companion/features/alarm/alarm_controller.dart';
import 'package:neend_companion/models/alarm_data.dart';
import 'package:neend_companion/core/utils/string_utils.dart';
import 'package:neend_companion/features/checkin/widgets/voice_input_sheet.dart';

class AlarmSetupScreen extends ConsumerStatefulWidget {
  const AlarmSetupScreen({super.key});

  @override
  ConsumerState<AlarmSetupScreen> createState() => _AlarmSetupScreenState();
}

class _AlarmSetupScreenState extends ConsumerState<AlarmSetupScreen> {
  TimeOfDay _selectedTime = const TimeOfDay(hour: 7, minute: 0);
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default to morning
    _selectedTime = const TimeOfDay(hour: 7, minute: 0);
  }

  void _saveAlarm() {
    final now = DateTime.now();
    DateTime scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final alarm = AlarmData(
      id: now.millisecondsSinceEpoch ~/ 1000,
      scheduledTime: scheduled,
      label: _labelController.text.isNotEmpty ? _labelController.text : 'Morning Wakeup',
      tomorrowGoal: _goalController.text.isNotEmpty ? _goalController.text : null,
      isEnabled: true,
      snoozeCount: 0,
      createdAt: now,
    );

    ref.read(alarmControllerProvider.notifier).setAlarm(alarm);
    
    final formattedTime = _selectedTime.format(context);
    final confirmation = AppStringUtils.getAlarmConfirmation(
      '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
      _goalController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(confirmation),
        backgroundColor: const Color(0xFF1A1F36),
      ),
    );

    context.pop();
  }

  void _openNaturalLanguageVoiceInput() {
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => VoiceInputSheet(
        onTextCaptured: (captured) {
          _processNaturalLanguageInput(captured);
        },
      ),
    );
  }

  void _processNaturalLanguageInput(String text) {
    if (text.isEmpty) return;

    final parsedTimeStr = AppStringUtils.parseTimeFromText(text);
    if (parsedTimeStr != null) {
      final parts = parsedTimeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      setState(() {
        _selectedTime = TimeOfDay(hour: hour, minute: minute);
      });

      // Check if text has a goal (e.g. running, meeting)
      final lower = text.toLowerCase();
      if (lower.contains('running') || lower.contains('run')) {
        _goalController.text = 'Morning Running';
      } else if (lower.contains('gym') || lower.contains('workout')) {
        _goalController.text = 'Gym Workout';
      } else if (lower.contains('presentation')) {
        _goalController.text = 'Presentation';
      } else if (lower.contains('office') || lower.contains('meeting')) {
        _goalController.text = 'Office Meeting';
      }

      final confirmation = AppStringUtils.getAlarmConfirmation(
        parsedTimeStr,
        _goalController.text.isNotEmpty ? _goalController.text : null,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(confirmation),
          backgroundColor: const Color(0xFFF5C842),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not detect time. Please pick time manually.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A), // Night bg
      appBar: AppBar(
        title: const Text('Set Alarm', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1F36),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Wake Time',
              style: TextStyle(color: Color(0xFF8B9DC3), fontSize: 16),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (time != null) setState(() => _selectedTime = time);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F36),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF5C842).withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(
                    _selectedTime.format(context),
                    style: const TextStyle(
                      fontSize: 56,
                      color: Color(0xFFE8ECF4),
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  IconButton.filled(
                    onPressed: _openNaturalLanguageVoiceInput,
                    icon: const Icon(Icons.mic, size: 32),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF5C842),
                      foregroundColor: const Color(0xFF0A0E1A),
                      padding: const EdgeInsets.all(16),
                    ),
                    tooltip: 'Speak natural language alarm (e.g. Kal 5 baje uthana hai)',
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap to speak (English / Hinglish)',
                    style: TextStyle(color: Color(0xFF8B9DC3), fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _goalController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Tomorrow\'s Goal / Activity',
                hintText: 'e.g. Morning running, Client presentation',
                hintStyle: const TextStyle(color: Color(0xFF5A6E8C)),
                labelStyle: const TextStyle(color: Color(0xFF8B9DC3)),
                filled: true,
                fillColor: const Color(0xFF1A1F36),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _labelController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Alarm Label (optional)',
                hintText: 'e.g. Early Wakeup',
                hintStyle: const TextStyle(color: Color(0xFF5A6E8C)),
                labelStyle: const TextStyle(color: Color(0xFF8B9DC3)),
                filled: true,
                fillColor: const Color(0xFF1A1F36),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveAlarm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5C842),
                foregroundColor: const Color(0xFF0A0E1A),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Save & Activate Alarm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

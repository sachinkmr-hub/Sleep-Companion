import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import 'package:neend_companion/models/voice_message.dart';
import 'package:neend_companion/models/voice_consent.dart';
import 'package:neend_companion/data/repositories/voice_repository.dart';

class RecordVoiceScreen extends ConsumerStatefulWidget {
  const RecordVoiceScreen({super.key});

  @override
  ConsumerState<RecordVoiceScreen> createState() => _RecordVoiceScreenState();
}

class _RecordVoiceScreenState extends ConsumerState<RecordVoiceScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final VoiceRepository _voiceRepo = VoiceRepository();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();
  final TextEditingController _promptController = TextEditingController();

  bool _isRecording = false;
  String? _recordedFilePath;
  int _recordDuration = 0;
  bool _consentChecked = true;

  @override
  void dispose() {
    _audioRecorder.dispose();
    _nameController.dispose();
    _relationshipController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // Stop recording
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _recordedFilePath = path;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio captured successfully!')),
        );
      }
    } else {
      // Check & request permission
      if (await _audioRecorder.hasPermission()) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        final filePath = '${appDir.path}/$fileName';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: filePath,
        );

        setState(() {
          _isRecording = true;
          _recordedFilePath = null;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission required.')),
          );
        }
      }
    }
  }

  Future<void> _saveRecording() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the person\'s name.')),
      );
      return;
    }

    if (_recordedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please record an audio clip first.')),
      );
      return;
    }

    // 1. Create Voice Consent
    final consentId = const Uuid().v4();
    final consent = VoiceConsent(
      id: consentId,
      voiceOwnerName: _nameController.text.trim(),
      relationship: _relationshipController.text.trim().isNotEmpty
          ? _relationshipController.text.trim()
          : 'Loved One',
      permissionGranted: _consentChecked,
      grantedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );
    await _voiceRepo.saveConsent(consent);

    // 2. Create Voice Message Entry
    final voiceMsg = VoiceMessage(
      id: const Uuid().v4(),
      personName: _nameController.text.trim(),
      relationship: consent.relationship,
      filePath: _recordedFilePath!,
      prompt: _promptController.text.trim().isNotEmpty
          ? _promptController.text.trim()
          : 'Wake up greeting',
      durationSeconds: 5,
      consentId: consentId,
      createdAt: DateTime.now(),
    );
    await _voiceRepo.saveVoiceMessage(voiceMsg);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved voice clip from ${_nameController.text}!'),
          backgroundColor: const Color(0xFFF5C842),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        title: const Text('Record Loved One', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1F36),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Person Name',
                hintText: 'e.g. Mom, Dad, Priya',
                hintStyle: const TextStyle(color: Color(0xFF5A6E8C)),
                labelStyle: const TextStyle(color: Color(0xFF8B9DC3)),
                filled: true,
                fillColor: const Color(0xFF1A1F36),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _relationshipController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Relationship (e.g. Mother, Partner)',
                labelStyle: const TextStyle(color: Color(0xFF8B9DC3)),
                filled: true,
                fillColor: const Color(0xFF1A1F36),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _promptController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Prompt / Message Description',
                hintText: 'e.g. Morning wakeup call ("Beta uth ja")',
                hintStyle: const TextStyle(color: Color(0xFF5A6E8C)),
                labelStyle: const TextStyle(color: Color(0xFF8B9DC3)),
                filled: true,
                fillColor: const Color(0xFF1A1F36),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Suggested prompts to record:', style: TextStyle(color: Color(0xFF8B9DC3), fontSize: 14)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPromptChip('Beta uth ja. Running pe jaana hai.'),
                _buildPromptChip('Good morning! Have a great day.'),
                _buildPromptChip('Good night, sleep well.'),
              ],
            ),
            const SizedBox(height: 36),
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _toggleRecording,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isRecording ? Colors.redAccent : const Color(0xFFF5C842),
                        boxShadow: [
                          BoxShadow(
                            color: (_isRecording ? Colors.redAccent : const Color(0xFFF5C842)).withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        size: 44,
                        color: _isRecording ? Colors.white : const Color(0xFF0A0E1A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isRecording
                        ? 'Recording... Tap to stop'
                        : (_recordedFilePath != null ? 'Clip recorded! Tap to re-record' : 'Tap to record audio'),
                    style: TextStyle(
                      color: _isRecording ? Colors.redAccent : const Color(0xFF8B9DC3),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Checkbox(
                  value: _consentChecked,
                  activeColor: const Color(0xFFF5C842),
                  onChanged: (val) => setState(() => _consentChecked = val ?? true),
                ),
                const Expanded(
                  child: Text(
                    'I confirm that this person has given explicit consent for their voice to be used as my companion audio.',
                    style: TextStyle(color: Color(0xFF8B9DC3), fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveRecording,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5C842),
                foregroundColor: const Color(0xFF0A0E1A),
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Save Loved-One Recording', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptChip(String text) {
    return ActionChip(
      label: Text(text, style: const TextStyle(color: Color(0xFFE8ECF4), fontSize: 12)),
      backgroundColor: const Color(0xFF1A1F36),
      side: const BorderSide(color: Color(0xFF2D3554)),
      onPressed: () {
        setState(() {
          _promptController.text = text;
        });
      },
    );
  }
}

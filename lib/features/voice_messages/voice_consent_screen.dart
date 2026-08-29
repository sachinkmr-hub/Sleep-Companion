import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VoiceConsentScreen extends ConsumerStatefulWidget {
  const VoiceConsentScreen({super.key});

  @override
  ConsumerState<VoiceConsentScreen> createState() => _VoiceConsentScreenState();
}

class _VoiceConsentScreenState extends ConsumerState<VoiceConsentScreen> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        title: const Text('Voice Consent', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1F36),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Permission to use voice',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'This voice recording will be used to play personalized wake-up and sleep messages. The recording is stored on this device only.',
              style: TextStyle(fontSize: 16, color: Color(0xFF8B9DC3), height: 1.5),
            ),
            const SizedBox(height: 32),
            CheckboxListTile(
              value: _agreed,
              onChanged: (val) => setState(() => _agreed = val ?? false),
              title: const Text(
                'I confirm that the person has given permission to use their voice in this app',
                style: TextStyle(color: Colors.white),
              ),
              activeColor: const Color(0xFFF5C842),
              checkColor: const Color(0xFF0A0E1A),
              contentPadding: EdgeInsets.zero,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _agreed ? () {
                // Save consent and pop
                Navigator.of(context).pop();
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5C842),
                foregroundColor: const Color(0xFF0A0E1A),
                disabledBackgroundColor: Colors.grey,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Grant Permission', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

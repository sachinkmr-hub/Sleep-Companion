import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neend_companion/features/voice_messages/voice_controller.dart';

class VoiceLibraryScreen extends ConsumerWidget {
  const VoiceLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voicesState = ref.watch(voiceControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        title: const Text('Voice Library', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1F36),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/voice/record'),
          ),
        ],
      ),
      body: voicesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
        data: (voices) {
          if (voices.isEmpty) {
            return const Center(child: Text('No voice messages recorded yet.', style: TextStyle(color: Color(0xFF8B9DC3))));
          }
          return ListView.builder(
            itemCount: voices.length,
            itemBuilder: (context, index) {
              final voice = voices[index];
              return Card(
                color: const Color(0xFF1A1F36),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(voice.personName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('\${voice.relationship} • \${voice.durationSeconds}s', style: const TextStyle(color: Color(0xFF8B9DC3))),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_arrow, color: Color(0xFFF5C842)),
                        onPressed: () {
                          // Play voice
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          ref.read(voiceControllerProvider.notifier).deleteVoice(voice.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class TtsService {
  Future<void> speak(
    String text, {
    String? language,
    double? pitch,
    double? rate,
  }) async {
    // Stub implementation for now
    // In a real app, this would use a package like flutter_tts
    print('Speaking: $text');
  }

  Future<void> stop() async {
    // Stub
  }

  Future<bool> isAvailable() async {
    return true; // Stub
  }

  Future<void> configureVoice(String voiceName) async {
    // Stub
  }
}

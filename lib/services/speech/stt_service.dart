class SttService {
  Future<void> startListening(
    Function(String) onResult, {
    String? locale,
  }) async {
    // Stub implementation
    // Would use speech_to_text package
    print('Started listening...');
  }

  Future<void> stopListening() async {
    // Stub
    print('Stopped listening.');
  }

  Future<bool> isAvailable() async {
    return true; // Stub
  }

  Future<bool> handlePermissions() async {
    return true; // Stub
  }
}

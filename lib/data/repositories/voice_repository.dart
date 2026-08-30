import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:neend_companion/models/voice_message.dart';
import 'package:neend_companion/models/voice_consent.dart';

class VoiceRepository {
  static const String _messagesBox = 'voice_messages';
  static const String _consentBox = 'voice_consents';

  Future<Box> _getMessagesBox() async {
    if (!Hive.isBoxOpen(_messagesBox)) {
      return await Hive.openBox(_messagesBox);
    }
    return Hive.box(_messagesBox);
  }
  
  Future<Box> _getConsentBox() async {
    if (!Hive.isBoxOpen(_consentBox)) {
      return await Hive.openBox(_consentBox);
    }
    return Hive.box(_consentBox);
  }

  Future<List<VoiceMessage>> getMessages() async {
    try {
      final box = await _getMessagesBox();
      final List<dynamic> data = box.values.toList();
      return data.map((e) => VoiceMessage.fromJson(jsonDecode(e.toString()))).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveMessage(VoiceMessage message) async {
    try {
      final box = await _getMessagesBox();
      await box.put(message.id, jsonEncode(message.toJson()));
    } catch (e) {}
  }

  Future<VoiceConsent?> getConsent() async {
    try {
      final box = await _getConsentBox();
      final data = box.get('consent');
      if (data != null) {
        return VoiceConsent.fromJson(jsonDecode(data.toString()));
      }
    } catch (e) {}
    return null;
  }

  Future<void> saveConsent(VoiceConsent consent) async {
    try {
      final box = await _getConsentBox();
      await box.put('consent', jsonEncode(consent.toJson()));
    } catch (e) {}
  }

  Future<void> saveVoiceMessage(VoiceMessage message) => saveMessage(message);

  Future<void> clearAll() async {
    try {
      final messagesBox = await _getMessagesBox();
      await messagesBox.clear();
      final consentBox = await _getConsentBox();
      await consentBox.clear();
    } catch (e) {}
  }
}

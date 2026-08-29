import 'package:flutter/material.dart';
import 'package:neend_companion/services/speech/stt_service.dart';

class VoiceInputSheet extends StatefulWidget {
  final ValueChanged<String>? onTextCaptured;

  const VoiceInputSheet({super.key, this.onTextCaptured});

  @override
  State<VoiceInputSheet> createState() => _VoiceInputSheetState();
}

class _VoiceInputSheetState extends State<VoiceInputSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final SttService _sttService = SttService();
  final TextEditingController _textController = TextEditingController();
  
  String _transcribedText = "";
  bool _isListening = false;
  bool _isSttAvailable = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _initSttAndListen();
  }

  Future<void> _initSttAndListen() async {
    _isSttAvailable = await _sttService.isAvailable();
    if (_isSttAvailable) {
      _startListening();
    } else {
      if (mounted) {
        setState(() {
          _transcribedText = "";
        });
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textController.dispose();
    _sttService.stopListening();
    super.dispose();
  }

  Future<void> _startListening() async {
    setState(() {
      _isListening = true;
    });
    _pulseController.repeat(reverse: true);

    try {
      await _sttService.startListening((recognizedWords) {
        if (mounted) {
          setState(() {
            _transcribedText = recognizedWords;
            _textController.text = recognizedWords;
          });
        }
      });
    } catch (_) {
      _stopListening();
    }
  }

  Future<void> _stopListening() async {
    await _sttService.stopListening();
    if (mounted) {
      setState(() {
        _isListening = false;
      });
      _pulseController.stop();
    }
  }

  void _finish() {
    final text = _textController.text.trim().isNotEmpty
        ? _textController.text.trim()
        : _transcribedText.trim();
    if (widget.onTextCaptured != null) {
      widget.onTextCaptured!(text);
    }
    Navigator.pop(context, text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1F36),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF2D3554),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _isListening ? "Listening to your voice..." : "Tap mic or type reflection",
            style: const TextStyle(
              color: Color(0xFFE8ECF4),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _textController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            onChanged: (val) => _transcribedText = val,
            decoration: InputDecoration(
              hintText: "Speak or type your reflection (e.g. Aaj office me stress tha, kal 5 baje running pe jaana hai)...",
              hintStyle: const TextStyle(color: Color(0xFF5A6E8C), fontSize: 14),
              filled: true,
              fillColor: const Color(0xFF0A0E1A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _isListening ? _stopListening : _startListening,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isListening ? 1.0 + (_pulseController.value * 0.1) : 1.0,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: _isListening ? const Color(0xFFF5C842) : const Color(0xFF0A0E1A),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFF5C842),
                        width: 2,
                      ),
                      boxShadow: _isListening
                          ? [
                              BoxShadow(
                                color: const Color(0xFFF5C842).withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: _pulseController.value * 8,
                              )
                            ]
                          : [],
                    ),
                    child: Icon(
                      _isListening ? Icons.stop : Icons.mic,
                      size: 38,
                      color: _isListening ? const Color(0xFF0A0E1A) : const Color(0xFFF5C842),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _isListening ? "Tap to pause" : "Tap to speak",
            style: const TextStyle(color: Color(0xFF8B9DC3), fontSize: 12),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8B9DC3),
                    side: const BorderSide(color: Color(0xFF2D3554)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(0, 48),
                  ),
                  child: const Text("Cancel"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _finish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5C842),
                    foregroundColor: const Color(0xFF0A0E1A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(0, 48),
                  ),
                  child: const Text("Done", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

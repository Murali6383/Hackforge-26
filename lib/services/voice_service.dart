// lib/services/voice_service.dart
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceAlertService {
  late stt.SpeechToText _speech;
  bool _isListening = false;

  VoiceAlertService() {
    _speech = stt.SpeechToText();
  }

  /// One-time voice listening after SOS pressed
  Future<void> listenOnce() async {
    if (_isListening) return; // Prevent multiple sessions

    bool available = await _speech.initialize(
      onError: (error) => print("Voice SOS error: $error"),
      onStatus: (status) => print("Voice SOS status: $status"),
    );

    if (!available) {
      print("Speech recognition not available");
      return;
    }

    _isListening = true;

    _speech.listen(
      listenFor: Duration(seconds: 5), // Stops automatically
      onResult: (val) {
        String command = val.recognizedWords.toLowerCase();
        print("Voice detected: $command");
        if (command.contains("help me") || command.contains("emergency")) {
          print("SOS voice command detected!");
          // Placeholder: add actual alert later
        }
      },
      cancelOnError: true,
      partialResults: false,
    );

    _speech.stop();
    _isListening = false;
  }
}
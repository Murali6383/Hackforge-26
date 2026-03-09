import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// 8. Drop-in ready to integrate with an existing Flutter app.
class VoiceAlertService {
  // 1. Use the 'speech_to_text' package to listen for voice commands.
  final SpeechToText _speechToText;
  bool _isInitialized = false;
  bool _isListening = false;
  bool _keepListening = false;
  
  // Timer to automatically restart listening if it stops
  Timer? _restartTimer;
  DateTime? _lastTriggerTime;

  void Function(String matchedPhrase)? _onCommandDetected;
  List<String> _triggerPhrases = const ['help', 'emergency'];

  VoiceAlertService({SpeechToText? speechToText})
      : _speechToText = speechToText ?? SpeechToText();

  bool get isListening => _isListening;

  /// Initialize speech recognition
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speechToText.initialize(
        onStatus: _onStatus,
        onError: _onError,
      );
    } catch (e) {
      debugPrint("Voice SOS: Error during initialization - $e");
    }
    return _isInitialized;
  }

  /// Start the continuous listening session
  Future<void> startContinuousListening({
    required void Function(String matchedPhrase) onCommandDetected,
    List<String> triggerPhrases = const ['help', 'emergency'],
  }) async {
    _onCommandDetected = onCommandDetected;
    _triggerPhrases = triggerPhrases;

    if (_keepListening) return;
    _keepListening = true;
    await _startListeningSession();
  }

  /// 5. Listener should run continuously, restarting automatically after each detection or if stopped.
  Future<void> _startListeningSession() async {
    if (!_keepListening) return;

    if (_isListening) {
      debugPrint("Voice SOS: Already listening, skipping start.");
      return;
    }

    final ready = await initialize();
    if (!ready) {
      debugPrint("Voice SOS: Plugin not available. Retrying...");
      _scheduleRestart(const Duration(seconds: 2));
      return;
    }

    try {
      debugPrint("Voice SOS: Starting listening session...");
      _isListening = true;

      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(hours: 1),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        cancelOnError: false,
        listenMode: ListenMode.dictation,
      );
    } catch (e) {
      debugPrint("Voice SOS exception while starting listen: $e");
      _isListening = false;
      if (_keepListening) {
        _scheduleRestart(const Duration(seconds: 1));
      }
    }
  }

  /// 2. Detect phrases like "help" or "1"
  /// 3. When detected, automatically trigger the existing SOS button
  /// 6. Include console debug prints for "detected phrase"
  void _onSpeechResult(SpeechRecognitionResult result) {
    if (result.recognizedWords.isEmpty) return;

    final spokenText = result.recognizedWords.toLowerCase().trim();
    debugPrint('Voice SOS detected phrase: \'$spokenText\'');

    final normalizedPhrases = _triggerPhrases.map((p) => p.toLowerCase()).toList();

    for (final phrase in normalizedPhrases) {
      if (spokenText.contains(phrase)) {
        final now = DateTime.now();
        
        // Cooldown to prevent multiple triggers from one sentence
        if (_lastTriggerTime != null &&
            now.difference(_lastTriggerTime!) < const Duration(seconds: 5)) {
          return;
        }

        debugPrint("Voice SOS: Trigger phrase '$phrase' detected!");
        _lastTriggerTime = now;

        // Stop current listening session temporarily
        _speechToText.stop();
        _isListening = false;

        // Fire the callback
        _onCommandDetected?.call(phrase);

        // Resume listening automatically after a short delay
        if (_keepListening) {
          debugPrint("Voice SOS: Resuming after SOS trigger...");
          _scheduleRestart(const Duration(seconds: 5));
        }
        return;
      }
    }
  }

  /// 6. Include console debug prints for "status"
  void _onStatus(String status) {
    debugPrint("Voice SOS status: $status");

    if (status == 'done' || status == 'notListening') {
      _isListening = false;
      if (_keepListening) {
        _scheduleRestart(const Duration(milliseconds: 500));
      }
    }
  }

  /// 4. Ensure the listener handles errors like 'error_busy' and does not start multiple sessions simultaneously
  /// 6. Include console debug prints for "error"
  void _onError(SpeechRecognitionError error) {
    debugPrint("Voice SOS error: ${error.errorMsg}");
    
    _isListening = false;

    if (_keepListening) {
      if (error.errorMsg.contains('error_busy')) {
        debugPrint("Voice SOS: Plugin busy (multiple sessions). Retrying shortly...");
        _scheduleRestart(const Duration(milliseconds: 800));
      } else {
        _scheduleRestart(const Duration(seconds: 1));
      }
    }
  }

  /// 7. Provide comments explaining each step
  void _scheduleRestart([Duration delay = const Duration(seconds: 2)]) {
    _restartTimer?.cancel();
    
    _restartTimer = Timer(delay, () {
      if (_keepListening && !_isListening) {
        debugPrint("Voice SOS: Auto-restarting continuous listening...");
        _startListeningSession();
      }
    });
  }

  /// Start listening helper method
  Future<void> startListening({
    required void Function(String matchedPhrase) onCommandDetected,
    List<String> triggerPhrases = const ['help', 'emergency'],
  }) async {
    await startContinuousListening(
      onCommandDetected: onCommandDetected,
      triggerPhrases: triggerPhrases,
    );
  }

  /// Stop listening manually
  Future<void> stopListening() async {
    debugPrint("Voice SOS: Stopping listening session manually.");
    _keepListening = false;
    _restartTimer?.cancel();
    
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
    }
  }

  Future<void> dispose() async {
    await stopListening();
    await _speechToText.cancel();
  }
}

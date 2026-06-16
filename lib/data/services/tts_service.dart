import 'package:flutter_tts/flutter_tts.dart';

/// Service that provides text-to-speech functionality for language details.
///
/// Uses Flutter TTS to read aloud language information when a marker
/// is tapped on the map. Designed as a singleton to avoid creating
/// multiple TTS engine instances.
class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;

  TtsService._internal();

  bool get isSpeaking => _isSpeaking;

  /// Initialize the TTS engine with soothing voice settings.
  ///
  /// Uses a slightly lower pitch and moderate-fast rate for a calm,
  /// clear delivery similar to AI assistant voices.
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Use British English for a smoother, more polished accent
    await _flutterTts.setLanguage('en-GB');

    // Faster rate for natural conversational pace (0.5 = default, 0.55 = slightly faster)
    await _flutterTts.setSpeechRate(0.55);

    await _flutterTts.setVolume(1.0);

    // Slightly lower pitch for a warmer, more soothing tone
    await _flutterTts.setPitch(0.9);

    // On web (Chrome), try to select the smoothest available voice
    // "Google UK English Female" is the closest to a soothing AI voice
    try {
      final voices = await _flutterTts.getVoices;
      if (voices != null && voices is List) {
        // Prefer Google UK English Female > Google US English > any en voice
        final preferredNames = [
          'Google UK English Female',
          'Google US English',
          'Microsoft Zira',
          'Samantha',
        ];

        Map<String, dynamic>? bestVoice;
        for (final preferred in preferredNames) {
          for (final voice in voices) {
            if (voice is Map && voice['name']?.toString().contains(preferred) == true) {
              bestVoice = Map<String, dynamic>.from(voice);
              break;
            }
          }
          if (bestVoice != null) break;
        }

        if (bestVoice != null) {
          await _flutterTts.setVoice({
            'name': bestVoice['name'].toString(),
            'locale': bestVoice['locale']?.toString() ?? 'en-GB',
          });
        }
      }
    } catch (_) {
      // Voice selection is best-effort; fall back to default
    }

    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
    });

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    _flutterTts.setCancelHandler(() {
      _isSpeaking = false;
    });

    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
    });

    _isInitialized = true;
  }

  /// Speak the provided text. Stops any current speech first.
  Future<void> speak(String text) async {
    try {
      await initialize();
      await stop();
      _isSpeaking = true;
      await _flutterTts.speak(text);
    } catch (_) {
      // SpeechSynthesis may fail on web if browser blocks it
      _isSpeaking = false;
    }
  }

  /// Stop current speech.
  Future<void> stop() async {
    _isSpeaking = false;
    try {
      await _flutterTts.stop();
    } catch (_) {
      // Ignore stop errors
    }
  }

  /// Generate a natural-sounding description for a language.
  static String buildLanguageDescription({
    required String name,
    required String family,
    required String endangeredStatus,
    required String countryRegion,
    required double latitude,
    required double longitude,
  }) {
    final buffer = StringBuffer();

    buffer.write('$name. ');
    buffer.write('This language belongs to the $family family. ');
    buffer.write('It is spoken in $countryRegion. ');

    // Describe endangerment status naturally
    switch (endangeredStatus.toLowerCase()) {
      case 'not endangered':
        buffer.write('This language is currently not endangered. ');
        break;
      case 'threatened':
        buffer.write('This language is classified as threatened. ');
        break;
      case 'shifting':
        buffer.write(
            'This language is shifting, meaning fewer people are learning it. ');
        break;
      case 'moribund':
        buffer.write(
            'This language is moribund, with very few remaining speakers. ');
        break;
      case 'nearly extinct':
        buffer.write(
            'This language is nearly extinct, with only a handful of speakers left. ');
        break;
      case 'extinct':
        buffer.write('This language is unfortunately extinct. ');
        break;
      default:
        buffer.write('Its endangerment status is $endangeredStatus. ');
    }

    buffer.write(
        'Located at coordinates ${latitude.toStringAsFixed(2)} latitude, '
        '${longitude.toStringAsFixed(2)} longitude.');

    return buffer.toString();
  }

  /// Dispose of the TTS engine.
  Future<void> dispose() async {
    await stop();
    _isInitialized = false;
  }
}

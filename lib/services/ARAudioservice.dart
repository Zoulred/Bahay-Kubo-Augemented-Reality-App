import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _backgroundPlayer = AudioPlayer();
  final AudioPlayer _soundEffectPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  bool _isMuted = false;
  bool _soundsEnabled = true;
  bool _isTTSActive = false;

  // REDUCED background music volume (from 0.7 to 0.4)
  double _originalBackgroundVolume = 0.4; // Lower volume for background music

  // Slightly increased sound effects to balance with lower background
  double _soundEffectVolume = 0.15; // Slightly increased from 0.1

  // Background music methods
  Future<void> playBackgroundMusic() async {
    try {
      await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);

      // Set the reduced initial volume
      await _backgroundPlayer.setVolume(_originalBackgroundVolume);

      // Optional: Reduce the audio file's inherent volume by using audio processing
      // This is handled at the volume level
      await _backgroundPlayer.play(AssetSource('audio/bahay-1.mp3'));
      _isPlaying = true;
    } catch (e) {
      print('Error playing background music: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      await _backgroundPlayer.stop();
      _isPlaying = false;
    } catch (e) {
      print('Error stopping background music: $e');
    }
  }

  Future<void> pauseBackgroundMusic() async {
    try {
      await _backgroundPlayer.pause();
      _isPlaying = false;
    } catch (e) {
      print('Error pausing background music: $e');
    }
  }

  Future<void> resumeBackgroundMusic() async {
    try {
      if (_isTTSActive) {
        // Keep muted if TTS is still active
        await _backgroundPlayer.setVolume(0.0);
      } else {
        // Resume with the reduced volume
        await _backgroundPlayer.setVolume(_originalBackgroundVolume);
      }
      await _backgroundPlayer.resume();
      _isPlaying = true;
    } catch (e) {
      print('Error resuming background music: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      // Apply a 40% reduction to whatever volume is set
      _originalBackgroundVolume = volume * 0.6;

      // Only set volume if TTS is not active
      if (!_isTTSActive) {
        await _backgroundPlayer.setVolume(_originalBackgroundVolume);
      }
    } catch (e) {
      print('Error setting volume: $e');
    }
  }

  Future<void> toggleMute() async {
    try {
      if (_isMuted) {
        // Only unmute if TTS is not active
        if (!_isTTSActive) {
          await _backgroundPlayer.setVolume(_originalBackgroundVolume);
        }
        _isMuted = false;
      } else {
        await _backgroundPlayer.setVolume(0.0);
        _isMuted = true;
      }
    } catch (e) {
      print('Error toggling mute: $e');
    }
  }

  // TTS Control Methods
  Future<void> onTTSStart() async {
    _isTTSActive = true;
    try {
      // Mute background music when TTS starts
      await _backgroundPlayer.setVolume(0.0);
    } catch (e) {
      print('Error muting background for TTS: $e');
    }
  }

  Future<void> onTTSComplete() async {
    _isTTSActive = false;
    try {
      // Restore background music volume if not muted
      if (!_isMuted && _isPlaying) {
        await _backgroundPlayer.setVolume(_originalBackgroundVolume);
      }
    } catch (e) {
      print('Error restoring volume after TTS: $e');
    }
  }

  // Text-to-Speech Methods
  Future<void> speak(String text, {double speechRate = 0.5}) async {
    try {
      // Mute background music before speaking
      await onTTSStart();

      // Configure TTS
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(speechRate);
      await _flutterTts.setVolume(1.0);

      // Speak the text
      await _flutterTts.speak(text);

      // Wait for completion
      _flutterTts.setCompletionHandler(() async {
        await onTTSComplete();
      });

      // Handle errors
      _flutterTts.setErrorHandler((msg) async {
        print("TTS Error: $msg");
        await onTTSComplete();
      });
    } catch (e) {
      print('Error with TTS: $e');
      await onTTSComplete();
    }
  }

  Future<void> stopTTS() async {
    try {
      await _flutterTts.stop();
      await onTTSComplete();
    } catch (e) {
      print('Error stopping TTS: $e');
    }
  }

  Future<void> setTTSSpeechRate(double rate) async {
    try {
      await _flutterTts.setSpeechRate(rate);
      // You can use this to adjust audio behavior based on speech rate if needed
      // For example, lower background volume more for slower speech
      if (rate < 1.0 && _isTTSActive) {
        // Extra quiet for slow speech
        await _backgroundPlayer.setVolume(0.0);
      }
    } catch (e) {
      print('Error setting TTS speech rate: $e');
    }
  }

  // Click sound methods - increased volume slightly to compensate for lower background
  Future<void> playClickSound() async {
    if (!_soundsEnabled) return;

    try {
      await _soundEffectPlayer.setVolume(_soundEffectVolume);
      await _soundEffectPlayer.play(AssetSource('audio/click.mp3'));
    } catch (e) {
      print('Error playing click sound: $e');
    }
  }

  Future<void> playTapSound() async {
    if (!_soundsEnabled) return;

    try {
      await _soundEffectPlayer.setVolume(_soundEffectVolume);
      await _soundEffectPlayer.play(AssetSource('audio/tap.mp3'));
    } catch (e) {
      print('Error playing tap sound: $e');
    }
  }

  Future<void> playButtonSound() async {
    if (!_soundsEnabled) return;

    try {
      await _soundEffectPlayer.setVolume(_soundEffectVolume);
      await _soundEffectPlayer.play(AssetSource('audio/button.mp3'));
    } catch (e) {
      print('Error playing button sound: $e');
    }
  }

  Future<void> playSuccessSound() async {
    if (!_soundsEnabled) return;

    try {
      await _soundEffectPlayer.setVolume(_soundEffectVolume);
      await _soundEffectPlayer.play(AssetSource('audio/success.mp3'));
    } catch (e) {
      print('Error playing success sound: $e');
    }
  }

  Future<void> playErrorSound() async {
    if (!_soundsEnabled) return;

    try {
      await _soundEffectPlayer.setVolume(_soundEffectVolume);
      await _soundEffectPlayer.play(AssetSource('audio/error.mp3'));
    } catch (e) {
      print('Error playing error sound: $e');
    }
  }

  // Sound controls
  void enableSounds() => _soundsEnabled = true;
  void disableSounds() => _soundsEnabled = false;
  void toggleSounds() => _soundsEnabled = !_soundsEnabled;

  // Volume controls for sound effects
  Future<void> setSoundEffectVolume(double volume) async {
    _soundEffectVolume =
        volume.clamp(0.0, 1.0); // Ensure volume is between 0 and 1
  }

  // New method to adjust background music volume specifically
  Future<void> setBackgroundVolume(double volume) async {
    try {
      // Apply additional reduction for background music specifically
      double reducedVolume = volume * 0.2; // 40% reduction
      _originalBackgroundVolume =
          reducedVolume.clamp(0.0, 0.5); // Max 0.5 for background

      if (!_isTTSActive && !_isMuted) {
        await _backgroundPlayer.setVolume(_originalBackgroundVolume);
      }
    } catch (e) {
      print('Error setting background volume: $e');
    }
  }

  bool get isPlaying => _isPlaying;
  bool get isMuted => _isMuted;
  bool get soundsEnabled => _soundsEnabled;
  bool get isTTSActive => _isTTSActive;
  double get soundEffectVolume => _soundEffectVolume;
  double get backgroundVolume => _originalBackgroundVolume;

  void dispose() {
    _backgroundPlayer.dispose();
    _soundEffectPlayer.dispose();
    _flutterTts.stop();
  }
}

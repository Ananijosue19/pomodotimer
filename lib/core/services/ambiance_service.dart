import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

enum AmbianceType { none, rain, whiteNoise, forest }

class AmbianceService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  AmbianceType _currentType = AmbianceType.none;
  double _volume = 0.5;

  AmbianceType get currentType => _currentType;
  double get volume => _volume;

  AmbianceService() {
    _player.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> setAmbiance(AmbianceType type) async {
    if (_currentType == type) return;
    
    _currentType = type;
    await _player.stop();

    if (type != AmbianceType.none) {
      String fileName;
      switch (type) {
        case AmbianceType.rain:
          fileName = 'sounds/rain.mp3';
          break;
        case AmbianceType.whiteNoise:
          fileName = 'sounds/white_noise.mp3';
          break;
        case AmbianceType.forest:
          fileName = 'sounds/forest.mp3';
          break;
        default:
          return;
      }
      
      try {
        await _player.play(AssetSource(fileName));
        await _player.setVolume(_volume);
      } catch (e) {
        debugPrint("Erreur lecture audio: $e");
        // En cas d'erreur (assets manquants), on repasse à none
        _currentType = AmbianceType.none;
      }
    }
    notifyListeners();
  }

  void setVolume(double volume) {
    _volume = volume;
    _player.setVolume(volume);
    notifyListeners();
  }

  void stop() {
    _player.stop();
    _currentType = AmbianceType.none;
    notifyListeners();
  }
}

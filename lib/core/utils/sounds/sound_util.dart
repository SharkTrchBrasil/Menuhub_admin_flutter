// lib/core/utils/sounds/sound_alert_util.dart

import 'package:audioplayers/audioplayers.dart';

class SoundAlertUtil {
  // Player para sons únicos (notificação de novo pedido)
  static final AudioPlayer _notificationPlayer = AudioPlayer();

  // Player separado para o som de alerta em loop
  static final AudioPlayer _loopingPlayer = AudioPlayer();
  static bool _isLooping = false;

  static const String _soundAsset = 'assets/sounds/notification.mp3';

  // O audioplayers não precisa de um `initialize()` explícito, mas manter o método não prejudica.
  static Future<void> initialize() async {
    // Configura o player de loop para repetir o som
    await _loopingPlayer.setReleaseMode(ReleaseMode.loop);
  }

  static Future<void> playNewOrderSound() async {
    try {
      await _notificationPlayer.play(AssetSource(_soundAsset.replaceFirst('assets/', '')));
    } catch (e) {
      print('Erro ao tocar som de novo pedido: $e');
    }
  }

  static Future<void> startLoopingSound() async {
    if (_isLooping) return;
    _isLooping = true;
    print('[SOM] Iniciando som de alerta em loop...');
    try {
      await _loopingPlayer.play(AssetSource(_soundAsset.replaceFirst('assets/', '')));
    } catch (e) {
      print('Erro ao iniciar loop de som: $e');
      _isLooping = false;
    }
  }

  static Future<void> stopLoopingSound() async {
    if (!_isLooping) return;
    _isLooping = false;
    print('[SOM] Parando som de alerta em loop.');
    if (_loopingPlayer.state == PlayerState.playing) {
      await _loopingPlayer.stop();
    }
  }

  static void dispose() {
    _notificationPlayer.dispose();
    _loopingPlayer.dispose();
  }
}
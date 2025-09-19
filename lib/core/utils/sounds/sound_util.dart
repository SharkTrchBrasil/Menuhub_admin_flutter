import 'package:audioplayers/audioplayers.dart';

class SoundAlertUtil {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isPlaying = false;

  static Future<void> playNewOrderSound() async {
    if (_isPlaying) return;

    try {
      _isPlaying = true;
      // Para web, use o caminho correto (pode precisar estar em "web/assets/sounds/")
      await _player.play(AssetSource('sounds/order.wav'));

      _player.onPlayerComplete.listen((_) {
        _isPlaying = false;
      });
    } catch (e) {
      print('Erro ao tocar som: $e');
      _isPlaying = false;
    }
  }
}
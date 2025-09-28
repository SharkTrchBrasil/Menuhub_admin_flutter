import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/widgets.dart';

/// Retorna `true` se a plataforma atual for Android ou iOS.
bool get isMobileDevice {
  // Se for web, não é um dispositivo móvel nativo.
  if (kIsWeb) return false;

  // Verifica se a plataforma é Android ou iOS.
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}
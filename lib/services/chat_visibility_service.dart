// lib/services/chat_visibility_service.dart
import 'package:flutter/foundation.dart';

class ChatVisibilityService {
  final ValueNotifier<bool> isCentralPanelVisible = ValueNotifier(false);

  void setPanelVisibility(bool isVisible) {
    isCentralPanelVisible.value = isVisible;
  }
}
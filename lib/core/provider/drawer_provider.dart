// lib/providers/drawer_provider.dart

import 'package:flutter/foundation.dart';

/// ✅ Provider simples para controlar expansão/colapso do drawer
/// Substitui completamente o GetX
class DrawerProvider extends ChangeNotifier {
  bool _isExpanded = true;

  bool get isExpanded => _isExpanded;

  void toggle() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }

  void expand() {
    if (!_isExpanded) {
      _isExpanded = true;
      notifyListeners();
    }
  }

  void collapse() {
    if (_isExpanded) {
      _isExpanded = false;
      notifyListeners();
    }
  }
}
import 'package:flutter/material.dart';

class DrawerControllerProvider with ChangeNotifier {
  bool _isExpanded = true;

  bool get isExpanded => _isExpanded;

  void toggle() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }

  void expand() {
    _isExpanded = true;
    notifyListeners();
  }

  void collapse() {
    _isExpanded = false;
    notifyListeners();
  }

  void set(bool value) {
    _isExpanded = value;
    notifyListeners();
  }
}

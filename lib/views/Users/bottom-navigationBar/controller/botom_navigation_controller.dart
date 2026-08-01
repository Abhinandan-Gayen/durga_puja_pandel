import 'package:flutter/material.dart';

class AppShellController extends ChangeNotifier {
  int _selectedIndex = 0;
  final Set<int> _saved = {0, 2};

  int get selectedIndex => _selectedIndex;
  Set<int> get saved => _saved;

  void setIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void toggleSaved(int value) {
    if (_saved.contains(value)) {
      _saved.remove(value);
    } else {
      _saved.add(value);
    }
    notifyListeners();
  }
}
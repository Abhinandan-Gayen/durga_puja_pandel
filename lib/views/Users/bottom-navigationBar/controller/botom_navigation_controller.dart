import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AppShellController extends ChangeNotifier {
  AppShellController() {
    final storedIndexes = _favoritesBox.get(
      _savedIndexesKey,
      defaultValue: <dynamic>[],
    );
    if (storedIndexes is Iterable) {
      _saved.addAll(storedIndexes.whereType<int>());
    }
  }

  static const String _savedIndexesKey = 'savedPandalIndexes';
  final Box<dynamic> _favoritesBox = Hive.box<dynamic>('favoritePandals');
  int _selectedIndex = 0;
  final Set<int> _saved = <int>{};

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
    unawaited(_favoritesBox.put(_savedIndexesKey, _saved.toList()));
    notifyListeners();
  }
}

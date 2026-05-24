import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:lifetours/models/firestore_constants.dart';
import 'package:lifetours/providers/auth_provider.dart';

class SettingsProvider extends ChangeNotifier {
  final AuthProvider _authProvider;

  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('es');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isEnglish => _locale.languageCode == 'en';

  SettingsProvider(this._authProvider) {
    _load();
    _authProvider.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    if (_authProvider.isAuthenticated) {
      _loadFromFirestore();
    }
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final dark = prefs.getBool('dark_mode') ?? false;
    final lang = prefs.getString('language') ?? 'es';
    _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    _locale = Locale(lang);
    notifyListeners();
  }

  Future<void> _loadFromFirestore() async {
    final uid = _authProvider.uid;
    if (uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirestoreCollections.users)
          .doc(uid)
          .get();
      if (!doc.exists) return;
      final data = doc.data()!;
      final dark = data[UserFields.darkMode] as bool? ?? false;
      final lang = data[UserFields.language] as String? ?? 'es';
      _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
      _locale = Locale(lang);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('dark_mode', dark);
      await prefs.setString('language', lang);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _saveToFirestore() async {
    final uid = _authProvider.uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance
          .collection(FirestoreCollections.users)
          .doc(uid)
          .update({
        UserFields.darkMode: isDarkMode,
        UserFields.language: _locale.languageCode,
      });
    } catch (_) {}
  }

  Future<void> setDarkMode(bool value) async {
    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
    await _saveToFirestore();
  }

  Future<void> setLanguage(String lang) async {
    _locale = Locale(lang);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    await _saveToFirestore();
  }

  void toggleDarkMode() => setDarkMode(!isDarkMode);
  void toggleLanguage() => setLanguage(isEnglish ? 'es' : 'en');

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthChanged);
    super.dispose();
  }
}

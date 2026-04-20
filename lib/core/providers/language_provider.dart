import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  static const String _englishCode = 'en';
  static const String _marathiCode = 'mr';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  bool get isMarathi => _locale.languageCode == _marathiCode;

  LanguageProvider() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final saved = await _storage.read(key: _languageKey);
      if (saved != null) {
        _locale = Locale(saved);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    try {
      await _storage.write(key: _languageKey, value: locale.languageCode);
    } catch (_) {}
  }

  Future<void> toggleLanguage() async {
    final newLocale = isMarathi
        ? const Locale(_englishCode)
        : const Locale(_marathiCode);
    await setLocale(newLocale);
  }

  /// Returns a tappable language toggle widget for use in AppBars.
  Widget buildToggleWidget({Color textColor = Colors.black}) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: toggleLanguage,
        child: Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isMarathi ? "मराठी | English" : "English | मराठी",
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

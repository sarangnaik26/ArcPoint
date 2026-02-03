import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppAccentColor {
  green,
  orange,
  yellow,
  blue,
  purple,
  red,
  pink,
  golden;

  FlexScheme get scheme {
    switch (this) {
      case AppAccentColor.green:
        return FlexScheme.money;
      case AppAccentColor.orange:
        return FlexScheme.deepOrangeM3;
      case AppAccentColor.yellow:
        return FlexScheme.amber;
      case AppAccentColor.blue:
        return FlexScheme.blue;
      case AppAccentColor.purple:
        return FlexScheme.deepPurple;
      case AppAccentColor.red:
        return FlexScheme.red;
      case AppAccentColor.pink:
        return FlexScheme.sakura;
      case AppAccentColor.golden:
        return FlexScheme.yellowM3;
    }
  }

  String get displayName {
    return name[0].toUpperCase() + name.substring(1);
  }
}

class ThemeProvider with ChangeNotifier {
  AppAccentColor _accentColor = AppAccentColor.blue;
  ThemeMode _themeMode = ThemeMode.dark;

  AppAccentColor get accentColor => _accentColor;
  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final accentIndex = prefs.getInt('accent_color');
    final themeIndex = prefs.getInt('theme_mode');

    if (accentIndex != null &&
        accentIndex >= 0 &&
        accentIndex < AppAccentColor.values.length) {
      _accentColor = AppAccentColor.values[accentIndex];
    }

    if (themeIndex != null &&
        themeIndex >= 0 &&
        themeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[themeIndex];
    }
    notifyListeners();
  }

  Future<void> setAccentColor(AppAccentColor color) async {
    _accentColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accent_color', color.index);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
  }

  Future<void> toggleThemeMode() async {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', _themeMode.index);
  }

  ThemeData get lightTheme => FlexThemeData.light(
    scheme: _accentColor.scheme,
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 7,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 10,
      blendOnColors: false,
      useMaterial3Typography: true,
      useM2StyleDividerInM3: true,
      alignedDropdown: true,
      useInputDecoratorThemeInDialogs: true,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
  );

  ThemeData get darkTheme => FlexThemeData.dark(
    scheme: _accentColor.scheme,
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 13,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 20,
      useMaterial3Typography: true,
      useM2StyleDividerInM3: true,
      alignedDropdown: true,
      useInputDecoratorThemeInDialogs: true,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
  );
}

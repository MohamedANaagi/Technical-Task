import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Manages app theme mode (light / dark / system) and persists the choice.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs) : super(_readThemeMode(_prefs));

  final SharedPreferences _prefs;

  static ThemeMode _readThemeMode(SharedPreferences prefs) {
    final value = prefs.getString(AppConstants.themeModeKey);
    if (value == null) return ThemeMode.system;
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  void setThemeMode(ThemeMode mode) {
    _prefs.setString(AppConstants.themeModeKey, mode.name);
    _applyStatusBar(mode);
    emit(mode);
  }

  void _applyStatusBar(ThemeMode mode) {
    final isDark = switch (mode) {
      ThemeMode.light => false,
      ThemeMode.dark => true,
      ThemeMode.system =>
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark,
    };
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );
  }

  /// Call once after app start so status bar matches saved theme.
  void applySavedTheme() {
    _applyStatusBar(state);
  }
}

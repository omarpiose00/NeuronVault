import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_ai_flutter/providers/theme_provider.dart';

void main() {
  test('initial state is correct', () {
    final themeProvider = ThemeProvider(false);
    expect(themeProvider.isDarkMode, isFalse);
    expect(themeProvider.themeMode, ThemeMode.light);
  });

  test('toggleTheme changes isDarkMode', () async {
    final themeProvider = ThemeProvider(false);
    await themeProvider.toggleTheme();
    expect(themeProvider.isDarkMode, isTrue);
  });

  test('themeMode returns correct ThemeMode based on isDarkMode', () {
    final lightThemeProvider = ThemeProvider(false);
    expect(lightThemeProvider.themeMode, ThemeMode.light);

    final darkThemeProvider = ThemeProvider(true);
    expect(darkThemeProvider.themeMode, ThemeMode.dark);
  });

  test('lightTheme returns a ThemeData with light colors', () {
    final themeProvider = ThemeProvider(false);
    final lightTheme = themeProvider.lightTheme;
    expect(lightTheme.brightness, Brightness.light);
    // Add more assertions for specific theme properties
  });

  test('darkTheme returns a ThemeData with dark colors', () {
    final themeProvider = ThemeProvider(true);
    final darkTheme = themeProvider.darkTheme;
    expect(darkTheme.brightness, Brightness.dark);
    // Add more assertions for specific theme properties
  });
}
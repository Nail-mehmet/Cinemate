
import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Color(0xFF121212), // Koyu kart zeminleri
    primary: Color(0xFF6EE2F5), // Açık mavi vurgular
    secondary: Color(0xFFE0E6ED), // Derin lacivert alt vurgu
    tertiary: Color(0xFF001F3F), // Dengeleyici koyu mavi/gri
    inversePrimary: Color(0xFF345d64), // Açık metinler vs.
  ),
  scaffoldBackgroundColor: Color(0xFF0D1117), // Derin gece tonu
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF0D1117),
    elevation: 0,
    iconTheme: IconThemeData(color: Color(0xFF6EE2F5)),
    titleTextStyle: TextStyle(
      color: Color(0xFF6EE2F5),
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  iconTheme: IconThemeData(color: Color(0xFFB0C4DE)),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Color(0xFFB0BEC5)),
  ),
);

/*
import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Color(0xFF121212), // Koyu kart zeminleri
    primary: Color(0xFF6EE2F5), // Açık mavi vurgular
    secondary: Color(0xFF001F3F), // Derin lacivert alt vurgu
    tertiary: Color(0xFF2C3E50), // Dengeleyici koyu mavi/gri
    inversePrimary: Color(0xFFFFFFFF), // Açık metinler vs.
  ),
  scaffoldBackgroundColor: Color(0xFF0D1117), // Derin gece tonu
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF0D1117),
    elevation: 0,
    iconTheme: IconThemeData(color: Color(0xFF6EE2F5)),
    titleTextStyle: TextStyle(
      color: Color(0xFF6EE2F5),
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  iconTheme: IconThemeData(color: Color(0xFFB0C4DE)),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Color(0xFFB0BEC5)),
  ),
);

 */
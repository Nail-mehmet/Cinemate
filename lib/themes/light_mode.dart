
import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: Color(0xFFF5F5F7), // Lüks kart zemini
    primary: Color(0xFF001F3F), // Ana koyu lacivert
    secondary: Color(0xFF345d64), // Aksiyon ve vurgu (CTA butonlar)
    tertiary: Color(0xFFE0E6ED), // Açık gri (ikon arkaları vs.)
    inversePrimary: Color(0xFF6EE2F5), // Vurgular için koyu ton
  ),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    iconTheme: IconThemeData(color: Color(0xFF001F3F)),
    titleTextStyle: TextStyle(
      color: Color(0xFF001F3F),
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  iconTheme: IconThemeData(color: Color(0xFF415A77)),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Color(0xFF001F3F)),
    bodyMedium: TextStyle(color: Color(0xFF415A77)),
  ),
);
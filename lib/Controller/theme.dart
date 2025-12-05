import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: const Color.fromARGB(255, 29, 29, 29),
    secondary: Colors.white,
    surface: Colors.white,
    tertiary: const Color.fromARGB(255, 121, 116, 126),
    onTertiary: Colors.white,
    onPrimary: Colors.white,
  )
);
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,

    colorScheme: const ColorScheme.light(
      //  primary: Color.fromARGB(255, 94, 190, 49),
      //       primaryContainer: Color.fromARGB(255, 209, 240, 195), // slightly lighter variant
      //       secondary:Color.fromARGB(255, 94, 190, 49),
      primary: Color.fromARGB(255, 73, 148, 38),
      primaryContainer: Color.fromARGB(
        223,
        229,
        235,
        209,
      ), // slightly lighter variant
      secondary: Color.fromARGB(255, 73, 148, 38),
      secondaryContainer: Color.fromARGB(
        137,
        221,
        234,
        234,
      ), // lighter container
      surface: Color(0xFFFFFFFF),
      error: Color(0xFFE53935),
      onPrimary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFF212121),
      onSurface: Color(0xFF212121),
      onError: Color(0xFFFFFFFF),
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFE9EFDC),
      foregroundColor: Colors.black,
      iconTheme: IconThemeData(color: Colors.black),
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Color.fromARGB(255, 73, 148, 38),
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 73, 148, 38),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      displayMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.black),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.black),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: Color.fromARGB(0, 255, 255, 255),
      labelStyle: TextStyle(color: Color(0xFF212121)),
      selectedColor: Color(0xFFE9EFDC),
      secondaryLabelStyle: TextStyle(color: Colors.white),
      padding: EdgeInsets.symmetric(horizontal: 12),
    ),
    dividerTheme: const DividerThemeData(
      color: Color.fromARGB(255, 230, 229, 229),
      thickness: 1,
      space: 0,
    ),
  );
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: Color.fromARGB(255, 32, 68, 16),
      primaryContainer: Color.fromARGB(
        223,
        229,
        235,
        209,
      ), // slightly lighter variant
      secondary: Color.fromARGB(255, 73, 148, 38),
      secondaryContainer: Color.fromARGB(
        137,
        221,
        234,
        234,
      ), // lighter container
      surface: Color.fromARGB(255, 44, 44, 44),
      error: Color(0xFFE53935),
      onPrimary: Color.fromARGB(255, 148, 148, 148),
      onSecondary: Color(0xFF212121),
      onSurface: Colors.grey,
      onError: Color(0xFFFFFFFF),
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFE9EFDC),
      foregroundColor: Colors.black,
      iconTheme: IconThemeData(color: Colors.black),
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Color.fromARGB(255, 73, 148, 38),
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 73, 148, 38),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displayMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.white),
      bodySmall: TextStyle(fontSize: 14, color: Colors.white),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: Color.fromARGB(0, 255, 255, 255),
      labelStyle: TextStyle(color: Color(0xFF212121)),
      selectedColor: Color(0xFFE9EFDC),
      secondaryLabelStyle: TextStyle(color: Colors.white),
      padding: EdgeInsets.symmetric(horizontal: 12),
    ),
    dividerTheme: const DividerThemeData(
      color: Color.fromARGB(255, 255, 255, 255),
      thickness: 1,
      space: 0,
    ),
  );
}

import 'package:flutter/material.dart';

class FashionStoreTheme {
  static ThemeData get lightTheme => ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: Color.fromARGB(255, 73, 148, 38),
        primaryContainer: Color.fromARGB(255, 236, 243, 219), // slightly lighter variant
        secondary:Color.fromARGB(255, 73, 148, 38),
        secondaryContainer: Color(0xFFF5FDD3), // lighter container
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
        buttonColor:  Color.fromARGB(255, 73, 148, 38),
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:  const Color.fromARGB(255, 73, 148, 38),
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
        color: Color(0xFFEEEEEE),
        thickness: 1,
        space: 0,
      ),
    );

  static ThemeData get darkTheme => ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF63781F),
        primaryContainer: Color(0xFF4A5E17),
        secondary: Color(0xFFEEFBBE),
        secondaryContainer: Color(0xFFCADB99),
        surface: Color(0xFF121212),
        error: Color(0xFFEF5350),
        onPrimary: Color(0xFFFFFFFF),
        onSecondary: Color(0xFF212121),
        onSurface: Color(0xFFFFFFFF),
        onError: Color(0xFF212121),
        brightness: Brightness.dark,
      ),
      // You can also add dark variants of AppBarTheme, textTheme, etc. if needed
    );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class AppTheme {
  // Define your color palette
  static const Color primaryColor = Color(0xFF0074A6); // Primary color
  static const Color accentColor = Color(0xFFF9D14A); // Accent color
  static const Color lightBackgroundColor = Colors.white;
  static const Color darkBackgroundColor = Color(0xFF2D3D88);
  static const Color lightTextColor = Colors.black;
  static const Color darkTextColor = Colors.white70;

  // Button style
  static final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    textStyle: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  );

  // Light theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: lightBackgroundColor,
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: createMaterialColor(primaryColor),
      accentColor: accentColor,
      brightness: Brightness.light,
      backgroundColor: lightBackgroundColor,
    ),
    textTheme: _buildTextTheme(Brightness.light),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: elevatedButtonStyle),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentColor,
    ),
    bottomNavigationBarTheme: _buildBottomNavigationBarTheme(
      backgroundColor: lightBackgroundColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
    ),
  );

  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: createMaterialColor(primaryColor),
      accentColor: accentColor,
      brightness: Brightness.dark,
      backgroundColor: darkBackgroundColor,
    ),
    textTheme: _buildTextTheme(Brightness.dark),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBackgroundColor,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: elevatedButtonStyle),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentColor,
    ),
    bottomNavigationBarTheme: _buildBottomNavigationBarTheme(
      backgroundColor: primaryColor,
      selectedItemColor: accentColor,
      unselectedItemColor: Colors.white30,
    ),
  );

  // Helper method to create a TextTheme based on brightness
  static TextTheme _buildTextTheme(Brightness brightness) {
    final Color textColor = brightness == Brightness.light ? lightTextColor : darkTextColor;

    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: textColor,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        color: brightness == Brightness.light ? Colors.grey[600] : Colors.grey[400],
      ),
    );
  }

  // Helper method to create a BottomNavigationBarThemeData based on colors
  static BottomNavigationBarThemeData _buildBottomNavigationBarTheme({
    required Color backgroundColor,
    required Color selectedItemColor,
    required Color unselectedItemColor,
  }) {
    return BottomNavigationBarThemeData(
      backgroundColor: backgroundColor,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    );
  }

  // Utility method to create a MaterialColor from a single Color
  static MaterialColor createMaterialColor(Color color) {
    List<double> strengths = <double>[.05];
    final Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}

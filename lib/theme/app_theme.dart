import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,

      primarySwatch: Colors.indigo,

      scaffoldBackgroundColor: Color(0xff0b1020),
    );
  }
}

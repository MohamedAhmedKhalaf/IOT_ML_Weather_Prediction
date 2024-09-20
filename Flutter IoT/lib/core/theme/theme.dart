import 'package:flutter/material.dart';

class ApplicationTheme {
  static ThemeData lightMode = ThemeData(
      textTheme: TextTheme(
    titleLarge: TextStyle(
        fontWeight: FontWeight.bold, fontSize: 30, color: Colors.black),
    bodyMedium: TextStyle(
        fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
    //bodyLarge: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color:Colors.black),
    bodySmall: TextStyle(
        fontWeight: FontWeight.w500, fontSize: 18, color: Colors.black),
  ));
}


import "package:flutter/material.dart";

import 'screens/role/role.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF1A1A1A)),
        bodyMedium: TextStyle(color: Color(0xFF616161)),
        headlineSmall: TextStyle(color: Color(0xFF0D47A1), 
        fontWeight: FontWeight.bold),
  ),

  scaffoldBackgroundColor: Color(0xFFF5F5F5),
  appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF0D47A1),
        foregroundColor: Colors.white,
         elevation: 0,
  ),

  colorScheme: ColorScheme.light(
    primary: Color(0xFF0D47A1),   // Royal Blue
    secondary: Color(0xFFFF6F00), // Orange
    tertiary: Color(0xFF00C853),  // Green
    background: Color(0xFFF5F5F5),
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Colors.black,
  ),



      ),
      debugShowCheckedModeBanner: false,
      home: Role(),
    );
  }
}

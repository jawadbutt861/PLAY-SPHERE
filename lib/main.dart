

// import "package:f_y_p/screens/login/login.dart";
import "package:f_y_p/screens/manager signup/manager_signup.dart";
import "package:f_y_p/screens/user%20home/user_home.dart";
// import "package:f_y_p/screens/role/role.dart";
// import "package:f_y_p/screens/user%20signup/user_signup.dart";
import "package:flutter/material.dart";

// import 'screens/role/role.dart';

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



// const Color kPrimaryColor = Color(0xFFFF7043);     // Coral  
// const Color kSecondaryColor = Color(0xFF26A69A);   // Aqua  
// const Color kBackgroundColor = Color(0xFFFFF8E1);  // Off White  
// const Color kSurfaceColor = Color(0xFFFFFFFF);     // White  
// const Color kAccentColor = Color(0xFFFFD54F);      // Yellow  
// const Color kTextPrimary = Color(0xFF4E342E);      // Dark Brown  
// const Color kTextSecondary = Color(0xFF757575);    // Gray



      ),
      debugShowCheckedModeBanner: false,
      home: Userhome(),
    );
  }
}

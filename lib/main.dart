
import "package:f_y_p/screens/login/login.dart";
import "package:f_y_p/screens/manager%20home/manager_home.dart";
import "package:f_y_p/screens/manager%20signup/manager_signup.dart";
import "package:f_y_p/screens/role/role.dart";
import "package:f_y_p/screens/routes/routes.dart";
import "package:f_y_p/screens/user%20home/user_home.dart";
import "package:f_y_p/screens/user%20signup/user_signup.dart";
import "package:flutter/material.dart";

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/' : (context) => Role(),
        '/ManagerSignUp' : (context) => ManagerSignup(),
        '/UserSignUp' : (context) => UserSignup(),
        '/LogIn' : (context) => Login(),
        '/UserHome' : (context) => Userhome(),
        '/ManagerHome' : (context) => Managerhome()

      },

    );
  }
}



// const Color kPrimaryColor = Color(0xFFFF7043);     // Coral
// const Color kSecondaryColor = Color(0xFF26A69A);   // Aqua
// const Color kBackgroundColor = Color(0xFFFFF8E1);  // Off White
// const Color kSurfaceColor = Color(0xFFFFFFFF);     // White
// const Color kAccentColor = Color(0xFFFFD54F);      // Yellow
// const Color kTextPrimary = Color(0xFF4E342E);      // Dark Brown
// const Color kTextSecondary = Color(0xFF757575);    // Gray


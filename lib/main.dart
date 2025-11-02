
import "package:f_y_p/screens/manager%20login/manager_login.dart";
import "package:f_y_p/screens/user%20login/user_login.dart";
import "package:f_y_p/screens/manager%20home/manager_home.dart";
import "package:f_y_p/screens/manager%20signup/manager_signup.dart";
import "package:f_y_p/screens/role/role.dart";
import "package:f_y_p/screens/user%20pages/booking/booking.dart";
import "package:f_y_p/screens/user%20pages/categories/categories.dart";
import "package:f_y_p/screens/user%20pages/tournament/tournament%20form/tournament%20form.dart";
import "package:f_y_p/screens/user%20pages/user%20home/booking%20history/booking%20history.dart";
import "package:f_y_p/screens/user%20pages/user%20home/calender/calender.dart";
import "package:f_y_p/screens/user%20pages/user%20home/favourite/favourite.dart";
import "package:f_y_p/screens/user%20pages/user%20home/home.dart";
import "package:f_y_p/screens/user%20pages/user%20home/profile.dart";
import "package:f_y_p/screens/user%20pages/user_main.dart";
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
        '/UserLogIn' : (context) => UserLogin(),
        '/ManagerLogIn' : (context) => ManagerLogin(),
        '/UserMain' : (context) => UserMain(),
        '/ManagerHome' : (context) => Managerhome(),
        '/Categories' : (context) => Categories(),
        '/Favourite' : (context) => Favourite(),
        '/Booking' : (context) => Booked(), 
        '/Home' : (context) => Home(),
        '/Calender' : (context) => Calender(),
        '/BookingHistory' : (context) => BookingHistory(),
        '/TournamentForm' : (context) => TournamentForm(),
        '/Profile' : (context) => Profile(),
     

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

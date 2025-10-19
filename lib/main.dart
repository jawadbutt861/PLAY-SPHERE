import 'package:f_y_p/screens/manager signup/manager_signup.dart';
import 'package:f_y_p/screens/role/role.dart';
import 'package:f_y_p/screens/user home/user_home.dart';
import 'package:f_y_p/screens/login/login.dart';
import 'package:f_y_p/screens/user signup/user_signup.dart';
import 'package:f_y_p/screens/user%20home/user_home.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UserSignup(),
    );
  }
}

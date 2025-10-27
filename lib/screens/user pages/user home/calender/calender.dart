import 'package:flutter/material.dart';

class Calender extends StatefulWidget {
  const Calender({super.key});

  @override
  State<Calender> createState() => _CalenderState();
}

class _CalenderState extends State<Calender> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Calender", style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold),),
        backgroundColor: Color(0xFF26A69A),
      ),
    );
  }
}
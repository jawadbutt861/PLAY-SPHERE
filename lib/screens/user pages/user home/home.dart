import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
   return ListView(
    children: [
      Container(
        width: 700,
        height: 300,
   
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/images/sportitems.jpg")),
          color: Colors.white,
        ),
        child: ElevatedButton(
          onPressed: (){

          }, 
        child: Text("Book Venue",style: TextStyle(
          fontSize: 18
        ),)
        ),
      ),

    ],
   );
   
  }
}
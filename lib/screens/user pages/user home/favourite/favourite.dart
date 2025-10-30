import 'package:flutter/material.dart';

class Favourite extends StatefulWidget {
const Favourite({super.key});

@override
State<Favourite> createState() => _FavouriteState();
}

class _FavouriteState extends State<Favourite> {

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: Text("Favourite Venues", style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold),),
backgroundColor: Color(0xFF26A69A)
),

);
}
}
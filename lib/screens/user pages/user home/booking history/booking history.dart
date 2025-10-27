import 'package:flutter/material.dart';

class BookingHistory extends StatefulWidget {
  const BookingHistory({super.key});

  @override
  State<BookingHistory> createState() => _BookingHistoryState();
}

class _BookingHistoryState extends State<BookingHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Booking History", style: TextStyle(
          fontSize: 18, 
          fontWeight: FontWeight.bold),),
        backgroundColor: Color(0xFF26A69A),
      ),
    );
  }
}
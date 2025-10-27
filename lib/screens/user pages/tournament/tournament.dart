import 'package:flutter/material.dart';

class Tournament extends StatefulWidget {
  const Tournament({super.key});

  @override
  State<Tournament> createState() => _TournamentState();
}

class _TournamentState extends State<Tournament> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body:ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200,40)
                ),
                onPressed: (){
                  Navigator.pushNamed(context, '/TournamentForm');
              
              }, child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 2,
                children: [
                  Text("Create Tournament",style: TextStyle(
                fontSize: 18,
                color: Color(0xFF757575),
                fontWeight: FontWeight.bold
              ),),
              Icon(Icons.arrow_outward_outlined,color: Color(0xFF757575),size: 25,)
                ],
              )
              ),

      
    
    );
  }
}
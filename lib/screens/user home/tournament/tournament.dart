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
      body: ListView(
        children: [
          // Container(
          //   margin: EdgeInsets.all(20),
          //   width: double.infinity,
          //   height: 60,
          //   child: Form(child: TextFormField(
          //     decoration: InputDecoration(
          //       prefixIcon: Icon(Icons.search,color:Color(0xFFFF7043),size: 25, ),
          //       hintText: "Search Tournament",
          //       hintStyle: TextStyle(
          //                   color: Color(0xFF757575)
          //               ),
          //       enabledBorder: OutlineInputBorder(
          //                   borderSide: BorderSide(color: Color(0xFF26A69A),width: 2),
          //                   borderRadius: BorderRadius.circular(10)
          //               ),
          //               focusedBorder: OutlineInputBorder(
          //                   borderSide: BorderSide(color: Color(0xFF26A69A),width: 2),
          //                   borderRadius: BorderRadius.circular(10)
          //               ),
          //               focusedErrorBorder: OutlineInputBorder(
          //                   borderSide: BorderSide(color: Color(0xFF26A69A),width: 2),
          //                   borderRadius: BorderRadius.circular(10)
          //               ),
          //               errorBorder: OutlineInputBorder(
          //                   borderSide: BorderSide(color: Colors.redAccent,width: 2),
          //                   borderRadius: BorderRadius.circular(10)
          //               ),
                
          //     ),
          //   )),
          // ),
          Container(
        
            margin: EdgeInsets.all(20),
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              image:DecorationImage(image: AssetImage('assets/images/tournament.jpg'),fit: BoxFit.cover,opacity: 1),
              border: BoxBorder.all(color: Color(0xFF26A69A),width: 2),
              borderRadius: BorderRadius.circular(10)
            ),
            child: Column(
              children: [
                SizedBox(height: 130,),
                  ElevatedButton(
                    
                    onPressed: (){
                      Navigator.pushNamed(context, '/TournamentForm');
                    }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF7043),
                      minimumSize: Size(300, 50)
                      
                      
                    ),
                    child: Text("Create Tournament",style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 18
                    ),))
              ],
            ),
          ),
          Center(
            child: Text("Ongoing Tournaments",style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF757575)
            ),),
          )
        ],
      ),
    );
  }
}
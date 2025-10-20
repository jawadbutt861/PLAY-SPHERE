import 'package:flutter/material.dart';

class Role extends StatefulWidget {
  const Role({super.key});

  @override
  State<Role> createState() => _RoleState();
}

class _RoleState extends State<Role> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeData().scaffoldBackgroundColor,
      body: ListView(
        children: [
          SizedBox(height: 100,),

          Center(
            child: Text("Choose Your Role",style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize:30
            ),),
          ),

          SizedBox(height: 50,),

          GestureDetector(

            onTap: (){
              print("Clicked");

            },

            child: Flexible(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.all(40),
                width: 100,
              
                decoration: BoxDecoration(
                    color: Color(0x80374151),
                  border: Border.all(color: Colors.white,width: 2),
                  borderRadius: BorderRadius.circular(10)
                ),
              
                child: Column(
              
                  spacing: 10,
                  
                  children: [
                    
              
                    Icon(Icons.groups,size: 60,color: Colors.white,),
              
                    Text("Player",style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold
                    ),),
              
                    Text("Find and book venues for your next match",style: TextStyle(
                      fontSize: 15,
                      color: Colors.white
                    ),
              
                    textAlign: TextAlign.center,)
              
                  ],
                ),
              ),
            ),
          ),


          GestureDetector(

            onTap: (){
              print("Clicked");
            },

            child: Flexible(
              flex: 1,

              child: Container(

                padding: EdgeInsets.all(20),
                margin: EdgeInsets.all(40),
                width: 100,

                decoration: BoxDecoration(
                  color: Color(0x80374151),
                    border: Border.all(color: Colors.white,width: 2),
                    borderRadius: BorderRadius.circular(10)
                ),

                child: Column(
                    spacing: 10,
                  children: [
                    Icon(Icons.person,size: 60,color: Colors.white,),
                    Text("Manager",style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold
                    ),),
                    Text("List your venue and manage your bookings",style: TextStyle(
                        fontSize: 15,
                        color: Colors.white

                    ),
                      textAlign: TextAlign.center,)
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

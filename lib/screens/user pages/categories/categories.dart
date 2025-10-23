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

        SizedBox(height: 30,),

        Container(
          margin: EdgeInsets.all(20),
          width: double.infinity,
          height: 320,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: Offset(2, 2)
                
              )
            ]
          ),
          child: Column(
            children: [
              SizedBox(height: 20,),
        Center(
          child: Text("Book Venue",style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4E342E)
          ),),
        ),
        SizedBox(height: 20,),
              Wrap(
                alignment: WrapAlignment.center,
                    
              spacing: 40,
              runSpacing: 10,
              children: [
                Column(
                 spacing: 5,
                  children: [
                        
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 10, 10, 5),
                        
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: Offset(2, 0)
                          )
                        ]
                      ),
                      child: CircleAvatar(
                        
                        backgroundColor: Color(0xFFFFFFFF),
                        radius:30,
                        child: Icon(Icons.sports_cricket_outlined,size: 30,color: Colors.black,),
                      ),
                    ),
                     Text("Cricket",style: TextStyle(
                      color: Color(0xFF757575),
                      fontSize: 12,
                      fontWeight:FontWeight.bold
                     ),)             ],
                        
                ),
                Column(
                 spacing: 5,
                  children: [
                        
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 10, 10, 5),
                        
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: Offset(2, 0)
                          )
                        ]
                      ),
                      child: CircleAvatar(
                        
                        backgroundColor: Color(0xFFFFFFFF),
                        radius:30,
                        child: Icon(Icons.sports_soccer_outlined,size: 30,color: Colors.black,),
                      ),
                    ),
                     Text("Football",style: TextStyle(
                      color: Color(0xFF757575),
                      fontSize: 12,
                      fontWeight: FontWeight.bold
                     ),)             ],
                        
                ),
                        
                Column(
                 spacing: 5,
                  children: [
                        
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 10, 10, 5),
                        
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: Offset(2, 0)
                          )
                        ]
                      ),
                      child: CircleAvatar(
                        
                        backgroundColor: Color(0xFFFFFFFF),
                        radius:30,
                        child: Icon(Icons.sports_tennis_outlined,size: 30,color: Colors.black,),
                      ),
                    ),
                     Text("Tennis",style: TextStyle(
                      color: Color(0xFF757575),
                      fontSize: 12,
                      fontWeight:FontWeight.bold
                     ),)             ],
                        
                ),
                        
                Column(
                 spacing: 5,
                  children: [
                        
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 10, 10, 5),
                        
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: Offset(2, 0)
                          )
                        ]
                      ),
                      child: CircleAvatar(
                        
                        backgroundColor: Color(0xFFFFFFFF),
                        radius:30,
                        child: Icon(Icons.sports_basketball_outlined,size: 30,color: Colors.black,),
                      ),
                    ),
                     Text("Basketball",style: TextStyle(
                      color: Color(0xFF757575),
                      fontSize: 12,
                      fontWeight:FontWeight.bold
                     ),)             ],
                        
                ),
                        
                Column(
                 spacing: 5,
                  children: [
                        
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 10, 10, 5),
                        
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: Offset(2, 0)
                          )
                        ]
                      ),
                      child: CircleAvatar(
                        
                        backgroundColor: Color(0xFFFFFFFF),
                        radius:30,
                        child: Icon(Icons.sports_hockey_outlined,size: 30,color: Colors.black,),
                      ),
                    ),
                     Text("Hockey",style: TextStyle(
                      color: Color(0xFF757575),
                      fontSize: 12,
                      fontWeight:FontWeight.bold
                     ),)             ],
                        
                ),
                        
                Column(
                 spacing: 5,
                  children: [
                        
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 10, 10, 5),
                        
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: Offset(2, 0)
                          )
                        ]
                      ),
                      child: CircleAvatar(
                        
                        backgroundColor: Color(0xFFFFFFFF),
                        radius:30,
                        child: Icon(Icons.sports_volleyball_outlined,size: 30,color: Colors.black,),
                      ),
                    ),
                     Text("Volleyball",style: TextStyle(
                      color: Color(0xFF757575),
                      fontSize: 12,
                      fontWeight:FontWeight.bold
                     ),)             ],
                        
                ),
                        
                        
                
              ],
                        ),
            ],
          ),
        )
      ],
    );
  }
}
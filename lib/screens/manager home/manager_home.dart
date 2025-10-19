import 'package:flutter/material.dart';

class Managerhome extends StatefulWidget {
  const Managerhome({super.key});

  @override
  State<Managerhome> createState() => _HomeState();
}

class _HomeState extends State<Managerhome> {

  int index = 0;
  List<String> bottomNavItems = ["Home","Analytics"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: Text(bottomNavItems[index],style: TextStyle(
            color: Colors.white,
            fontSize: 20
        ),),
        backgroundColor: Color(0x80374151),
        actions: [
          PopupMenuButton(

            color: Color(0x80374151),
            iconColor: Colors.white,
            iconSize: 24,
            onSelected: (value){

            },
            itemBuilder: (context){
              return [
                PopupMenuItem(

                  child: ListTile(
                    title: Text("Profile",style: TextStyle(
                        color: Colors.white,
                        fontSize: 16
                    ),),
                    leading: Icon(Icons.person,weight: 18,color: Colors.white,),
                  ),

                ),

                PopupMenuItem(
                  child: ListTile(
                    title: Text("Settings",style: TextStyle(
                        color: Colors.white,
                        fontSize: 16
                    ),),
                    leading: Icon(Icons.settings,weight: 18,color: Colors.white,),
                  ),
                ),

                PopupMenuItem(
                  child: ListTile(
                    title: Text("Logout",style: TextStyle(
                        color: Colors.white,
                        fontSize: 16
                    ),),
                    leading: Icon(Icons.logout,weight: 18,color: Colors.white,),
                  ),
                )

              ];
            },
          )
        ],
      ),


      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0x80374151),
        // fixedColor: Color(0xFF00A8E8),
        selectedItemColor: Color(0xFF00A8E8),
        selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold
        ),
        unselectedItemColor: Colors.white,
        onTap: (value){
          setState(() {
            index = value;
          });
        },
        currentIndex: index,
        items: [
          BottomNavigationBarItem(
              label: "Home",
              icon: Icon(Icons.home)
          ),
          BottomNavigationBarItem(
              label: "Analytics",
              icon: Icon(Icons.calendar_month)
          ),


        ],
      ),
    );
  }
}

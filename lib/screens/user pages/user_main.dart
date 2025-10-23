import 'package:f_y_p/screens/user%20pages/booking/booking.dart';
import 'package:f_y_p/screens/user%20pages/tournament/tournament.dart';
import 'package:f_y_p/screens/user%20pages/user%20home/home.dart';
import 'package:flutter/material.dart';

class UserMain extends StatefulWidget {
  const UserMain({super.key});

  @override
  State<UserMain> createState() => _UserMainState();
}

class _UserMainState extends State<UserMain> {
      int index = 0;
  List<Widget> userpages = [
    Home(),
    Booking(),
    Tournament()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.white.withAlpha(250),

      appBar: AppBar(
        
       title: Image.asset("assets/images/logo.png",
       height: 120,
       fit: BoxFit.cover,),
       backgroundColor: Color(0xFF26A69A),
       centerTitle: true,
     
       ),
       drawer: Drawer(
        width: 250,
        child: ListView(
          children: [
            Image.asset("assets/images/logo.png",alignment: Alignment.center,),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Profile"),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Setting"),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
            )
          ],
        ),
       ),

      body:userpages[index],
      
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF26A69A),
        selectedItemColor: Color(0xFFFFD54F),
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
              label: "Booking",
              icon: Icon(Icons.calendar_month)
          ),
          BottomNavigationBarItem(
              label: "Tournament",
              icon: Icon(Icons.emoji_events_outlined)
          ),

        ],
      ),

    );
  }
}
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

    // ignore: deprecated_member_use
    return WillPopScope(
      
      onWillPop: () async { 

        if (index != 0) {

          setState(() {
          index = 0; // go back to Home
        });
        
        return false; // stop default back (don’t exit)
        
      } else {
        return true; // exit app
      }
       },
      child: Scaffold(
         backgroundColor: Colors.white,
      
        appBar: AppBar(
          
          leading: IconButton(
            onPressed: (){
                Navigator.pushNamed(context, '/Profile');
            },
           icon: Icon(Icons.person_outline_sharp,color: Color(0xFFFF7043),size: 20,)),
         title: Image.asset("assets/images/logo.png",
         height: 80,
         fit: BoxFit.cover,),
         backgroundColor: Color(0xFF004E89),
         centerTitle: true,
         
         actions: [
          IconButton(
            onPressed: (){
      
          }, 
          icon: Icon(Icons.notifications_none,color: Color(0xFFFF7043),size: 20,))
         ],
       
         ),
        
        body:userpages[index],
        
        bottomNavigationBar: BottomNavigationBar(
           currentIndex: index,
          backgroundColor: Color(0xFF004E89),
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
      
      ),
    );
  }
}
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
      children: [
        Container(
      
          width: 200,
          height: 300,
          margin: EdgeInsets.fromLTRB(20,30,20,20),
          padding: EdgeInsets.fromLTRB(10,30,10,0),
          
      
          decoration: BoxDecoration(
           image:DecorationImage(image: AssetImage('assets/images/bg2.jpg'),fit: BoxFit.cover),
           border: Border.all(
            color: Colors.white,
            width: 2
           ),
           borderRadius: BorderRadius.circular(20)
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200,40)
                ),
                onPressed: (){
                  Navigator.pushNamed(context, '/Categories');
              
              }, child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 2,
                children: [
                  Text("Book Venue",style: TextStyle(
                fontSize: 18,
                color: Color(0xFF757575),
                fontWeight: FontWeight.bold
              ),),
              Icon(Icons.arrow_outward_outlined,color: Color(0xFF757575),size: 25,)
                ],
              )
              ),
              SizedBox(height: 10,)
            ],
          ),
        ),
      
        
        Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
      
            Container(
      
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
      
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 1).withOpacity(0.3),
                    offset: Offset(2, 1) 
                  )
                ]
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 15,
                children: [
                  Icon(Icons.calendar_month,size: 30,),
                  Text("My Calender",textAlign: TextAlign.center,style: TextStyle(
                    color: Color(0xFF757575),
                    fontWeight: FontWeight.bold,
                    fontSize: 12
                  ),)
                ],
              ),
            ),
      
            Container(
      
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
      
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 1).withOpacity(0.3),
                    offset: Offset(2, 1) 
                  )
                ]
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 15,
                children: [
                  Icon(Icons.workspace_premium,size: 30,),
                  Text("Favourite  Venue",textAlign: TextAlign.center,style: TextStyle(
                    color: Color(0xFF757575),
                    fontSize: 12,
                    fontWeight: FontWeight.bold
                  ),)
                ],
              ),
            ),
      
            Container(
      
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
      
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 1).withOpacity(0.3),
                    offset: Offset(2, 1) 
                  )
                ]
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 15,
                children: [
                  Icon(Icons.receipt_long_sharp,size: 30,),
                  Text("Payment History",textAlign: TextAlign.center,style: TextStyle(
                    color: Color(0xFF757575),
                    fontWeight: FontWeight.bold,
                    fontSize: 12
                  ),)
                ],
              ),
            )
          ],
        )
      
      
      ],
         ),
    );
  }
}
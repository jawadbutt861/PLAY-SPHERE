import 'package:flutter/material.dart';

class TournamentForm extends StatefulWidget {
  const TournamentForm({super.key});

  @override
  State<TournamentForm> createState() => _TournamentFormState();
}

class _TournamentFormState extends State<TournamentForm> {

    bool showPass = true;
  int selected = 0;


  final formkey = GlobalKey<FormState>();

  TextEditingController fullName = TextEditingController();
  TextEditingController eMail = TextEditingController();
  TextEditingController cnic = TextEditingController();
  TextEditingController mobileNo = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController role = TextEditingController();
  TextEditingController venueName = TextEditingController();
  TextEditingController venueLocation = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      // body: Flexible(
        
      //     flex: 1,
      //   child: Center(
      //     child: Container(
      //       margin: EdgeInsets.all(20),
      //       height: 700,
      //       width: 400,
      //       decoration: BoxDecoration(
      //         border: Border.all(color: Colors.white),
      //         borderRadius: BorderRadius.circular(20),
      //         color: Colors.white.withAlpha(200)
      //       ),
      //       child: Form(
      //         key: formkey,
      //         child: ListView(
      //         padding: EdgeInsets.all(20),
            
      //           children: [
            
      //             SizedBox(height: 20,),
            
      //             Center(
      //               child: Text("Manager Sign Up",style: TextStyle(
      //                   color: Color(0xFF4E342E),
      //                   fontSize: 25,
      //                   fontWeight: FontWeight.bold
      //               ),),
      //             ),
            
      //             SizedBox(height: 50,),
            
      //             TextFormField(
      //               controller: fullName,
      //               style: TextStyle(
                      
      //                 color: Colors.black,
      //                 ),
      //               keyboardType: TextInputType.name,
      //               decoration: InputDecoration(
      //                 filled: true,
      //                 prefixIcon: Icon(Icons.person,size: 25,),
      //                 prefixIconColor: Color(0xFFFF7043),
      //                 fillColor: Color(0xFFFFFFFF),
      //                 hintText: 'Enter Your Full Name',
      //                 hintStyle: TextStyle(
      //                   color: Color(0xFF757575),
      //                   fontSize: 16
      //                 ),
      //                 labelText: 'Full Name',
      //                 labelStyle: TextStyle(
      //                   color: Color(0xFF757575)
      //                 ),
      //                 enabledBorder: OutlineInputBorder(
      //                   borderSide: BorderSide(color: Color(0xFF26A69A),width: 2),
      //                   borderRadius: BorderRadius.circular(10)
      //                 ),
      //                 focusedBorder: OutlineInputBorder(
      //                   borderSide: BorderSide(color: Color(0xFF26A69A),width: 2),
      //                   borderRadius: BorderRadius.circular(10)
      //                 ),
      //                 focusedErrorBorder: OutlineInputBorder(
      //                     borderSide: BorderSide(color: Color(0xFF26A69A),width: 2),
      //                     borderRadius: BorderRadius.circular(10)
      //                 ),
      //                 errorBorder: OutlineInputBorder(
      //                     borderSide: BorderSide(color: Colors.redAccent,width: 2),
      //                     borderRadius: BorderRadius.circular(10)
      //                 ),
            
      //               ),
            
            
      //               validator: (value){
      //                 if(value == null || value.isEmpty){
      //                   return "Please enter fullname";
      //                 }
      //                 return null;
      //               },
      //             ),
            
      //             SizedBox(height: 30,),
            
      //             TextFormField(
      //               controller: eMail,
      //               style: TextStyle(color: Colors.black),
      //               keyboardType: TextInputType.emailAddress,
      //               decoration: InputDecoration(
      //                   prefixIcon: Icon(Icons.email_outlined,size: 25,),
      //                   prefixIconColor: Color(0xFFFF7043),
      //                   filled: true,
      //                   fillColor: Colors.white,
      //                   hintText: 'Enter Your Email Address',
      //                   hintStyle: TextStyle(
      //                       color: Color(0xFF757575)
      //                   ),
      //                   labelText: 'Email',
      //                   labelStyle: TextStyle(
      //                       color: Color(0xFF757575)
      //                   ),
      //                   enabledBorder: OutlineInputBorder(
      //                       borderSide: BorderSide(color: Color(0xFF26A69A),width: 2),
      //                       borderRadius: BorderRadius.circular(10)
      //                   ),
      //                   focusedBorder: OutlineInputBorder(
      //                       borderSide: BorderSide(color: Color(0xFF26A69A),width: 2),
      //                       borderRadius: BorderRadius.circular(10)
      //                   ),
      //                 focusedErrorBorder: OutlineInputBorder(
      //                     borderSide: BorderSide(color: Color(0xFF26A69A),width: 2),
      //                     borderRadius: BorderRadius.circular(10)
      //                 ),
      //                 errorBorder: OutlineInputBorder(
      //                     borderSide: BorderSide(color: Colors.redAccent,width: 2),
      //                     borderRadius: BorderRadius.circular(10)
      //                 ),
      //               ),
      //               validator: (value){
      //                 if(value == null || value.isEmpty){
      //                   return "Please enter email";
      //                 }
      //                 if(!value.contains('@')){
      //                   return "Invalid email";
      //                 }
      //                 return null;
      //               },
      //             ),
            
      //             SizedBox(height: 30,),

      //             TextFormField(
              
      //         controller: cnic,
      //         style: TextStyle(color: Colors.black),
      //         keyboardType: TextInputType.number,
      //         decoration: InputDecoration(
      //           prefixIcon: Icon(Icons.contact_mail,size: 25,),
      //           prefixIconColor: Color(0xFFFF7043),
      //           filled: true,
      //           fillColor: Colors.white,
      //           hintText: 'Enter CNIC (without dashes)',
      //           hintStyle: TextStyle(
      //               color: Color(0xFF757575)
      //           ),
      //           labelText: 'CNIC',
      //           labelStyle: TextStyle(
      //               color: Color(0xFF757575)
      //           ),
      //           enabledBorder: OutlineInputBorder(
      //               borderSide: BorderSide(color: Color(0xFF26A69A),width: 2),
      //               borderRadius: BorderRadius.circular(10)
      //           ),
      //           focusedBorder: OutlineInputBorder(
      //               borderSide: BorderSide(color: Color(0xFF26A69A),width: 2),
      //               borderRadius: BorderRadius.circular(10)
      //           ),
      //           focusedErrorBorder: OutlineInputBorder(
      //               borderSide: BorderSide(color: Color(0xFF26A69A),width: 2),
      //               borderRadius: BorderRadius.circular(10)
      //           ),
      //           errorBorder: OutlineInputBorder(
      //               borderSide: BorderSide(color: Colors.redAccent,width: 2),
      //               borderRadius: BorderRadius.circular(10)
      //           ),
      //         ),
              
      //         validator: (value){
      //           if(value == null || value.isEmpty){
      //             return "Please enter cnic";
      //           }
      //           if(value.length != 13){
      //             return "Invalid cnic";
      //           }
      //           return null;
      //         },
      //       ),


      //             SizedBox(height: 30,),
            
      //             TextFormField(
      //               controller: mobileNo,
      //               style: TextStyle(color: Colors.black),
      //               keyboardType: TextInputType.number ,
      //               decoration: InputDecoration(
      //                   prefixIcon: Icon(Icons.phone,size: 25,),
      //                   prefixIconColor: Color(0xFFFF7043),
      //                   filled: true,
      //                   fillColor: Colors.white,
      //                   hintText: 'e.g.,0312-4567098',
      //                   hintStyle: TextStyle(
      //                       color: Color(0xFF757575)
      //                   ),
      //                   labelText: 'Mobile No',
      //                   labelStyle: TextStyle(
      //                       color: Color(0xFF757575)
      //                   ),
      //                   enabledBorder: OutlineInputBorder(
      //                       borderSide: BorderSide(color: Color(0xFF26A69A),width: 2),
      //                       borderRadius: BorderRadius.circular(10)
      //                   ),
      //                   focusedBorder: OutlineInputBorder(
      //                       borderSide: BorderSide(color: Color(0xFF26A69A),width: 2),
      //                       borderRadius: BorderRadius.circular(10)
      //                   ),
      //                 focusedErrorBorder: OutlineInputBorder(
      //                     borderSide: BorderSide(color: Color(0xFF26A69A),width: 2),
      //                     borderRadius: BorderRadius.circular(10)
      //                 ),
      //                 errorBorder: OutlineInputBorder(
      //                     borderSide: BorderSide(color: Colors.redAccent,width: 2),
      //                     borderRadius: BorderRadius.circular(10)
      //                 ),
      //               ),
      //               validator: (value){
      //                 if(value == null || value.isEmpty){
      //                   return "Please enter mobile number";
      //                 }
      //                 if(value.length != 11){
      //                   return "Invalid mobile number";
      //                 }
      //                 return null;
      //               },
      //             ),

      //             SizedBox(height: 30,),
            
      //             TextFormField(
      //               controller: venueName,
      //               style: TextStyle(
                      
      //                 color: Colors.black,
      //                 ),
      //               keyboardType: TextInputType.name,
      //               decoration: InputDecoration(
      //                 filled: true,
      //                 prefixIcon: Icon(Icons.business_outlined,size: 25,),
      //                 prefixIconColor: Color(0xFFFF7043),
      //                 fillColor: Color(0xFFFFFFFF),
      //                 hintText: 'Enter Venue Name',
      //                 hintStyle: TextStyle(
      //                   color: Color(0xFF757575),
      //                   fontSize: 16
      //                 ),
      //                 labelText: 'Venue Name',
      //                 labelStyle: TextStyle(
      //                   color: Color(0xFF757575)
      //                 ),
      //                 enabledBorder: OutlineInputBorder(
      //                   borderSide: BorderSide(color: Color(0xFF26A69A),width: 2),
      //                   borderRadius: BorderRadius.circular(10)
      //                 ),
      //                 focusedBorder: OutlineInputBorder(
      //                   borderSide: BorderSide(color: Color(0xFF26A69A),width: 2),
      //                   borderRadius: BorderRadius.circular(10)
      //                 ),
      //                 focusedErrorBorder: OutlineInputBorder(
      //                     borderSide: BorderSide(color: Color(0xFF26A69A),width: 2),
      //                     borderRadius: BorderRadius.circular(10)
      //                 ),
      //                 errorBorder: OutlineInputBorder(
      //                     borderSide: BorderSide(color: Colors.redAccent,width: 2),
      //                     borderRadius: BorderRadius.circular(10)
      //                 ),
            
      //               ),
            
            
      //               validator: (value){
      //                 if(value == null || value.isEmpty){
      //                   return "Please enter venue ";
      //                 }
      //                 return null;
      //               },
      //             ),

      //             SizedBox(height: 30,),
            
      //             TextFormField(
      //               controller: venueLocation,
      //               style: TextStyle(
                      
      //                 color: Colors.black,
      //                 ),
      //               keyboardType: TextInputType.name,
      //               decoration: InputDecoration(
      //                 filled: true,
      //                 prefixIcon: Icon(Icons.location_on,size: 25,),
      //                 prefixIconColor: Color(0xFFFF7043),
      //                 fillColor: Color(0xFFFFFFFF),
      //                 hintText: 'Enter Venue Location',
      //                 hintStyle: TextStyle(
      //                   color: Color(0xFF757575),
      //                   fontSize: 16
      //                 ),
      //                 labelText: 'Venue Location',
      //                 labelStyle: TextStyle(
      //                   color: Color(0xFF757575)
      //                 ),
      //                 enabledBorder: OutlineInputBorder(
      //                   borderSide: BorderSide(color: Color(0xFF26A69A),width: 2),
      //                   borderRadius: BorderRadius.circular(10)
      //                 ),
      //                 focusedBorder: OutlineInputBorder(
      //                   borderSide: BorderSide(color: Color(0xFF26A69A),width: 2),
      //                   borderRadius: BorderRadius.circular(10)
      //                 ),
      //                 focusedErrorBorder: OutlineInputBorder(
      //                     borderSide: BorderSide(color: Color(0xFF26A69A),width: 2),
      //                     borderRadius: BorderRadius.circular(10)
      //                 ),
      //                 errorBorder: OutlineInputBorder(
      //                     borderSide: BorderSide(color: Colors.redAccent,width: 2),
      //                     borderRadius: BorderRadius.circular(10)
      //                 ),
            
      //               ),
            
            
      //               validator: (value){
      //                 if(value == null || value.isEmpty){
      //                   return "Please enter location ";
      //                 }
      //                 return null;
      //               },
      //             ),
            
            
      //             SizedBox(height: 30,),
            
      //             TextFormField(
      //               obscureText: showPass,
      //               style: TextStyle(color: Colors.black),
      //               controller: password,
      //               keyboardType: TextInputType.visiblePassword,
      //               decoration: InputDecoration(
      //                   prefixIcon: Icon(Icons.lock_outline,size: 25,),
      //                   prefixIconColor: Color(0xFFFF7043),
      //                   filled: true,
      //                   fillColor: Colors.white,
      //                   suffixIcon: IconButton(
      //                       onPressed: (){
      //                         setState(() {
      //                           showPass = !showPass;
      //                         });
      //                       },
      //                       icon: Icon(Icons.remove_red_eye_outlined),color: Colors.white,),
      //                   hintText: 'Enter Password',
      //                   hintStyle: TextStyle(
      //                       color: Color(0xFF757575)
      //                   ),
      //                   labelText: 'Password',
      //                   labelStyle: TextStyle(
      //                       color: Color(0xFF757575)
      //                   ),
      //                   enabledBorder: OutlineInputBorder(
      //                       borderSide: BorderSide(color: Color(0xFF26A69A),width: 2),
      //                       borderRadius: BorderRadius.circular(10)
      //                   ),
      //                   focusedBorder: OutlineInputBorder(
      //                       borderSide: BorderSide(color: Color(0xFF26A69A),width: 2),
      //                       borderRadius: BorderRadius.circular(10)
      //                   ),
      //                 focusedErrorBorder: OutlineInputBorder(
      //                     borderSide: BorderSide(color: Color(0xFF26A69A),width: 2),
      //                     borderRadius: BorderRadius.circular(10)
      //                 ),
      //                 errorBorder: OutlineInputBorder(
      //                     borderSide: BorderSide(color: Colors.redAccent,width: 2),
      //                     borderRadius: BorderRadius.circular(10)
      //                 ),
      //               ),
      //               validator: (value){
      //                 if(value == null || value.isEmpty){
      //                   return "Please enter password";
      //                 }
      //                 if(value.length < 8){
      //                   return "Password must be 8 characters or more";
      //                 }
      //                 return null;
      //               },
      //             ),
            
      //             SizedBox(height: 40,),
            
      //             Center(
      //               child: ElevatedButton(
      //                   onPressed: (){
      //                     if(formkey.currentState!.validate()){
      //                       Navigator.pushNamed(context, '/LogIn');
      //                       return;
      //                     }

      //                   },
      //                   style: ElevatedButton.styleFrom(
      //                     backgroundColor: Color(0xFFFF7043),
      //                     minimumSize: Size(220, 50),
            
      //                   ),
            
      //                   child: Text("Create Account",style: TextStyle(
      //                     color: Colors.white,
      //                     fontSize: 20,
      //                     fontWeight: FontWeight.bold
      //                   ),)
      //               ),
      //             ),
            
      //             SizedBox(height: 40,),
            
      //             Row(
      //               mainAxisAlignment: MainAxisAlignment.center,
      //               children: [
      //                 Text("Already have an account?",style: TextStyle(
      //                     color: Color(0xFF757575),
      //                     fontSize: 16
      //                 ),),
      //                 TextButton(
      //                     onPressed: (){
      //                       Navigator.pushNamed(context, '/ManagerLogIn');
      //                     },
      //                     child: Text("Sign in",style: TextStyle(
      //                         fontSize: 16,
      //                         fontWeight: FontWeight.bold,
      //                         color:Colors.blue,
            
      //                     ),))
      //               ],
      //             )
            
            
            
            
            
      //           ],
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
    );
  }
}
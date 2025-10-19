import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';

class UserSignup extends StatefulWidget {
  const UserSignup({super.key});

  @override
  State<UserSignup> createState() => _SignupState();
}

class _SignupState extends State<UserSignup> {
  bool showPass = true;
  int selected = 0;


  final formkey = GlobalKey<FormState>();

  TextEditingController fullName = TextEditingController();
  TextEditingController eMail = TextEditingController();
  TextEditingController cnic = TextEditingController();
  TextEditingController mobileNo = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController role = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,


      body: Form(
        key: formkey,
        child: ListView(

          padding:EdgeInsets.all(20),

          children: [

            SizedBox(height: 20,),

            Center(child: Image.asset('assets/images/logo.png',width: 300,)),


            SizedBox(height: 10,),

            Center(child: Text("Welcome to PlaySphere",style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'assets/fonts/roboto.tff'
            ),)),

            SizedBox(height: 20,),

            Center(
              child: Text("User",style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold
              ),),
            ),

            SizedBox(height: 50,),

            TextFormField(
              controller: fullName,
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                filled: true,
                prefixIcon: Icon(Icons.person,size: 20,),
                prefixIconColor: Colors.white,
                fillColor: Color(0x80374151),
                hintText: 'Enter Your Full Name',
                hintStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 16
                ),
                labelText: 'Full Name',
                labelStyle: TextStyle(
                  color: Colors.white
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white,width: 2),
                  borderRadius: BorderRadius.circular(10)
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white,width: 2),
                  borderRadius: BorderRadius.circular(10)
                ),
                focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white,width: 2),
                    borderRadius: BorderRadius.circular(10)
                ),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white,width: 2),
                    borderRadius: BorderRadius.circular(10)
                ),

              ),


              validator: (value){
                if(value == null || value.isEmpty){
                  return "Please enter fullname";
                }
                return null;
              },
            ),

            SizedBox(height: 30,),

            TextFormField(
              controller: eMail,
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email_outlined,size: 20,),
                  prefixIconColor: Colors.white,
                  filled: true,
                  fillColor: Color(0x80374151),
                  hintText: 'Enter Your Email Address',
                  hintStyle: TextStyle(
                      color: Colors.white
                  ),
                  labelText: 'Email',
                  labelStyle: TextStyle(
                      color: Colors.white
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white,width: 2),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white,width: 2),
                      borderRadius: BorderRadius.circular(10)
                  ),
                focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white,width: 2),
                    borderRadius: BorderRadius.circular(10)
                ),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white,width: 2),
                    borderRadius: BorderRadius.circular(10)
                ),
              ),
              validator: (value){
                if(value == null || value.isEmpty){
                  return "Please enter email";
                }
                if(!value.contains('@')){
                  return "Invalid email";
                }
                return null;
              },
            ),

            SizedBox(height: 30,),

            TextFormField(
              controller: mobileNo,
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.number ,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.phone,size: 20,),
                  prefixIconColor: Colors.white,
                  filled: true,
                  fillColor: Color(0x80374151),
                  hintText: 'e.g.,0312-4567098',
                  hintStyle: TextStyle(
                      color: Colors.white
                  ),
                  labelText: 'Mobile No',
                  labelStyle: TextStyle(
                      color: Colors.white
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white,width: 2),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white,width: 2),
                      borderRadius: BorderRadius.circular(10)
                  ),
                focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white,width: 2),
                    borderRadius: BorderRadius.circular(10)
                ),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white,width: 2),
                    borderRadius: BorderRadius.circular(10)
                ),
              ),
              validator: (value){
                if(value == null || value.isEmpty){
                  return "Please enter mobile number";
                }
                if(value.length != 11){
                  return "Invalid mobile number";
                }
                return null;
              },
            ),

            SizedBox(height: 30,),

            TextFormField(
              obscureText: showPass,
              style: TextStyle(color: Colors.white),
              controller: password,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock_outline,size: 20,),
                  prefixIconColor: Colors.white,
                  filled: true,
                  fillColor: Color(0x80374151),
                  suffixIcon: IconButton(
                      onPressed: (){
                        setState(() {
                          showPass = !showPass;
                        });
                      },
                      icon: Icon(Icons.remove_red_eye_outlined),color: Colors.white,),
                  hintText: 'Enter Password',
                  hintStyle: TextStyle(
                      color: Colors.white
                  ),
                  labelText: 'Password',
                  labelStyle: TextStyle(
                      color: Colors.white
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white,width: 2),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white,width: 2),
                      borderRadius: BorderRadius.circular(10)
                  ),
                focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white,width: 2),
                    borderRadius: BorderRadius.circular(10)
                ),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white,width: 2),
                    borderRadius: BorderRadius.circular(10)
                ),
              ),
              validator: (value){
                if(value == null || value.isEmpty){
                  return "Please enter password";
                }
                if(value.length != 8){
                  return "Password must be 8 characters or more";
                }
                return null;
              },
            ),

            SizedBox(height: 60,),

            Center(
              child: ElevatedButton(
                  onPressed: (){
                    if(formkey.currentState!.validate()){
                     return ;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00A8E8),
                    minimumSize: Size(50, 40),

                  ),

                  child: Text("Sign Up",style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),)
              ),
            ),

            SizedBox(height: 90,),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account?",style: TextStyle(
                    color: Colors.white,
                    fontSize: 16
                ),),
                TextButton(
                    onPressed: (){

                    },
                    child: Text("Sign in",style: TextStyle(
                        fontSize: 16,
                        color:Colors.lightBlue,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.lightBlue

                    ),))
              ],
            )





          ],
        ),
      ),
    );
  }
}

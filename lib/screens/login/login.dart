import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final formkey = GlobalKey<FormState>();

  TextEditingController eMail = TextEditingController();
  TextEditingController password = TextEditingController();

  bool showPass = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Form(
        key: formkey,
        child: ListView(
          padding: EdgeInsets.all(20),
        
          children: [
        
            SizedBox(height: 20,),
        
            Center(child: Image.asset('assets/images/logo.png',width: 300,)),
        
            SizedBox(height: 20,),
        
            Center(child: Text("PlaySphere",style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                fontFamily: 'assets/fonts/roboto.tff'
            ),)),
        
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

            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("Forgot Password?",style: TextStyle(
                  color: Colors.white
                ),)
              ],
            ),

            SizedBox(height: 30,),
            Center(
              child: ElevatedButton(
                  onPressed: (){
                    if(formkey.currentState!.validate()){
                      return;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00A8E8),
                    minimumSize: Size(50, 40),

                  ),

                  child: Text("Log in",style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),)
              ),
            ),
            SizedBox(height: 150,),
            Center(
              child: Text("Not a member?",style: TextStyle(
                color: Colors.white,
                fontSize: 15
              ),),
            ),
            SizedBox(height: 10,),
            Center(
              child: ElevatedButton(
                  onPressed: (){
                    print("To Login Page");
                    },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00A8E8),
                    minimumSize: Size(50, 40),

                  ),

                  child: Text("Create an account",style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),)
              ),
            ),

          ],
        ),
      ),
    );

  }
}

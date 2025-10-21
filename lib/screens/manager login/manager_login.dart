import 'package:flutter/material.dart';

class ManagerLogin extends StatefulWidget {
  const ManagerLogin({super.key});

  @override
  State<ManagerLogin> createState() => _ManagerLoginState();
}

class _ManagerLoginState extends State<ManagerLogin> {
    final formkey = GlobalKey<FormState>();
  TextEditingController eMail = TextEditingController();
  TextEditingController password = TextEditingController();

  bool showPass = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF26A69A),
      body: Form(
        key: formkey,
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color:Colors.white.withAlpha(200),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white,width: 2)
            ),
            width: 400,
            height: 660,
            margin: EdgeInsets.all(20),
            child: ListView(
              padding: EdgeInsets.all(20),
            
              children: [
            
                SizedBox(height: 20,),
            
                Center(child: Text("PlaySphere",style: TextStyle(
                    color: Color(0xFF4E342E),
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    // letterSpacing: 4
                ),)),
            
                SizedBox(height: 50,),
            
                TextFormField(
                  controller: eMail,
                  style: TextStyle(color: Colors.black),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined,size: 25,),
                    prefixIconColor: Color(0xFFFF7043),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Enter Your Email Address',
                    hintStyle: TextStyle(
                        color: Color(0xFF757575)
                    ),
                    labelText: 'Email',
                    labelStyle: TextStyle(
                        color: Color(0xFF757575)
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF26A69A),width: 2),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF26A69A),width: 2),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF26A69A),width: 2),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.redAccent,width: 2),
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
                  style: TextStyle(color: Colors.black),
                  controller: password,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock_outline,size: 25,),
                    prefixIconColor: Color(0xFFFF7043),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      onPressed: (){
                        setState(() {
                          showPass = !showPass;
                        });
                      },
                      icon: Icon(Icons.remove_red_eye_outlined),color: Colors.white,),
                    hintText: 'Enter Password',
                    hintStyle: TextStyle(
                        color: Color(0xFF757575)
                    ),
                    labelText: 'Password',
                    labelStyle: TextStyle(
                        color: Color(0xFF757575)
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF26A69A),width: 2),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF26A69A),width: 2),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF26A69A),width: 2),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.redAccent,width: 2),
                        borderRadius: BorderRadius.circular(10)
                    ),
                  ),
                  validator: (value){
                    if(value == null || value.isEmpty){
                      return "Please enter password";
                    }
                    if(value.length < 8){
                      return "Invalid Password";
                    }
                    return null;
                  },
                ),
            
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Forgot Password?",style: TextStyle(
                      color: Color(0xFF757575)
                    ),)
                  ],
                ),
            
                SizedBox(height: 30,),
                Center(
                  child: ElevatedButton(
                      onPressed: (){
                        if(formkey.currentState!.validate()){
                         Navigator.pushReplacementNamed(context, "/ManagerHome");
                          return;
                        }

                       

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF7043),
                        minimumSize: Size(200, 50),
            
                      ),
            
                      child: Text("Log In",style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),)
                  ),
                ),
                SizedBox(height: 150,),
                Center(
                  child: Text("Not a member?",style: TextStyle(
                    color: Color(0xFF757575),
                    fontSize: 15
                  ),),
                ),
                SizedBox(height: 10,),
                Center(
                  child: ElevatedButton(
                      onPressed: (){
                        Navigator.pop(context);
                        },
            
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF7043),
                        minimumSize: Size(200, 40),
            
                      ),
            
                      child: Text("Create an account",style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),)
                  ),
                ),
            
              ],
            ),
          ),
        ),
      ),

    );
  }
}
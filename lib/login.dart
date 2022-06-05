// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// ignore: use_key_in_widget_constructors, must_be_immutable
class Login extends StatelessWidget {
  // ignore: non_constant_identifier_names
  TextEditingController txt_ctrl_uid=TextEditingController();
  

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xfe212121),
          body: SingleChildScrollView(
            child: Center(
              child:Column(
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  //Text Heading                  
                  Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Row(
                    children: [
                      //User ID Label
                      Container(
                        width: 50,
                        child: Text(
                          "User ID",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18
                          ),)
                      ),
                      //User ID TextBox
                      Expanded(child: TextField(
                        controller: txt_ctrl_uid,
                        style: TextStyle(
                          color: Colors.white
                        ),
                        decoration: InputDecoration(
                          hintText: "Enter your user ID",
                          hintStyle: TextStyle(
                            color: Colors.grey
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                              color: Colors.blue,
                              width: 2
                            ),
                          )
                          )
                        )),
                    ],
                  )
                ]
              )
            ),
      )),
    );
  }
}

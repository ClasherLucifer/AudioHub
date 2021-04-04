import 'package:audiohub/homepage.dart';
import 'package:audiohub/signup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginState();
}

class LoginState extends State<Login> {
  CollectionReference userdata =
      FirebaseFirestore.instance.collection('User Data');

  TextEditingController uidtext = new TextEditingController();
  TextEditingController passwordtext = new TextEditingController();

  String errorMsg = '';
  bool visibleError = false;
  bool hasAccount = false;

  @override
  void initState() {
    //initialiseFlutterFire();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor:
                //Colors.white
                Color(0xfe212121),
            body: SingleChildScrollView(
                child: Center(
              child: Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    children: [
                      /////////////////////////////////////////////////////Login
                      Padding(
                          padding: EdgeInsets.only(top: 30, bottom: 40),
                          child: Text('Login',
                              style: TextStyle(
                                  fontSize: 25, color: Colors.white))),
                      /////////////////////////////////////////////////////Error
                      Visibility(
                          visible: visibleError,
                          child: Padding(
                              padding: EdgeInsets.only(top: 10, bottom: 10),
                              child: Text(
                                errorMsg,
                                style: TextStyle(color: Colors.red),
                              ))),
                      ///////////////////////////////////////////////////user id
                      createFields('User ID', 'Enter your User ID', uidtext),
                      //////////////////////////////////////////////////password
                      createFields('Password', 'Enter password', passwordtext),
                      ////////////////////////////////////////////////////button
                      Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: GestureDetector(
                              onTap: () => signInWithCredentials(
                                  uidtext.text, passwordtext.text, context),
                              child: Container(
                                  alignment: Alignment.center,
                                  width: MediaQuery.of(context).size.width - 20,
                                  height: 50,
                                  //color: Colors.blue,
                                  decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Text('Login',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold))))),
                      //////////////////////////////////////////////////////////
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'New to Audio Hub? ',
                              style: TextStyle(color: Colors.white),
                            ),
                            GestureDetector(
                                onTap: () => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignUp())),
                                child: Text('Sign Up! ',
                                    style: TextStyle(color: Colors.blue)))
                          ],
                        ),
                      ),
                    ],
                  )),
            ))));
  }

////////////////////////////////////////////////////////////////////End of Build
  Widget createFields(
      String description, String hint, TextEditingController controller) {
    return Padding(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        child: Container(
          height: 60,
          child: Row(
            children: [
              Container(
                  width: 90,
                  child: Text(
                    description,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  )),
              Expanded(
                  child: Theme(
                      data: ThemeData(
                        primaryColor: Colors.transparent,
                      ),
                      child: TextField(
                        controller: controller,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            ////////////////////////////////////////////////
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(width: 2, color: Colors.blue)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(width: 2, color: Colors.blue)),
                            disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(width: 2, color: Colors.blue)),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(width: 2, color: Colors.red)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(width: 2, color: Colors.red)),
                            ////////////////////////////////////////////////
                            hintText: hint,
                            hintStyle: TextStyle(color: Colors.grey)),
                      )))
            ],
          ),
        ));
  }

////////////////////////////////////////////////////////////////////////////////
  void signInWithCredentials(
      String uid, String password, BuildContext context) async {
    ///////////////////////////////////////

    ///////////////////////////////////////
    var result = await userdata
        .where('uid', isEqualTo: uid)
        .where('password', isEqualTo: password)
        .get();
    hasAccount = result.docs.isNotEmpty ? true : false;
    if (hasAccount) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage(uid: uid)));
    } else {
      errorMsg = 'Incorrect User ID and/or Password';
      visibleError = true;
      setState(() {});
    }

    ///////////////////////////////////////
  }

////////////////////////////////////////////////////////////////////////////////
  void initialiseFlutterFire() async {
    await Firebase.initializeApp();
  }
////////////////////////////////////////////////////////////////////End of class
}

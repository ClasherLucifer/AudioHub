import 'package:audiohub/homepage.dart';
import 'package:audiohub/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:audiohub/global.dart';

class SignUp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SignUpState();
}

class SignUpState extends State<SignUp> {
  CollectionReference userdata =
      FirebaseFirestore.instance.collection('User Data');

  TextEditingController emailtext = new TextEditingController();
  TextEditingController uidtext = new TextEditingController();
  TextEditingController passwordtext = new TextEditingController();

  final FirebaseAuth auth = FirebaseAuth.instance;
  String errorMsg = '';
  bool visibleError = false;

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
                      ///////////////////////////////////////////////////Sign Up
                      Padding(
                          padding: EdgeInsets.only(top: 30, bottom: 40),
                          child: Text('Sign Up',
                              style: TextStyle(
                                  fontSize: 25, color: Colors.white))),
                      /////////////////////////////////////////////////////error
                      Visibility(
                        visible: visibleError,
                        child: Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: Text(errorMsg,
                              style: TextStyle(color: Colors.red)),
                        ),
                      ),
                      /////////////////////////////////////////////////////email
                      createFields('Email ID', 'Enter your email', emailtext),
                      /////////////////////////////////////////////////user name
                      createFields(
                          'User ID', 'Enter your unique User ID', uidtext),
                      //////////////////////////////////////////////////password
                      createFields('Password', 'Enter password', passwordtext),
                      ////////////////////////////////////////////////////button
                      Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: GestureDetector(
                              onTap: () => createAccount(
                                  emailtext.text.toString(),
                                  uidtext.text,
                                  passwordtext.text.toString(),
                                  context),
                              child: Container(
                                  alignment: Alignment.center,
                                  width: MediaQuery.of(context).size.width - 20,
                                  height: 50,
                                  //color: Colors.blue,
                                  decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Text('Sign Up',
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
                              'Already a user? ',
                              style: TextStyle(color: Colors.white),
                            ),
                            GestureDetector(
                                onTap: () => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Login())),
                                child: Text('Login! ',
                                    style: TextStyle(color: Colors.blue)))
                          ],
                        ),
                      ),
                    ],
                  )),
            ))));
  }

////////////////////////////////////////////////////////////////////End of build
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
  void initialiseFlutterFire() async {
    await Firebase.initializeApp();
  }

////////////////////////////////////////////////////////////////////////////////
  void createAccount(
      String email, String uid, String password, BuildContext context) async {
    ////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////
    if (false)
    {
      errorMsg = 'Please fill up all the fields.';
      visibleError = true;
      setState(() {});
    } else {
      var existingemail = await userdata.where('email', isEqualTo: email).get();
      if (existingemail.docs.isEmpty) //checks if email is already registered
      {
        var existinguser = await userdata.where('uid', isEqualTo: uid).get();
        if (existinguser.docs.isEmpty) //checks if user id already exists
        {
          //if neither email nor uid exist in the collection, create new id
          await userdata.doc(uid).set({
            'email': email,
            'uid': uid,
            'password': password,
            'favourites': []
          }).then((_)
          {
            Global.uid=uid;
            Global.fetchFavourites();
            Navigator
            .pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) => HomePage()));});
        } else {
          errorMsg = 'This User ID already exists!';
          visibleError = true;
          setState(() {});
        }
      } else {
        errorMsg = 'This email ID is already registered!';
        visibleError = true;
        setState(() {});
      }
    }
    ////////////////////////////////////////////////////////////////////////////
  }
////////////////////////////////////////////////////////////////////End of class
}

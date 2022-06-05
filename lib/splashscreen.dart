// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

// ignore: use_key_in_widget_constructors
class Splashscreen extends StatelessWidget{
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 0, 23, 43),
      body: Center(
        child: Column(
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            Text(
              "Audio Hub",
              style: TextStyle(
                color: Colors.white,
                fontSize: 25
              )
            ),
            SizedBox(
              width: 70,
              child:LinearProgressIndicator(
              minHeight: 10,
              color: Colors.blue,
            ))
          ],
        )
      )
    );
  }
  
}
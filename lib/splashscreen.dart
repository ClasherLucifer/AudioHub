import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Center(
      child: Container(
          child: Text(
        'Splash',
        style: TextStyle(fontSize: 30),
      )),
    )));
  }

  //////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////End of class
}

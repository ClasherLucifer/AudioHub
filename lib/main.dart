import 'dart:async';

import 'package:audiohub/homepage.dart';
import 'package:audiohub/login.dart';
import 'package:audiohub/signup.dart';
import 'package:audiohub/splashscreen.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:audiohub/audiopage.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:just_audio/just_audio.dart';

import 'package:marquee_widget/marquee_widget.dart';

import 'globalvariables.dart' as g;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(home: Login()));
}

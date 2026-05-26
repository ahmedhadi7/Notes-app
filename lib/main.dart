import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebasee/coud/addnotes.dart';
import 'package:firebasee/coud/editnodes.dart';
import 'package:firebasee/firebase_options.dart';
import 'package:firebasee/homepage.dart';
import 'package:firebasee/login.dart';
import 'package:firebasee/signup.dart';
import 'package:flutter/material.dart';

bool islogin = false;

@pragma('vm:entry-point')
Future<void> backgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("=======================");
  print("${message.notification?.body}");
  print("=======================");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(backgroundMessage);

  var user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    islogin = true;
  } else {
    islogin = false;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final docid;
  const MyApp({super.key, this.docid});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(),

      home: islogin == false ? Login() : Homepage(),
      routes: {
        "login": (context) => const Login(),
        "signup": (context) => const Signup(),
        "homepage": (context) => const Homepage(),
        "addnotes": (context) => const Addnotes(),
        "editnodes": (context) => Editnodes(docid: docid, list: []),
      },
    );
  }
}

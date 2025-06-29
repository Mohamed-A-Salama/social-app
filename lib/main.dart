import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_day1/pages/home_page.dart';
import 'package:flutter_firebase_day1/pages/login_page.dart';
import 'package:flutter_firebase_day1/pages/profile_page.dart';
import 'package:flutter_firebase_day1/pages/register_page.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // @override
  // void initState() {
  //   FirebaseAuth.instance.authStateChanges().listen((User? user) {
  //     if (user == null) {
  //       print("user is signed out.");
  //     } else {
  //       print("user is signed in");
  //     }
  //   });
  //   // TODO: implement initState
  //   super.initState();
  // }

  Widget checkUserState () {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null){
      return HomePage();
    }else{
      return LoginPage();
    }
}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firebase',
      home: checkUserState(),
      routes: {
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/profile' : (context) => ProfileScreen(),
      },
    );
  }
}

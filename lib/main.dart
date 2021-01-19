import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/Signup_screen.dart';
import 'screens/mails_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './screens/add_mail_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flumail',
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            return Mails();
          }
          return Login();
        },
      ),
      routes: {
        SignUp.routeName: (ctx) => SignUp(),
        Mails.routeName: (ctx) => Mails(),
        AddMailScreen.routeName: (ctx) => AddMailScreen(),
      },
    );
  }
}

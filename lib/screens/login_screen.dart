import 'package:flutter/material.dart';
import 'file:///C:/flutter_practice_projects/gmail_flutter_app/lib/screens/Signup_screen.dart';
import '../variables.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var username = '';
  var password = '';
  bool isLoginStarted = false;
  var _formKey = GlobalKey<FormState>();

  void ontryLogin() async {
    _formKey.currentState.save();
    setState(() {
      isLoginStarted = true;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: username.trim() + '@flumail.com', password: password);
    } catch (e) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          title: Text('Error Occured'),
          content: Text(e.toString()),
        ),
      );
    }
    setState(() {
      isLoginStarted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 190),
              Hero(
                tag: 'flu-mail',
                child: Text(
                  'Flu-Mail',
                  style: myStyle(
                    50,
                    FontWeight.w500,
                    Colors.black.withOpacity(0.77),
                  ),
                ),
              ),
              SizedBox(height: 50),
              PaddedTextField(
                hintText: 'username',
                hidePassword: false,
                onSaveFun: (String value) {
                  username = value;
                },
              ),
              SizedBox(height: 20),
              PaddedTextField(
                hintText: 'password',
                hidePassword: true,
                onSaveFun: (String value) {
                  password = value;
                },
              ),
              SizedBox(height: 30),
              isLoginStarted
                  ? CircularProgressIndicator(backgroundColor: Colors.black)
                  : RaisedButton(
                      onPressed: ontryLogin,
                      child: Text(
                        'Login',
                        style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500),
                      ),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      elevation: 4,
                    ),
              SizedBox(height: 150),
              Text(
                'Don\'t have an account.',
                style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500),
              ),
              FlatButton(
                onPressed: () async {
                  Navigator.of(context).pushNamed(SignUp.routeName);
                },
                child: Text(
                  'Create account',
                  style: GoogleFonts.ubuntu(fontWeight: FontWeight.w700),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

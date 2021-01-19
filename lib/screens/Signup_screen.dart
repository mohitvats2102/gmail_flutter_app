import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../variables.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SignUp extends StatefulWidget {
  static const routeName = '/sign_up';
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  FirebaseAuth auth = FirebaseAuth.instance;
  Firestore firestore = Firestore.instance;
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  File pickedImage;
  bool isSignupStarted = false;
  var formKey = GlobalKey<FormState>();
  var tempPassword = '';
  var username = '';
  var password = '';

  void onWantToTakePic(ImageSource imageSource) async {
    final picker = ImagePicker();
    final image = await picker.getImage(
        source: imageSource, maxHeight: 250, maxWidth: 150, imageQuality: 50);
    if (image == null) return;
    setState(() {
      pickedImage = File(image.path);
    });
    Navigator.pop(context);
    FocusScope.of(context).unfocus();
  }

  void pickImage() {
    showDialog(
        context: context,
        builder: (ctx) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: SimpleDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                children: <Widget>[
                  SimpleDialogOption(
                    onPressed: () {
                      onWantToTakePic(ImageSource.camera);
                    },
                    child: Text(
                      'Open Camera',
                      style: myStyle(17, FontWeight.w500),
                    ),
                  ),
                  SizedBox(height: 10),
                  SimpleDialogOption(
                    onPressed: () {
                      onWantToTakePic(ImageSource.gallery);
                    },
                    child: Text(
                      'Pick From Gallery',
                      style: myStyle(17, FontWeight.w500),
                    ),
                  ),
                  SizedBox(height: 10),
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context);
                      FocusScope.of(context).unfocus();
                    },
                    child: Text(
                      'Cancel',
                      style: myStyle(17, FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ));
  }

  void _trySubmit() async {
    var isValid = formKey.currentState.validate();
    if (pickedImage == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          content: Text('Please pick a profile image'),
          actions: <Widget>[
            FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Ok'),
            )
          ],
        ),
      );
      FocusScope.of(context).unfocus();
      return;
    }
    if (isValid) {
      formKey.currentState.save();
      setState(() {
        isSignupStarted = true;
      });
      try {
        AuthResult authResult = await auth.createUserWithEmailAndPassword(
            email: username.trim() + '@flumail.com', password: password);
        StorageReference ref = firebaseStorage
            .ref()
            .child('user_profile_images')
            .child(authResult.user.uid + '.jpg');
        await ref.putFile(pickedImage).onComplete;
        var imageUrl = await ref.getDownloadURL();

        await firestore
            .collection('users')
            .document(username.trim() + '@flumail.com')
            .setData({
          'username': username,
          'email': username.trim() + '@flumail.com',
          'imageUrl': imageUrl,
        });
      } catch (e) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(Radius.circular(15))),
            title: Text('Error Occured'),
            content: Text(e.toString()),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Ok'),
              )
            ],
          ),
        );
      }
      setState(() {
        isSignupStarted = false;
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 50),
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
              SizedBox(height: 30),
              CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 50,
                backgroundImage: pickedImage == null
                    ? AssetImage('assets/userimage.jpg')
                    : FileImage(pickedImage),
              ),
              FlatButton.icon(
                  onPressed: () {
                    pickImage();
                  },
                  icon: Icon(Icons.image),
                  label: Text('Add Profile Image',
                      style: myStyle(15, FontWeight.w500))),
              SizedBox(height: 10),
              PaddedTextField(
                hidePassword: false,
                hintText: 'username (min 4 char long)',
                validatorFun: (String value) {
                  if (value.isEmpty || value.length < 4) {
                    return 'username must be at least 4 char long';
                  }
                  return null;
                },
                onSaveFun: (String value) {
                  username = value;
                },
              ),
              SizedBox(height: 20),
              PaddedTextField(
                hidePassword: true,
                hintText: 'password (min 8 char long)',
                validatorFun: (String value) {
                  tempPassword = value;
                  if (value.isEmpty || value.length < 8) {
                    return 'password must be at least 8 char long';
                  }
                  return null;
                },
                onSaveFun: (String value) {
                  password = value;
                },
              ),
              SizedBox(height: 20),
              PaddedTextField(
                hidePassword: true,
                hintText: 'Repeat Password',
                validatorFun: (String value) {
                  if (value != tempPassword) {
                    return 'password doesn\'t match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              isSignupStarted
                  ? CircularProgressIndicator(backgroundColor: Colors.black)
                  : RaisedButton(
                      onPressed: _trySubmit,
                      child: Text(
                        'Signup',
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
              SizedBox(height: 70),
              Text(
                'Already have an account.',
                style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Login',
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

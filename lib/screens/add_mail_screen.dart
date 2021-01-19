import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gmail_flutter_app/variables.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class AddMailScreen extends StatefulWidget {
  static const routeName = '/add_mail_screen';
  @override
  _AddMailScreenState createState() => _AddMailScreenState();
}

class _AddMailScreenState extends State<AddMailScreen> {
  File imagePath;
  bool sendingStarted = false;
  TextEditingController _reciever = TextEditingController();
  TextEditingController _subject = TextEditingController();
  TextEditingController _mail = TextEditingController();
  String imageID = Uuid().v4();

  void onWantToTakePic(ImageSource imageSource) async {
    final picker = ImagePicker();
    final image = await picker.getImage(
        source: imageSource, maxHeight: 250, maxWidth: 150, imageQuality: 50);
    if (image == null) return;
    setState(() {
      imagePath = File(image.path);
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

  Future<dynamic> getUploadedAttachmentURL() async {
    StorageReference ref =
        FirebaseStorage.instance.ref().child('attachments').child(imageID);
    await ref.putFile(imagePath).onComplete;
    return ref.getDownloadURL();
  }

  void sendMail() async {
    setState(() {
      sendingStarted = true;
    });
    try {
      CollectionReference userCollection =
          Firestore.instance.collection('users');
      FirebaseUser _currentUser = await FirebaseAuth.instance.currentUser();
      DocumentSnapshot _currentUserData =
          await userCollection.document(_currentUser.email).get();
      var id = userCollection
          .document(_reciever.text)
          .collection('inbox')
          .document()
          .documentID;
      dynamic attachImgURl = imagePath == null
          ? 'No attachment'
          : await getUploadedAttachmentURL();
      await userCollection
          .document(_reciever.text)
          .collection('inbox')
          .document(id)
          .setData({
        'sender': _currentUser.email,
        'reciever': _reciever.text,
        'sub': _subject.text,
        'mail': _mail.text,
        'attachment': attachImgURl,
        'hasred': false,
        'starred': false,
        'id': id,
        'time': DateTime.now(),
        'profilepic': _currentUserData['imageUrl'],
        'username': _currentUserData['username'],
      });
      setState(() {
        sendingStarted = false;
      });
      Navigator.pop(context);
    } catch (e) {
      print(e);
      setState(() {
        sendingStarted = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back, color: Colors.black)),
        backgroundColor: Colors.white,
        title: Text(
          'Compose Mail',
          style: myStyle(20, FontWeight.w500, Colors.black),
        ),
        actions: <Widget>[
          InkWell(
            onTap: pickImage,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Icon(Icons.attach_file, color: Colors.black, size: 26),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: sendMail,
        backgroundColor: Colors.black,
        child: Icon(Icons.send),
      ),
      body: sendingStarted
          ? Center(
              child: CircularProgressIndicator(backgroundColor: Colors.black),
            )
          : Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 15),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.1,
                    width: MediaQuery.of(context).size.height,
                    child: TextField(
                      controller: _reciever,
                      decoration: InputDecoration(
                        hintText: 'To',
                        hintStyle: myStyle(17, FontWeight.w500),
                      ),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.1,
                    width: MediaQuery.of(context).size.height,
                    child: TextField(
                      controller: _subject,
                      decoration: InputDecoration(
                        hintText: 'Subject',
                        hintStyle: myStyle(17, FontWeight.w500),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.1,
                      width: MediaQuery.of(context).size.height,
                      child: TextField(
                        maxLines: null,
                        controller: _mail,
                        decoration: InputDecoration(
                            hintText: 'Mail',
                            hintStyle: myStyle(17, FontWeight.w500),
                            border: InputBorder.none),
                      ),
                    ),
                  ),
                  imagePath == null
                      ? Container()
                      : MediaQuery.of(context).viewInsets.bottom > 0
                          ? Container()
                          : Container(
                              margin: EdgeInsets.only(bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    'Your Attachments',
                                    style: myStyle(
                                        20, FontWeight.w500, Colors.black),
                                  ),
                                  SizedBox(width: 5),
                                  Container(
                                    alignment: Alignment.center,
                                    child: Image.file(imagePath,
                                        width: 100, height: 100),
                                  ),
                                ],
                              ),
                            )
                ],
              ),
            ),
    );
  }
}

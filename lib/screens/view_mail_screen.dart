import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:gmail_flutter_app/variables.dart';
import 'package:flutter/material.dart';

class ViewMailScreen extends StatefulWidget {
  static const routeName = '/view_mail_screen';

  final String id;
  final String sender;
  final Timestamp time;
  final String picture;
  final String mail;
  final String sub;
  final String profilePic;
  final String username;

  ViewMailScreen({
    this.username,
    this.sender,
    this.id,
    this.mail,
    this.picture,
    this.profilePic,
    this.sub,
    this.time,
  });

  @override
  _ViewMailScreenState createState() => _ViewMailScreenState();
}

class _ViewMailScreenState extends State<ViewMailScreen> {
  @override
  void initState() {
    super.initState();
    markAsRead();
  }

  void markAsRead() async {
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    await Firestore.instance
        .collection('users')
        .document(currentUser.email)
        .collection('inbox')
        .document(widget.id)
        .updateData({
      'hasred': true,
    });
  }

  void confirmDelete() {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              title: Text('Confirm Delete!!'),
              content: Text('Are you sure you want to delete this mail.'),
              actions: <Widget>[
                FlatButton(
                    onPressed: () => Navigator.pop(context), child: Text('No')),
                FlatButton(onPressed: () => deleteMail(), child: Text('Yes'))
              ],
            ));
  }

  void deleteMail() async {
    Navigator.pop(context);
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    await Firestore.instance
        .collection('users')
        .document(currentUser.email)
        .collection('inbox')
        .document(widget.id)
        .delete();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back, color: Colors.black),
        ),
        actions: <Widget>[
          InkWell(
            onTap: () {},
            child: Icon(Icons.reply, color: Colors.black),
          ),
          SizedBox(width: 15),
          InkWell(
            onTap: () => confirmDelete(),
            child: Icon(Icons.delete, color: Colors.red),
          ),
          SizedBox(width: 12),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.sub,
                style: myStyle(30, FontWeight.w500),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(widget.profilePic),
                ),
                title: Text(
                  widget.username,
                  style: myStyle(20),
                ),
                trailing: Icon(Icons.reply, color: Colors.black),
              ),
              SizedBox(height: 30),
              Text(
                widget.mail,
                style: myStyle(22),
                softWrap: true,
                overflow: TextOverflow.fade,
              ),
              SizedBox(height: 30),
              Text(
                'Attachment -',
                style: myStyle(20),
              ),
              SizedBox(height: 15),
              widget.picture == 'No attachment'
                  ? Container()
                  : Image.network(
                      widget.picture,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gmail_flutter_app/variables.dart';
import 'add_mail_screen.dart';
import 'package:intl/intl.dart';
import 'view_mail_screen.dart';

class Mails extends StatefulWidget {
  static const routeName = '/mails_screen';
  @override
  _MailsState createState() => _MailsState();
}

class _MailsState extends State<Mails> {
  String currentUserMail;
  String currentUserIMGURL;

  Future<void> getUserData() async {
    FirebaseUser _currentUser = await FirebaseAuth.instance.currentUser();
    var _currentUserData = await Firestore.instance
        .collection('users')
        .document(_currentUser.email)
        .get();

    setState(() {
      currentUserMail = _currentUser.email;
      currentUserIMGURL = _currentUserData['imageUrl'];
    });
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void starMsg(String docID) async {
    DocumentSnapshot docData = await Firestore.instance
        .collection('users')
        .document(currentUserMail)
        .collection('inbox')
        .document(docID)
        .get();

    if (docData['starred'] == false) {
      await Firestore.instance
          .collection('users')
          .document(currentUserMail)
          .collection('inbox')
          .document(docID)
          .updateData({
        'starred': true,
      });
    } else {
      await Firestore.instance
          .collection('users')
          .document(currentUserMail)
          .collection('inbox')
          .document(docID)
          .updateData({
        'starred': false,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          ' Flu-Mail',
          style: myStyle(25, FontWeight.w500, Colors.black),
        ),
        actions: <Widget>[
          InkWell(
            onTap: () {
              FirebaseAuth.instance.signOut();
            },
            child: Container(
              padding: EdgeInsets.all(8),
              height: 60,
              width: 60,
              child: CircleAvatar(
                radius: 25,
                backgroundImage: currentUserIMGURL == null
                    ? AssetImage('assets/userimage.jpg')
                    : NetworkImage(currentUserIMGURL),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          Navigator.of(context).pushNamed(AddMailScreen.routeName);
        },
        child: Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('users')
              .document(currentUserMail)
              .collection('inbox')
              .snapshots(),
          builder: (context, stramSnapshot) {
            if (!stramSnapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(backgroundColor: Colors.black),
              );
            }
            List<DocumentSnapshot> documents = stramSnapshot.data.documents;
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (ctx, index) {
                DocumentSnapshot emailData = documents[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(emailData['profilepic']),
                  ),
                  title: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => ViewMailScreen(
                            id: emailData['id'],
                            mail: emailData['mail'],
                            picture: emailData['attachment'],
                            profilePic: emailData['profilepic'],
                            sender: emailData['sender'],
                            sub: emailData['sub'],
                            time: emailData['time'],
                            username: emailData['username'],
                          ),
                        ),
                      );
                    },
                    child: Text(emailData['username'],
                        style: emailData['hasred']
                            ? myStyle(20, FontWeight.w400)
                            : myStyle(20, FontWeight.w700)),
                  ),
                  subtitle: Text(emailData['sub'],
                      style: emailData['hasred']
                          ? myStyle(16, FontWeight.w500)
                          : myStyle(16, FontWeight.w700)),
                  trailing: Column(
                    children: <Widget>[
                      SizedBox(height: 5),
                      Text(
                          DateFormat.Hm()
                              .format(emailData['time'].toDate())
                              .toString(),
                          style: myStyle(14, FontWeight.w600)),
                      SizedBox(height: 5),
                      InkWell(
                        onTap: () => starMsg(emailData['id']),
                        child: emailData['starred']
                            ? Icon(Icons.star, color: Colors.redAccent)
                            : Icon(Icons.star_border),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

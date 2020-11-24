import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final contactController = TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> addUser(username, email, contact) {
    return users
        .add({'username': username, 'email': email, 'contact': contact})
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  void showDialog(BuildContext ctx, bool isUpdate, DocumentSnapshot ds) {
    showModalBottomSheet(
        context: ctx,
        builder: (_) {
          return GestureDetector(
            onTap: () {},
            child: Card(
              elevation: 5,
              child: Padding(
                padding: EdgeInsets.only(top: 10, right: 10, left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    TextField(
                      decoration: InputDecoration(labelText: "Name"),
                      controller: nameController,
                      onSubmitted: (_) => submitData,
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: "Email"),
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      onSubmitted: (_) => submitData,
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: "Contact"),
                      controller: contactController,
                      keyboardType: TextInputType.number,
                      onSubmitted: (_) => submitData,
                    ),
                    RaisedButton(
                      onPressed: () {
                        if (isUpdate) {
                          firestore.collection('users').doc(ds.id).update({
                            'username': nameController.text,
                            'email': emailController.text,
                            'contact': contactController.text
                          });
                          Navigator.of(context).pop();
                        } else
                          submitData();

                        contactController.clear();
                        emailController.clear();
                        nameController.clear();
                      },
                      child: isUpdate ? Text("Update") : Text("Add"),
                      color: isUpdate ? Colors.blue : Colors.green,
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  void submitData() {
    final name = nameController.text;
    final email = emailController.text;
    final contact = contactController.text;
    if (name.isEmpty || email.isEmpty || contact.isEmpty) return;

    addUser(name, email, contact);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Test App")),
      body: StreamBuilder<QuerySnapshot>(
        stream: users.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong ");
          }
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snapshot.data.docs[index];
                return Container(
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                    elevation: 5,
                    child: ListTile(
                      leading: Text(
                        ds['username'],
                        style: TextStyle(fontSize: 20),
                      ),
                      title: Text(ds['email']),
                      subtitle: Text(ds['contact']),
                      trailing: IconButton(
                          onPressed: () {
                            firestore.collection('users').doc(ds.id).delete();
                          },
                          icon: Icon(Icons.delete)),
                      onTap: () {
                        showDialog(context, true, ds);
                        nameController.text = ds['username'];
                        emailController.text = ds['email'];
                        contactController.text = ds['contact'];
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context, false, null);
          contactController.clear();
          emailController.clear();
          nameController.clear();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

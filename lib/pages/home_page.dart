// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatapp_firebase/helper/helper_function.dart';
import 'package:flutter_chatapp_firebase/pages/login_page.dart';
import 'package:flutter_chatapp_firebase/pages/profile_page.dart';
import 'package:flutter_chatapp_firebase/pages/search_page.dart';
import 'package:flutter_chatapp_firebase/services/auth_service.dart';
import 'package:flutter_chatapp_firebase/services/database_service.dart';
import 'package:flutter_chatapp_firebase/widgets/group_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthService authService = AuthService();

  String email = "";
  String userName = "";

  String groupName = "";

  Stream? groups;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    gettingUserData();
  }

  //string manipulation
  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  gettingUserData() async {
    await HelperFunctions.getUserEmailFromSF().then((value) {
      setState(() {
        email = value!;
      });
    });

    await HelperFunctions.getUserNameFromSF().then((value) {
      setState(() {
        userName = value!;
      });
    });
    // getting the list of snapshots in our stream
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        title: Text(
          "Groups",
          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 32),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
                onPressed: () {
                  HelperFunctions().nextScreen(context, SearchPage());
                },
                icon: Icon(
                  CupertinoIcons.search,
                  size: 24,
                )),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 50),
          children: [
            Icon(
              Icons.account_circle_outlined,
              size: 120,
            ),
            Center(
                child: Text(
              userName,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            )),
            SizedBox(
              height: 25,
            ),
            ListTile(
              selectedColor: Theme.of(context).primaryColor,
              selected: true,
              leading: Icon(
                Icons.group,
              ),
              title: Text(
                "Groups",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            ListTile(
              onTap: () {
                HelperFunctions().nextScreen(
                    context,
                    ProfilePage(
                      userName: userName,
                      email: email,
                    ));
              },
              selectedColor: Theme.of(context).primaryColor,
              selected: false,
              leading: Icon(
                Icons.person_3_sharp,
              ),
              title: Text(
                "Profile",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            ListTile(
              onTap: () async {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Logout"),
                        content: Text("Are you sure you want to logout?"),
                        actions: [
                          IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: Icon(
                                Icons.cancel,
                                color: Colors.red,
                              )),
                          IconButton(
                              onPressed: () async {
                                await authService.signOut();
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) => LoginPage()),
                                    (route) => false);
                              },
                              icon: Icon(
                                Icons.done,
                                color: Colors.green,
                              ))
                        ],
                      );
                    });
              },
              selectedColor: Theme.of(context).primaryColor,
              selected: false,
              leading: Icon(
                Icons.logout_sharp,
              ),
              title: Text(
                "Logout",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            )
          ],
        ),
      ),
      body: groupList(),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          popUpDialog(context);
        },
        child: Icon(
          Icons.add,
          size: 32,
        ),
      ),
    );
  }

  popUpDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Create a group",
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                isLoading == true
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    : TextField(
                        onChanged: (value) {
                          setState(() {
                            groupName = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Group name here",
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                  width: 1.5,
                                  color: Theme.of(context).primaryColor)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                  width: 2,
                                  color: Theme.of(context).primaryColor)),
                        ),
                      ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  if (groupName != "") {
                    setState(() {
                      isLoading = true;
                    });
                    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                        .createGroup(userName,
                            FirebaseAuth.instance.currentUser!.uid, groupName)
                        .whenComplete(() {
                      isLoading = false;
                    });
                    Navigator.of(context).pop();
                    HelperFunctions().showSnackBar(
                        context, Colors.green, "Group created successfully.");
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor),
                child: Text("Create"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor),
                child: Text("Cancel"),
              ),
            ],
          );
        });
  }

  groupList() {
    return StreamBuilder(
      stream: groups,
      builder: (context, AsyncSnapshot snapshot) {
        // make some checks
        if (snapshot.hasData) {
          if (snapshot.data['groups'] != null) {
            if (snapshot.data['groups'].length != 0) {
              return ListView.builder(
                  itemCount: snapshot.data['groups'].length,
                  itemBuilder: (context, index) {
                    int reverseIndex =
                        snapshot.data['groups'].length - index - 1;
                    return GroupTile(
                        userName: snapshot.data['fullName'],
                        groupId: getId(snapshot.data['groups'][reverseIndex]),
                        groupName:
                            getName(snapshot.data['groups'][reverseIndex]));
                  });
            } else {
              return noGroupWidget();
            }
          } else {
            return noGroupWidget();
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          );
        }
      },
    );
  }

  noGroupWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              popUpDialog(context);
            },
            child: Icon(
              Icons.add_circle,
              color: Colors.grey[700],
              size: 75,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "You have not joined any group(s) yet, press the add button to create one. You can also search for a group using the above search icon.",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}

// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatapp_firebase/helper/helper_function.dart';
import 'package:flutter_chatapp_firebase/pages/home_page.dart';
import 'package:flutter_chatapp_firebase/pages/register_page.dart';
import 'package:flutter_chatapp_firebase/services/auth_service.dart';
import 'package:flutter_chatapp_firebase/services/database_service.dart';
import 'package:flutter_chatapp_firebase/widgets/my_button.dart';
import 'package:flutter_chatapp_firebase/widgets/text_field_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String email = "";
  String password = "";

  bool _isLoading = false;

  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
      key: formKey,
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.only(top: 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Chatter Box",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 28,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    "Login now to see what everybody is talking about!",
                    style: TextStyle(fontSize: 15),
                  ),
                  Image.asset("assets/login.jpg"),
                  TextFieldWidget(
                    controller: emailController,
                    text: "Email",
                    obscureText: false,
                    prefixIcon: Icon(Icons.email_sharp),
                    validator: (value) {
                      return RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(value!)
                          ? null
                          : "Please enter a valid email address";
                    },
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  TextFieldWidget(
                    controller: passwordController,
                    text: "Password",
                    obscureText: true,
                    prefixIcon: Icon(Icons.lock_outline_sharp),
                    validator: (value) {
                      if (value!.length < 6) {
                        return "Password must be atleast 6 characters";
                      } else {
                        return null;
                      }
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  MyButton(
                      onPressed: () {
                        setState(() {
                          email = emailController.text;
                          password = passwordController.text;
                        });
                        login();
                      },
                      text: "Sign in"),
                  SizedBox(
                    height: 20,
                  ),
                  Text.rich(
                      TextSpan(text: "Don't have an account? ", children: [
                    TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            HelperFunctions()
                                .nextScreen(context, RegisterPage());
                          },
                        text: "Register now!",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold))
                  ])),
                ],
              ),
            ),
    ));
  }

  login() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService
          .loginWithUsernameAndPassword(email, password)
          .then((value) async {
        if (value == true) {
          QuerySnapshot snapshot =
              await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                  .gettingUserdata(email);

          // saving the values to our shared preferences
          await HelperFunctions.saveUserLoggedInStatus(true);
          await HelperFunctions.saveUserEmailSF(email);
          await HelperFunctions.saveUserNameSF(snapshot.docs[0]['fullName']);

          HelperFunctions().nextScreenReplace(context, HomePage());
        } else {
          HelperFunctions().showSnackBar(context, Colors.redAccent, value);
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }
}

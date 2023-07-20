// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatapp_firebase/helper/helper_function.dart';
import 'package:flutter_chatapp_firebase/pages/home_page.dart';
import 'package:flutter_chatapp_firebase/pages/login_page.dart';
import 'package:flutter_chatapp_firebase/services/auth_service.dart';
import 'package:flutter_chatapp_firebase/widgets/my_button.dart';
import 'package:flutter_chatapp_firebase/widgets/text_field_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;
  final formKeyy = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final nameController = TextEditingController();

  String email = "";
  String password = "";
  String fullName = "";

  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
      key: formKeyy,
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
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
                    "Create your account now to chat and explore!",
                    style: TextStyle(fontSize: 15),
                  ),
                  Image.asset("assets/register.jpg"),
                  TextFieldWidget(
                    controller: nameController,
                    text: "Full Name",
                    obscureText: false,
                    prefixIcon: Icon(Icons.person),
                    validator: (value) {
                      if (value!.isNotEmpty) {
                        return null;
                      } else {
                        return "Name cannot be empty";
                      }
                    },
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  TextFieldWidget(
                    controller: _emailController,
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
                    controller: _passwordController,
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
                          email = _emailController.text;
                          password = _passwordController.text;
                          fullName = nameController.text;
                        });
                        register();
                      },
                      text: "Register"),
                  SizedBox(
                    height: 20,
                  ),
                  Text.rich(
                      TextSpan(text: "Already have an account? ", children: [
                    TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            HelperFunctions().nextScreen(context, LoginPage());
                          },
                        text: "Login now!",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold))
                  ])),
                ],
              ),
            ),
    ));
  }

  register() async {
    if (formKeyy.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService
          .registerUserWithEmailAndPassword(fullName, email, password)
          .then((value) async {
        if (value == true) {
          // saving the shared preference state
          await HelperFunctions.saveUserLoggedInStatus(true);
          await HelperFunctions.saveUserEmailSF(email);
          await HelperFunctions.saveUserNameSF(fullName);
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

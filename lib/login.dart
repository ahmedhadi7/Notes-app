import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasee/component/alert.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String? mypassword;
  String? myemail;
  final GlobalKey<FormState> formstate = GlobalKey<FormState>();

  Future<UserCredential?> signIn() async {
    var formdata = formstate.currentState;

    if (formdata!.validate()) {
      formdata.save();

      UserCredential? userCredential;
      String? errorMessage;

      try {
        showLoading(context);
        userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: myemail!.trim(),
              password: mypassword!.trim(),
            );
      } on FirebaseAuthException catch (e) {
        errorMessage = "Login failed. Please try again.";

        if (e.code == "user-not-found") {
          errorMessage = "No user found for this email.";
        } else if (e.code == "wrong-password") {
          errorMessage = "Wrong password.";
        } else if (e.code == "invalid-credential") {
          errorMessage = "Email or password is incorrect.";
        } else if (e.code == "invalid-email") {
          errorMessage = "Invalid email address.";
        }
      } catch (e) {
        errorMessage = "Unexpected error. Please try again.";
      } finally {
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      }

      if (errorMessage != null && mounted) {
        await showErrorDialog(context, errorMessage);
      }

      return userCredential;
    } else {
      print("not valid");
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: ListView(
        children: [
          SizedBox(height: 100),
          Center(child: Text('hi')),
          Container(
            padding: EdgeInsets.all(20),
            child: Form(
              key: formstate,
              child: Column(
                children: [
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (val) {
                      myemail = val;
                    },
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return "email required";
                      }
                      if (!val.contains("@")) {
                        return "enter valid email";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      hintText: "email",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 20),

                  TextFormField(
                    obscureText: true,
                    onSaved: (val) {
                      mypassword = val;
                    },
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return "password required";
                      }
                      if (val.trim().length < 6) {
                        return "password too short";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      hintText: "password",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Text("if you haven't an account "),
                        InkWell(
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushReplacementNamed("signup");
                          },
                          child: Text(
                            "click here",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final user = await signIn();
                      if (!mounted) return;
                      if (user != null) {
                        Navigator.of(
                          this.context,
                        ).pushReplacementNamed("homepage");
                      }
                    },
                    child: Text("sign In"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

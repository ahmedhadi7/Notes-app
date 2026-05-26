import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasee/component/alert.dart';
import 'package:flutter/material.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  var myusername, mypassword, myemail;

  final GlobalKey<FormState> formstate = GlobalKey<FormState>();
  Future<UserCredential?> signUp() async {
    var formdata = formstate.currentState;
    if (formdata!.validate()) {
      formdata.save();
      try {
        showLoading(context);
        UserCredential usercredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: myemail!,
              password: mypassword!,
            );
        return usercredential;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          Navigator.of(context).pop();

          showErrorDialog(context, 'The password provided is too weak.');

          debugPrint('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          Navigator.of(context).pop();
          showErrorDialog(context, 'The email already exists.');
        }
        return null;
      } catch (e) {
        debugPrint('$e');
        return null;
      }
    } else {
      print("not valid");
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Signup')),
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
                    onSaved: (val) {
                      myusername = val;
                    },
                    validator: (val) {
                      if (val == null) {
                        return "username required";
                      }
                      if (val.length > 100) {
                        return "username too long";
                      }
                      if (val.length < 2) {
                        return "username too short";
                      }
                      return null;
                    },

                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      hintText: "username",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  TextFormField(
                    onSaved: (val) {
                      myemail = val;
                    },
                    validator: (val) {
                      if (val == null) {
                        return "email required";
                      }
                      if (val.length > 100) {
                        return "email too long";
                      }
                      if (val.length < 5) {
                        return "email too short";
                      }
                      return null;
                    },

                    obscureText: false,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      hintText: "email",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  TextFormField(
                    onSaved: (val) {
                      mypassword = val;
                    },
                    validator: (val) {
                      if (val == null) {
                        return "password required";
                      }
                      if (val.length > 100) {
                        return "password too long";
                      }
                      if (val.length < 4) {
                        return "password too short";
                      }
                      return null;
                    },

                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      hintText: "password",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Text("if you have an account "),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed("login");
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
                      final response = await signUp();
                      debugPrint("//////////////");

                      if (response != null) {
                        await FirebaseFirestore.instance
                            .collection("users")
                            .add({"username": myusername, "email": myemail});
                        // only if route exists:
                        Navigator.of(context).pushReplacementNamed('homepage');
                      } else {
                        debugPrint("Sign up failed");
                      }
                    },
                    child: Text("Sign Up"),
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

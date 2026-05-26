import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebasee/component/alert.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' show basename;

class Addnotes extends StatefulWidget {
  const Addnotes({super.key});

  @override
  State<Addnotes> createState() => _AddnotesState();
}

class _AddnotesState extends State<Addnotes> {
  CollectionReference refnotes = FirebaseFirestore.instance.collection("notes");

  Reference? ref;

  XFile? pickedImage;

  var title, note, imageurl;

  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  Future<bool> addNote(BuildContext context) async {
    if (pickedImage == null) {
      await showErrorDialog(context, "please add image for note");
      return false;
    }

    var formdata = formstate.currentState;

    if (formdata!.validate()) {
      showLoading(context);
      formdata.save();

      try {
        final imageBytes = await pickedImage!.readAsBytes();
        await ref!.putData(
          imageBytes,
          SettableMetadata(contentType: pickedImage!.mimeType ?? "image/jpeg"),
        );

        imageurl = await ref!.getDownloadURL();

        await refnotes.add({
          "title": title,
          "note": note,
          "imageurl": imageurl,
          "userid": FirebaseAuth.instance.currentUser!.uid,
        });

        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        return true;
      } catch (e) {
        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        if (context.mounted) {
          await showErrorDialog(context, "Failed to add note: $e");
        }
        print("FIRESTORE ERROR: $e");
        return false;
      }
    } else {
      print("not valid");
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Notes')),
      body: Padding(
        padding: EdgeInsetsGeometry.all(40),
        child: Column(
          children: [
            Form(
              key: formstate,
              child: Column(
                children: [
                  TextFormField(
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return "please enter title";
                      }
                      if (val.length > 250) {
                        return "title too long";
                      }
                      if (val.length < 3) {
                        return "title too short";
                      }
                      return null;
                    },

                    onSaved: (val) {
                      title = val;
                    },
                    maxLength: 30,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.cyan,
                      labelText: "Note Title",
                      prefixIcon: Icon(Icons.note),
                    ),
                  ),
                  TextFormField(
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return "please enter note";
                      }
                      if (val.length > 250) {
                        return "note too long";
                      }
                      if (val.length < 5) {
                        return "note too short";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      note = val;
                    },
                    minLines: 1,
                    maxLines: 3,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.cyan,
                      labelText: "Note Content",
                      prefixIcon: Icon(Icons.edit),
                    ),
                  ),
                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: () {
                      showBottomSheet();
                    },
                    child: Text("add image for note"),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final added = await addNote(context);
                if (!context.mounted) return;
                if (added) {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pushReplacementNamed("homepage");
                  }
                }
              },

              child: Text("add Note"),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> showBottomSheet() {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          height: 170,
          child: Column(
            children: [
              Text(
                "please Chose image",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              InkWell(
                onTap: () async {
                  var picked = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) {
                    var rand = Random().nextInt(100000);
                    var nameimage = "$rand${basename(picked.path)}";

                    setState(() {
                      pickedImage = picked;
                      ref = FirebaseStorage.instance
                          .ref("images")
                          .child(nameimage);
                    });

                    Navigator.of(context).pop();
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.cyan,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.photo_library, color: Colors.white),
                      SizedBox(width: 10),
                      Text("Gallery", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),

              InkWell(
                onTap: () async {
                  var picked = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                  );
                  if (picked != null) {
                    var rand = Random().nextInt(100000);
                    var nameimage = "$rand${basename(picked.path)}";
                    setState(() {
                      pickedImage = picked;
                      ref = FirebaseStorage.instance
                          .ref("images")
                          .child(nameimage);
                    });
                    debugPrint(nameimage);
                    if (!mounted) return;
                    Navigator.of(context).pop();
                  }
                },
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.cyan,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.camera_alt, color: Colors.white),
                      SizedBox(width: 10),
                      Text("Camera", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

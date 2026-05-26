import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebasee/component/alert.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' show basename;

class Editnodes extends StatefulWidget {
  final docid;
  final list;
  const Editnodes({super.key, required this.docid, required this.list});

  @override
  State<Editnodes> createState() => _EditnodesState();
}

class _EditnodesState extends State<Editnodes> {
  CollectionReference refnotes = FirebaseFirestore.instance.collection("notes");

  Reference? ref;

  XFile? pickedImage;

  var title, note, imageurl;

  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  Future<bool> editNote(BuildContext context) async {
    var formdata = formstate.currentState;

    if (pickedImage == null) {
      // file تساوي نولل يعني المستخدم لم يختار صورة جديدة، لذلك نستخدم الصورة القديمة الموجودة في قاعدة البيانات

      if (formdata!.validate()) {
        showLoading(context);
        formdata.save();

        try {
          //await ref!.putFile(file!);

          //imageurl = await ref!.getDownloadURL();

          await refnotes.doc(widget.docid).update({
            "title": title,
            "note": note,
            // "imageurl": imageurl,
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
            await showErrorDialog(context, "Failed to edit note: $e");
          }
          print("FIRESTORE ERROR: $e");
          return false;
        }
      } else {
        print("not valid");
        return false;
      }
    } else {
      if (formdata!.validate()) {
        showLoading(context);
        formdata.save();

        try {
          await ref!.putData(
            await pickedImage!.readAsBytes(),
            SettableMetadata(
              contentType: pickedImage!.mimeType ?? "image/jpeg",
            ),
          );

          imageurl = await ref!.getDownloadURL();

          await refnotes
              .doc(widget.docid)
              .update({"title": title, "note": note, "imageurl": imageurl});
             
                if (context.mounted && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
                return true;
              
        } catch (e) {
          if (context.mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          if (context.mounted) {
            await showErrorDialog(context, "Failed to edit note: $e");
          }
          print("FIRESTORE ERROR: $e");
          return false;
        }
      } else {
        print("not valid");
        return false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Notes')),
      body: Container(
        child: Column(
          children: [
            Form(
              key: formstate,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: widget.list["title"],
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
                    initialValue: widget.list["note"],

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
                  ElevatedButton(
                    onPressed: () {
                      showBottomSheet();
                    },
                    child: Text("edit image for note"),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final edited = await editNote(context);
                if (!context.mounted) return;
                if (edited) {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pushReplacementNamed("homepage");
                  }
                }
              },

              child: Text("edit Note"),
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
                " edit image",
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

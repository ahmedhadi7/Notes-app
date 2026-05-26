import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class Testone extends StatefulWidget {
  const Testone({super.key});

  @override
  State<Testone> createState() => _TestoneState();
}

class _TestoneState extends State<Testone> {
  
  var imagepicker = ImagePicker();

  Future<void> uploadImages() async {
    var imgpicked = await imagepicker.pickImage(source: ImageSource.gallery);

    if (imgpicked != null) {
      //start upload
      var nameimage = basename(imgpicked.path);

      var random = Random().nextInt(
        100000,
      ); // اضافة رقم عشوائي لاسم الصورة لتجنب تكرار الاسم في التخزين
      nameimage =
          "$random$nameimage"; // دمج الرقم العشوائي مع اسم الصورة الأصلي

      var refstorage = FirebaseStorage.instance
          .ref("images")
          .child("part1")
          .child(nameimage);

      await refstorage.putData(
        await imgpicked.readAsBytes(),
        SettableMetadata(
          contentType: imgpicked.mimeType ?? "image/jpeg",
        ),
      );

      // ارجاع عنوان الصوره
      var url = await refstorage.getDownloadURL();

      print("url: $url");

      // end upload
    } else {
      debugPrint("no image selected");
    }
  }

 
  Future<void> getImagesAndFolderName() async {
    var result = await FirebaseStorage.instance.ref().listAll();
    for (var element in result.items) {
      print("_______________________________");
      print(element.fullPath);
    }
  }

  @override
  void initState() {
    getImagesAndFolderName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("test one")),
      body: Column(
       /* children: [
          ElevatedButton(
            onPressed: () async {
              await uploadImages();
            },
            child: Text("Upload Image"),
          ),
        ],*/
      ),
    );
  }
}

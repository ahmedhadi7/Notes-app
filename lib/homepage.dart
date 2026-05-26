import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebasee/coud/editnodes.dart';
import 'package:firebasee/coud/viewnotes.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  FirebaseMessaging? fbm;
  CollectionReference notesref = FirebaseFirestore.instance.collection("notes");
  void getUser() {
    final user = FirebaseAuth.instance.currentUser;
    print(user!.email);
  }

  @override
  void initState() {
    //للايفون
    /*fbm = FirebaseMessaging.instance;
    fbm!.requestPermission(alert: true, badge: true, sound: true);
    fbm!.getToken().then((token) {
      print("basim karbalaie is: $token");
    });*/

    // التطبيق في الخلفيه
    /*FirebaseMessaging.onMessageOpenedApp.listen((event) {
      Navigator.of(context).pushNamed("addnotes");
    });*/
    
    // التطبيق غير موجود في الخلفيه
    initialMessage() async {
      var message = await FirebaseMessaging.instance.getInitialMessage();
      if (message != null) {
        Navigator.of(context).pushNamed("addnotes");
      }
    }

    FirebaseMessaging.onMessage.listen((event) {
      print("____________________data notification_____________");
      print("${event.notification!.body}");
    });
    initialMessage();
    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Homepage'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed("login");
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyan,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).pushNamed("addnotes");
        },
      ),
      body: Container(
        child: StreamBuilder(
          stream: notesref
              .where(
                "userid",
                isEqualTo: FirebaseAuth.instance.currentUser!.uid,
              )
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasData) {
              if (snapshot.data!.docs.isEmpty) {
                return Center(child: Text("No notes found"));
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, i) {
                  return Dismissible(
                    onDismissed: (direction) async {
                      final imageurl = snapshot.data!.docs[i]['imageurl'];
                      await notesref.doc(snapshot.data!.docs[i].id).delete();
                      try {
                        await FirebaseStorage.instance
                            .refFromURL(imageurl)
                            .delete();
                        print("Image deleted successfully");
                      } on FirebaseException catch (e) {
                        if (e.code != "object-not-found") {
                          rethrow;
                        }
                        print("Image already deleted");
                      }
                    },
                    key: UniqueKey(),
                    child: ListNote(
                      notes: snapshot.data!.docs[i].data(),
                      docid: snapshot.data!.docs[i].id,
                    ),
                  );
                },
              );
            }

            return Center(child: Text("No data"));
          },
        ),
      ),
    );
  }
}

class ListNote extends StatelessWidget {
  final docid;
  final notes;
  const ListNote({super.key, this.docid, this.notes});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return Viewnotes(notes: notes);
            },
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Image.network(
                "${notes['imageurl']}",
                fit: BoxFit.fill,
                height: 60,
                webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 60,
                    color: Colors.black12,
                    child: const Icon(Icons.broken_image),
                  );
                },
              ),
            ),
            Expanded(
              flex: 3,
              child: ListTile(
                title: Text(
                  "${notes['title']}",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${notes['note']}",
                  style: TextStyle(fontSize: 16),
                ),
                trailing: IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return Editnodes(docid: docid, list: notes);
                        },
                      ),
                    );
                  },
                  icon: Icon(Icons.edit),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

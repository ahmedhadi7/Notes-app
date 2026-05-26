import 'package:flutter/material.dart';

class Viewnotes extends StatefulWidget {
  final notes;
  const Viewnotes({super.key, this.notes});

  @override
  State<Viewnotes> createState() => _ViewnotesState();
}

class _ViewnotesState extends State<Viewnotes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Viewnotes')),

      body: Container(child: Column(children: [
        SizedBox(
          height: 200,
          width: double.infinity,
          child: Image.network(
            widget.notes["imageurl"],
            webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.black12,
                child: const Icon(Icons.broken_image, size: 60),
              );
            },
          )
        ),
        SizedBox(height: 20,),
        Text(widget.notes["title"], style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        Text(widget.notes["note"], style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),

      ],)),
    );
  }
}

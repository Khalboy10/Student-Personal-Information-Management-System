import 'package:flutter/material.dart';
import 'package:splanner/notes/note_func.dart';

class MyNotes extends StatelessWidget {
  const MyNotes({super.key});

    @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CreateNotes()
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Note {
  String text;
  final String documentId;
  final String userId;

  Note(this.text, {required this.documentId, required this.userId});
}

class CreateNotes extends StatefulWidget {
  @override
  State<CreateNotes> createState() => _CreateNotesState();
}

class _CreateNotesState extends State<CreateNotes> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;
  bool _isMounted = false; // Flag to track widget mount state
  List<Note> notes = [];
  late CollectionReference _notesCollection;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _user = _auth.currentUser!;
    _notesCollection = FirebaseFirestore.instance.collection('notes');
    _fetchNotes();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

   void _fetchNotes() async {
    if (_user != null) {
      QuerySnapshot querySnapshot = await _notesCollection
          .where('userId', isEqualTo: _user.uid) // Query only notes of the current user
          .get();

      if (_isMounted) {
        setState(() {
          notes = querySnapshot.docs.map((document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return Note(data['text'], documentId: document.id, userId: data['userId']);
          }).toList();
        });
      }
    }
  }

  void _addNote(String noteText) async {
    if (noteText.isNotEmpty) {
      DocumentReference documentReference = await _notesCollection.add({
        'text': noteText,
        'userId': _user.uid, // Store the user ID with the note
      });

      if (_isMounted) {
        setState(() {
          notes.add(Note(noteText, documentId: documentReference.id, userId: _user.uid));
        });
      }
    }
  }

  void _deleteNote(String documentId, int index) async {
    bool confirmDelete = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmation'),
        content: Text('Are you sure you want to delete?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Return false when canceled
            },
            child: Text('Cancel', style: TextStyle(color: Color.fromARGB(255, 60, 138, 255))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Return true when confirmed
            },
            style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 236, 22, 7))
            ),
            child: Text('Yes', style: TextStyle(color: Colors.white),),
          ),
        ],
      );
    },
  );

    if (confirmDelete){
      await _notesCollection.doc(documentId).delete();
      setState(() {
        if (index >= 0 && index < notes.length) {
        notes.removeAt(index);
        }
      });
    }
  }

  void _editNote(Note note) async {
  TextEditingController controller = TextEditingController(text: note.text);
  String? editedNoteText = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Edit Note'),
        content: TextField(
          controller: controller,
          style: TextStyle(fontSize: 20),
          decoration: InputDecoration(hintText: 'Enter edited note'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Cancel',
                style: TextStyle(color: Color.fromARGB(255, 60, 138, 255))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(controller.text); // Pass edited text back
            },
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Color.fromARGB(255, 60, 138, 255))),
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );

  if (editedNoteText != null) {
    // Update note in Firestore
    await _notesCollection.doc(note.documentId).update({'text': editedNoteText});
    setState(() {
      // Update note in UI
      notes.firstWhere((n) => n.documentId == note.documentId).text = editedNoteText!;
    });
  }
}


  Future<void> _showAddNoteDialog(BuildContext context) async {
    String newNoteText = '';
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Note'),
          content: TextField(
            onChanged: (value) {
              newNoteText = value;
            },
            style: TextStyle(fontSize: 20),
            decoration: InputDecoration(hintText: 'Enter note'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel',
                  style: TextStyle(color: Color.fromARGB(255, 60, 138, 255))),
            ),
            ElevatedButton(
              onPressed: () {
                _addNote(newNoteText);
                Navigator.of(context).pop(); // Close the dialog
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromARGB(255, 60, 138, 255))),
              child: Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: StreamBuilder<QuerySnapshot>(
      stream: _notesCollection.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < notes.length; i++)
                Card(
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notes[i].text,
                          style: TextStyle(fontSize: 18),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit,
                                color: Color.fromARGB(255, 60, 138, 255)),
                              onPressed: () => _editNote(notes[i]),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete,
                                color: Colors.red),
                              onPressed: () => _deleteNote(notes[i].documentId, i),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    ),
    floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(context),
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Color.fromARGB(255, 60, 138, 255)),
  );
}

}

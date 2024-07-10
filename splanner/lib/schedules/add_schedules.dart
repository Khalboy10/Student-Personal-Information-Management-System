import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Task {
  String name;
  final String documentId;
  final String userId;
  DateTime selectedDate;
  TimeOfDay selectedTime;
  bool isComplete; // New field to track task completion

  Task(this.name, {required this.documentId, required this.userId, required this.selectedDate, required this.selectedTime, required this.isComplete});
}

class CreateTasks extends StatefulWidget {
  @override
  State<CreateTasks> createState() => _CreateTasksState();
}

class _CreateTasksState extends State<CreateTasks> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;
  bool _isMounted = false;
  List<Task> tasks = [];
  late CollectionReference _tasksCollection;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _user = _auth.currentUser!;
    _tasksCollection = FirebaseFirestore.instance.collection('tasks');
    _fetchTasks();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  void _fetchTasks() async {
    if (_user != null) {
      QuerySnapshot querySnapshot = await _tasksCollection
          .where('userId', isEqualTo: _user.uid)
          .get();

      if (_isMounted) {
        setState(() {
          tasks = querySnapshot.docs.map((document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return Task(
              data['name'],
              documentId: document.id,
              userId: data['userId'],
              selectedDate: (data['selectedDate'] as Timestamp).toDate(),
              selectedTime: TimeOfDay.fromDateTime((data['selectedTime'] as Timestamp).toDate()),
              isComplete: data['isComplete'] ?? false, // Initialize isComplete from Firestore
            );
          }).toList();
        });
      }
    }
  }

  void _addTask(String taskName, DateTime selectedDate, TimeOfDay selectedTime) async {
    if (taskName.isNotEmpty) {
      DocumentReference documentReference = await _tasksCollection.add({
        'name': taskName,
        'selectedDate': selectedDate,
        'selectedTime': DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute),
        'userId': _user.uid,
        'isComplete': false, // Default value for isComplete in Firestore
      });

      if (_isMounted) {
        setState(() {
          tasks.add(Task(taskName, documentId: documentReference.id, userId: _user.uid, selectedDate: selectedDate, selectedTime: selectedTime, isComplete: false));
        });
      }
    }
  }

  void _deleteTask(String documentId, int index) async {
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

    if (confirmDelete) {
      await _tasksCollection.doc(documentId).delete();
      setState(() {
        tasks.removeAt(index);
      });
    }
  }

  void _editTask(Task task) async {
    TextEditingController nameController = TextEditingController(text: task.name);
    DateTime selectedDate = task.selectedDate;
    TimeOfDay selectedTime = task.selectedTime;

    String? editedName = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(hintText: 'Enter task name'),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != selectedDate) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Text('Select Date'),
                  ),
                  Text(selectedDate.toString().substring(0, 10)),
                ],
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (pickedTime != null && pickedTime != selectedTime) {
                        setState(() {
                          selectedTime = pickedTime;
                        });
                      }
                    },
                    child: Text('Select Time'),
                  ),
                  Text(selectedTime.format(context)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel', style: TextStyle(color: Color.fromARGB(255, 60, 138, 255))),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(nameController.text); // Pass edited name back
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 60, 138, 255))),
              child: Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (editedName != null) {
      // Update task in Firestore
      await _tasksCollection.doc(task.documentId).update({
        'name': editedName,
        'selectedDate': selectedDate,
        'selectedTime': DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute),
      });

      setState(() {
        // Update task in UI
        task.name = editedName;
        task.selectedDate = selectedDate;
        task.selectedTime = selectedTime;
      });
    }
  }

  void _toggleTaskCompletion(Task task) async {
    // Toggle isComplete locally
    setState(() {
      task.isComplete = !task.isComplete;
    });

    // Update isComplete in Firestore
    await _tasksCollection.doc(task.documentId).update({'isComplete': task.isComplete});
  }

  Future<void> _showAddTaskDialog(BuildContext context) async {
    String newTaskName = '';
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add Task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      newTaskName = value;
                    },
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(hintText: 'Enter task name'),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null && pickedDate != selectedDate) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                        child: Text('Select Date'),
                      ),
                      Text(selectedDate.toString().substring(0, 10)),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () async {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (pickedTime != null && pickedTime != selectedTime) {
                            setState(() {
                              selectedTime = pickedTime;
                            });
                          }
                        },
                        child: Text('Select Time'),
                      ),
                      Text(selectedTime.format(context)),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Cancel', style: TextStyle(color: Color.fromARGB(255, 60, 138, 255))),
                ),
                ElevatedButton(
                  onPressed: () {
                    _addTask(newTaskName, selectedDate, selectedTime);
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 60, 138, 255)),
                  ),
                  child: Text('Add', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            for (int i = 0; i < tasks.length; i++)
              Card(
                child: ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: tasks[i].isComplete,
                            onChanged: (value) => _toggleTaskCompletion(tasks[i]),
                            checkColor: Color.fromARGB(255, 60, 138, 255),
                            activeColor: Colors.white,
                          ),
                          Text(tasks[i].name, style: TextStyle(fontSize: 18)),
                        ],
                      ),
                      Text('Date: ${tasks[i].selectedDate.toString().substring(0, 10)}', style: TextStyle(fontSize: 16)),
                      Text('Time: ${tasks[i].selectedTime.format(context)}', style: TextStyle(fontSize: 16)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit,
                              color: Color.fromARGB(255, 60, 138, 255)),
                            onPressed: () => _editTask(tasks[i]),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTask(tasks[i].documentId, i),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Color.fromARGB(255, 60, 138, 255),
      ),
    );
  }
}

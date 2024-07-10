import 'package:flutter/material.dart';
import 'schedules/schedules.dart';
import 'package:splanner/voiceNote/voiceNote.dart';
import 'notes/notes.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(title:const Text("SPIMS",
            style: TextStyle(color: Color.fromARGB(255, 236, 247, 252))),
            bottom: const TabBar(
              indicatorColor: Colors.white,
              tabs: [
                Tab(icon: Column(
                  children: [Icon(Icons.schedule, color: Colors.white), Text('Schedules', style: TextStyle(color: Colors.white))]
                )),
                Tab(icon: Column(
                  children: [Icon(Icons.note, color: Colors.white), Text('Notes', style: TextStyle(color: Colors.white))]
                )),
                Tab(icon: Column(
                  children: [Icon(Icons.mic, color: Colors.white), Text('Voice', style: TextStyle(color: Colors.white))]
                ))
              ]
            ),
            backgroundColor: Color.fromARGB(255, 60, 138, 255)),
          body: const TabBarView(
            children: [
              Schedules(),
              MyNotes(),
              MyVoiceNote()
            ])
        )
        ),
    );
  }
}

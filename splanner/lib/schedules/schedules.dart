import 'package:flutter/material.dart';
import 'package:splanner/schedules/add_schedules.dart';

class Schedules extends StatelessWidget {
  const Schedules({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: CreateTasks()
      )
    );
  }
}

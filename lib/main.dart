import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: DateTimeDisplay());
  }
}

class DateTimeDisplay extends StatefulWidget {
  const DateTimeDisplay({super.key});

  @override
  DateTimeDisplayState createState() => DateTimeDisplayState();
}

class DateTimeDisplayState extends State<DateTimeDisplay> {
  String _dateTimeString = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    Timer.periodic(Duration(seconds: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('dd-MM-yy HH:mm:ss');
    setState(() {
      _dateTimeString = formatter.format(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Date & Time Display")),
      body: Center(
        child: TextField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: "Current Date & Time",
            border: OutlineInputBorder(),
          ),
          controller: TextEditingController(text: _dateTimeString),
        ),
      ),
    );
  }
}

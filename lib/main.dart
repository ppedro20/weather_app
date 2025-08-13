import 'package:flutter/material.dart';
import 'date.dart';
import 'dart:async';
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final logger = Logger();

final apiKey = dotenv.env['WEATHER_API_KEY'];

void main() {
  runApp(const MyApp());
}

final Map<String, int> cityID = {
  'Lisboa': 2267056,
  'Leiria': 2267094,
  'Coimbra': 2740636,
  'Porto': 2735941,
  'Faro': 2268337,
};

String? _selectedCity;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: DateTimeDisplay());
  }
}

class DateTimeDisplay extends StatefulWidget {
  const DateTimeDisplay({super.key});

  @override
  DateTimeDisplayState createState() => DateTimeDisplayState();
}

class DateTimeDisplayState extends State<DateTimeDisplay> {
  String _dateTimeString = '';
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _dateTimeString = DateHelper.getCurrentDateTime();
    _timer = DateHelper.startTimer((newTime) {
      setState(() {
        _dateTimeString = newTime;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Weather App")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //Display current date and time
            _buildReadOnlyField("Current Date & Time", _dateTimeString),

            //City selection dropdown
            DropdownButton<String>(
              hint: const Text("Select a city"),
              value: _selectedCity,
              items: cityID.keys.map((String city) {
                return DropdownMenuItem<String>(value: city, child: Text(city));
              }).toList(),
              onChanged: (String? newCity) {
                setState(() {
                  _selectedCity = newCity;
                });
                logger.i("Selected city: $newCity, ID: ${cityID[newCity]}");
              },
            ),

            //Button to search weather
            ElevatedButton(
              onPressed: () => logger.i("Searched for weather in $_selectedCity"),
              child: const Text("Search Weather"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      controller: TextEditingController(text: value),
    );
  }
}

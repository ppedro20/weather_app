import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'date.dart';

final logger = Logger();
String? _selectedCity;

// Map of city names to OpenWeatherMap city IDs
final Map<String, int> cityID = {
  'Lisboa': 2267056,
  'Leiria': 2267094,
  'Coimbra': 2740636,
  'Porto': 2735941,
  'Faro': 2268337,
};

// Read from compile-time environment variable
const apiKey = String.fromEnvironment('WEATHER_API_KEY');

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DateTimeDisplay(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DateTimeDisplay extends StatefulWidget {
  const DateTimeDisplay({super.key});

  @override
  DateTimeDisplayState createState() => DateTimeDisplayState();
}

class DateTimeDisplayState extends State<DateTimeDisplay> {
  String _dateTimeString = '';
  String _weatherData = '';
  late Timer _timer;
  bool _isLoading = false;

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

  Future<void> fetchWeatherData() async {
    if (_selectedCity == null) {
      setState(() => _weatherData = "Please select a city first.");
      return;
    }

    setState(() {
      _isLoading = true;
      _weatherData = '';
    });

    final cityId = cityID[_selectedCity];
    final url =
        "https://api.openweathermap.org/data/2.5/forecast?id=$cityId&APPID=$apiKey&units=metric";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final cityName = data['city']['name'];
        final temp = data['list'][0]['main']['temp'];
        final description = data['list'][0]['weather'][0]['description'];

        setState(() {
          _weatherData =
              "City: $cityName\nTemperature: $temp°C\nCondition: $description";
        });
      } else {
        setState(() {
          _weatherData = "Error fetching weather: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _weatherData = "Exception fetching weather: $e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Weather App")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Display the current date and time
            _buildReadOnlyField("Current Date & Time", _dateTimeString),
            
            // Dropdown for selecting a city
            DropdownButton<String>(
              hint: const Text("Select a city"),
              value: _selectedCity,
              isExpanded: true,
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
            
            // Button to fetch weather data
            ElevatedButton(
              onPressed: _isLoading ? null : fetchWeatherData,
              child: _isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    )
                  : const Text("Search Weather"),
            ),
                        
            // Display the fetched weather data
            if (_weatherData.isNotEmpty)
            _buildReadOnlyField("Weather Data", _weatherData),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return TextField(
      readOnly: true,
      maxLines: null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      controller: TextEditingController(text: value),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'date.dart'; 

final logger = Logger();
String? _selectedCity;

// Mapping of city names to OpenWeatherMap city IDs
const Map<String, int> cityID = {
  'Lisboa': 2267056,
  'Leiria': 2267094,
  'Coimbra': 2740636,
  'Porto': 2735941,
  'Faro': 2268337,
};

// Read API key from compile-time environment variable
const apiKey = String.fromEnvironment('WEATHER_API_KEY');

void main() => runApp(const MyApp());

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

  // Temperature unit: "metric" = Celsius, "imperial" = Fahrenheit
  String _tempUnit = "metric"; // Default to Celsius

  @override
  void initState() {
    super.initState();
    // Initialize current date/time display and start timer
    _dateTimeString = DateHelper.getCurrentDateTime();
    _timer = DateHelper.startTimer((newTime) {
      setState(() => _dateTimeString = newTime);
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Stop timer when widget is destroyed
    super.dispose();
  }

  // Fetch weather data for the selected city from OpenWeatherMap API
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
        "https://api.openweathermap.org/data/2.5/forecast?id=$cityId&APPID=$apiKey&units=$_tempUnit";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final cityName = data['city']['name'];
        final temp = data['list'][0]['main']['temp'];
        final description = data['list'][0]['weather'][0]['description'];

        final unitSymbol = _tempUnit == "metric" ? "°C" : "°F";

        setState(() {
          _weatherData =
              "City: $cityName\nTemperature: $temp$unitSymbol\nCondition: $description";
        });
      } else {
        setState(() {
          _weatherData = "Error fetching weather: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() => _weatherData = "Exception fetching weather: $e");
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
          children: [
            // Display current date & time inside a card
            _buildCard(
              _buildReadOnlyField("Current Date & Time", _dateTimeString),
            ),

            // City selection dropdown
            _buildCard(
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Select City",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    hint: const Text("Choose a city"),
                    value: _selectedCity,
                    isExpanded: true,
                    items: cityID.keys
                        .map(
                          (city) =>
                              DropdownMenuItem(value: city, child: Text(city)),
                        )
                        .toList(),
                    onChanged: (newCity) {
                      setState(() => _selectedCity = newCity);
                      logger.i(
                        "Selected city: $newCity, ID: ${cityID[newCity]}",
                      );
                    },
                  ),
                ],
              ),
            ),

            // Temperature unit selection
            _buildCard(
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Unit: "),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: _tempUnit,
                    items: const [
                      DropdownMenuItem(
                        value: "metric",
                        child: Text("Celsius (°C)"),
                      ),
                      DropdownMenuItem(
                        value: "imperial",
                        child: Text("Fahrenheit (°F)"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _tempUnit = value!);
                      if (_selectedCity != null) fetchWeatherData();
                    },
                  ),
                ],
              ),
            ),

            // Search weather button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton(
                onPressed: _isLoading ? null : fetchWeatherData,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : const Text("Search Weather"),
              ),
            ),

            // Display weather data if available
            if (_weatherData.isNotEmpty)
              _buildCard(_buildReadOnlyField("Weather Data", _weatherData)),
          ],
        ),
      ),
    );
  }

  // Helper method to build a read-only text field
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

  // Helper method to wrap widgets inside a Card with padding
  Widget _buildCard(Widget child) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
  }
}

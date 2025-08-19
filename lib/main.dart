import 'package:flutter/material.dart';
import 'dart:async';
import 'date.dart';
import 'weather.dart'; // importa WeatherInfo e fetchWeatherData

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
  late Timer _timer;
  String _dateTimeString = '';
  WeatherInfo? _weather; 
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dateTimeString = DateHelper.getCurrentDateTime();
    _timer = DateHelper.startTimer((newTime) {
      setState(() => _dateTimeString = newTime);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _handleFetchWeather() async {
    setState(() {
      _isLoading = true;
      _weather = null;
    });

    final result = await fetchWeatherData();

    setState(() {
      _weather = result;
      _isLoading = false;
    });
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
                    value: selectedCity,
                    isExpanded: true,
                    items: cityID.keys
                        .map(
                          (city) =>
                              DropdownMenuItem(value: city, child: Text(city)),
                        )
                        .toList(),
                    onChanged: (newCity) {
                      setState(() => selectedCity = newCity);
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
                    value: tempUnit,
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
                      setState(() => tempUnit = value!);
                      if (selectedCity != null) _handleFetchWeather();
                    },
                  ),
                ],
              ),
            ),

            // Search weather button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleFetchWeather,
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

            // Display weather data with icon
            if (_weather != null)
              _buildCard(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "City: ${_weather!.cityName}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Temperature: ${_weather!.temperature}${tempUnit == "metric" ? "°C" : "°F"}",
                    ),
                    Text("Condition: ${_weather!.description}"),
                    const SizedBox(height: 8),
                    Center(
                      child: Image.network(
                        _weather!.iconUrl,
                        width: 80,
                        height: 80,
                      ),
                    ),
                  ],
                ),
              ),

            if (_weather == null && selectedCity == null && !_isLoading)
              _buildCard(
                const Text(
                  "Please select a city to view weather data.",
                  style: TextStyle(color: Colors.red),
                ),
              ),
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

  Widget _buildCard(Widget child) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
  }
}

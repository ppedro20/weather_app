import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

final logger = Logger();

// Mapping of city names to OpenWeatherMap city IDs
const Map<String, int> cityID = {
  'Lisboa': 2267056,
  'Leiria': 2267094,
  'Coimbra': 2740636,
  'Porto': 2735941,
  'Faro': 2268337,
};

// Read API key
const apiKey = String.fromEnvironment('WEATHER_API_KEY');

// Temperature unit: "metric" = Celsius, "imperial" = Fahrenheit
String tempUnit = "metric"; // default to Celsius
String lang = "pt"; // portuguese

// Selected city
String? selectedCity;

/// Model to hold weather info
class WeatherInfo {
  final String cityName;
  final double temperature;
  final String description;
  final String iconUrl;

  WeatherInfo({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.iconUrl,
  });
}

/// Fetch weather data for the selected city
Future<WeatherInfo?> fetchWeatherData() async {
  if (selectedCity == null) {
    return null;
  }

  final cityId = cityID[selectedCity];
  final url =
      "https://api.openweathermap.org/data/2.5/forecast?id=$cityId&APPID=$apiKey&units=$tempUnit&lang=$lang";

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final cityName = data['city']['name'];
      final temp = (data['list'][0]['main']['temp']).toDouble();
      final description = data['list'][0]['weather'][0]['description'];
      final iconCode = data['list'][0]['weather'][0]['icon'];
      final iconUrl = "http://openweathermap.org/img/wn/$iconCode@2x.png";

      return WeatherInfo(
        cityName: cityName,
        temperature: temp,
        description: description,
        iconUrl: iconUrl,
      );
    } else {
      logger.e("Error fetching weather: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    logger.e("Exception fetching weather: $e");
    return null;
  }
}

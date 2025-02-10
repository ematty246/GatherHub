import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'notification_helper.dart';

void main() {
  runApp(AQIApp());
}

class AQIApp extends StatefulWidget {
  @override
  _AQIAppState createState() => _AQIAppState();
}

class _AQIAppState extends State<AQIApp> {
  final TextEditingController _cityController = TextEditingController();
  String aqiData = "Enter a city and fetch AQI data.";

  @override
  void initState() {
    super.initState();
    NotificationHelper.init();
  }

  Future<void> _fetchAQIData() async {
    if (_cityController.text.isEmpty) return;
    try {
      List<Location> locations =
          await locationFromAddress(_cityController.text);
      if (locations.isNotEmpty) {
        double lat = locations.first.latitude;
        double lon = locations.first.longitude;

        final response = await http
            .get(Uri.parse('http://192.168.208.86:5000/aqi?lat=$lat&lon=$lon'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            aqiData = "📌 CO: ${data['CO']}\n"
                "📌 NO2: ${data['NO2']}\n"
                "📌 PM2.5: ${data['PM2_5']}\n"
                "📌 SO2: ${data['SO2']}\n\n"
                "✅ Suggestion:\n${data['suggestion']['parts'][0]['text']}";
          });

          if (data['PM2_5'] > 50 ||
              data['CO'] > 500 ||
              data['NO2'] > 40 ||
              data['SO2'] > 20) {
            NotificationHelper.pushNotification(
              title: "⚠ Air Quality Alert",
              body: "High Pollution! Avoid outdoor activities.",
            );
          }
        } else {
          setState(() => aqiData = "Error fetching data.");
        }
      }
    } catch (e) {
      setState(() => aqiData = "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('AQI Monitor')),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/background.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // City Input Box
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        labelText: '📍 Enter City Name',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Fetch AQI Button
                  ElevatedButton(
                    onPressed: _fetchAQIData,
                    child: Text('🔍 Get AQI Data'),
                  ),
                  SizedBox(height: 20),

                  // AQI Display Box
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              spreadRadius: 1)
                        ],
                      ),
                      padding: EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: Text(
                          aqiData,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

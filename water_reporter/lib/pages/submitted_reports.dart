import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final String baseUrl = 'http://192.168.208.86:5000';
  final FlutterTts flutterTts = FlutterTts();
  String? storedUsername;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _speakWelcomeMessage();
  }

  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      storedUsername = prefs.getString('username');
    });
    debugPrint('Stored Username: $storedUsername');
  }

  Future<void> _speakWelcomeMessage() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(
        "Welcome to submitted reports screen, where you can see the reports reported by you.");
  }

  Future<List<dynamic>> fetchReports() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/reports'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        return data
            .where((report) =>
                storedUsername != null && report['username'] == storedUsername)
            .toList();
      } else {
        throw Exception('Failed to load reports');
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  void shareReport(Map<String, dynamic> report) async {
    final imageUrl =
        report['image_url'] != null ? '$baseUrl/${report['image_url']}' : null;
    final message = '''
🔴 **Report Details** 🔴

👤 **Username:** ${report['username']}
🏢 **Department:** ${report['department'] ?? 'N/A'}
📌 **Category:** ${report['category'] ?? 'N/A'}
📝 **Description:** ${report['description'] ?? 'N/A'}

🌍 **Location:** 
📍 Latitude: ${report['latitude'] ?? 'N/A'}
📍 Longitude: ${report['longitude'] ?? 'N/A'}

📍 **Open in OpenStreetMap:**
https://www.openstreetmap.org/?mlat=${report['latitude']}&mlon=${report['longitude']}&zoom=15
''';

    if (imageUrl != null) {
      try {
        var dir = await getTemporaryDirectory();
        String filePath = '${dir.path}/report_image.jpg';
        await Dio().download(imageUrl, filePath);

        Share.shareXFiles([XFile(filePath)], text: message);
      } catch (e) {
        print("Image download error: $e");
        Share.share(message);
      }
    } else {
      Share.share(message);
    }
  }

  Future<void> deleteReport(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/reports/$id'));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report deleted successfully')),
        );
        setState(() {});
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report not found')),
        );
      } else {
        throw Exception('Failed to delete report');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete report: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder<List<dynamic>>(
          future: fetchReports(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No reports available.'));
            } else {
              final reports = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  final imageUrl = report['image_url'] != null
                      ? '$baseUrl/${report['image_url']}'
                      : null;
                  final latitude = report['latitude'];
                  final longitude = report['longitude'];
                  final id = report['id'];

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.all(12.0),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 40,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Username: ${report['username']}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Category: ${report['category']?.toString() ?? 'N/A'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Department: ${report['department']?.toString() ?? 'N/A'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Description: ${report['description']?.toString() ?? 'N/A'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8.0),
                            if (imageUrl != null)
                              Image.network(
                                imageUrl,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Text(
                                    'Image not available',
                                    textAlign: TextAlign.center,
                                  );
                                },
                              ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Latitude: ${latitude?.toString() ?? 'N/A'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Longitude: ${longitude?.toString() ?? 'N/A'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            if (latitude != null && longitude != null)
                              Container(
                                height: 200,
                                margin: const EdgeInsets.only(top: 8.0),
                                child: FlutterMap(
                                  options: MapOptions(
                                    initialCenter: LatLng(latitude, longitude),
                                    initialZoom: 15.0,
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate:
                                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      subdomains: const ['a', 'b', 'c'],
                                    ),
                                    MarkerLayer(
                                      markers: [
                                        Marker(
                                          width: 80.0,
                                          height: 80.0,
                                          point: LatLng(latitude, longitude),
                                          child: const Icon(
                                            Icons.location_pin,
                                            color: Colors.red,
                                            size: 40.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        Positioned(
                          top: 8.0,
                          right: 8.0,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Confirm Delete'),
                                        content: const Text(
                                          'Are you sure you want to delete this report?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              deleteReport(id);
                                            },
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.share,
                                    color: Colors.black),
                                onPressed: () => shareReport(report),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

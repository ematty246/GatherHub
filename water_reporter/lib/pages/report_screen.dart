// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({
    super.key,
  });

  @override
  ReportScreenState createState() => ReportScreenState();
}

class ReportScreenState extends State<ReportScreen> {
  XFile? _image;
  final bool _isAnalyzing = false;
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String? selectedDepartment = 'State Disaster Management Authorities';
  String? selectedCategory = 'Flood';
  MapController mapController = MapController();
  double _currentZoom = 13.0;

  final TextStyle commonTextStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.black,
  );

  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadUsername();
    _speakIntro();
  }

  void _speakIntro() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.speak(
        "Welcome to the report issue screen. Please describe the issue and provide your location.");
  }

  void _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    if (storedUsername != null) {
      setState(() {
        usernameController.text = storedUsername;
      });
    }
  }

  void _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      latitudeController.text = position.latitude.toString();
      longitudeController.text = position.longitude.toString();
    });

    _getAddressFromLatLng(position);
  }

  void _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks[0];
      setState(() {
        addressController.text =
            "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  Future<List<String>> _getSuggestions(String query) async {
    final uri = Uri.parse('https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(query)}'
        '&format=json'
        '&addressdetails=1');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => e['display_name'] as String).toList();
    } else {
      return [];
    }
  }

  Future<void> _getCoordinatesFromAddress(String address) async {
    final uri = Uri.parse('https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(address)}'
        '&format=json'
        '&addressdetails=1');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        final location = data[0];
        setState(() {
          latitudeController.text = location['lat'];
          longitudeController.text = location['lon'];
        });
        mapController.move(
          LatLng(double.parse(location['lat']), double.parse(location['lon'])),
          _currentZoom,
        );
      } else {
        setState(() {
          latitudeController.text = '';
          longitudeController.text = '';
        });
      }
    } else {
      print('Failed to get coordinates');
    }
  }

  void pickImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile? pickedFile;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  pickedFile =
                      await _picker.pickImage(source: ImageSource.camera);
                  Navigator.of(context).pop();
                  if (pickedFile != null) {
                    await analyzeImage(pickedFile!);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> analyzeImage(XFile image) async {
    const String backendUrl = 'http://192.168.208.86:3000/generate';

    try {
      final imageBytes = await image.readAsBytes();

      final request = http.MultipartRequest('POST', Uri.parse(backendUrl))
        ..files.add(http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: image.name,
        ));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print("Backend Response: $responseBody");

      if (response.statusCode == 200) {
        final result = jsonDecode(responseBody);

        print("Parsed Response: $result");

        if (result.containsKey('markdownOutput')) {
          final markdownOutput = result['markdownOutput'];

          String classification = '';

          final classificationRegExp =
              RegExp(r'\*\*Classification:\*\*\s*(\w+)');
          final match = classificationRegExp.firstMatch(markdownOutput);

          if (match != null) {
            classification = match.group(1) ?? '';
          }

          print("Extracted Classification: $classification");

          if (classification == 'Flooded') {
            setState(() {
              _image = image;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Image Accepted: Classified as Flooded')),
            );
          } else if (classification == 'Not') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Image Rejected: Classified as Not Flooded')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Unexpected Classification: $classification')),
            );
          }
        } else {
          print("Error: No 'markdownOutput' found in response.");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: Unexpected response format')),
          );
        }
      } else {
        throw Exception('Failed to analyze the image: ${response.statusCode}');
      }
    } catch (e) {
      print("Error during image analysis: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void submitReport() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('username')) {
      prefs.setString('username', usernameController.text);
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.208.86:5000/report'),
    );
    request.fields['username'] = usernameController.text;
    request.fields['description'] = descriptionController.text;
    request.fields['department'] = selectedDepartment ?? '';
    request.fields['category'] = selectedCategory!;
    request.fields['latitude'] = latitudeController.text;
    request.fields['longitude'] = longitudeController.text;
    request.fields['address'] = addressController.text;
    if (_image != null) {
      request.files
          .add(await http.MultipartFile.fromPath('image', _image!.path));
    }

    final response = await request.send();

    if (!mounted) return;

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.lightGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Report submitted successfully',
                style: commonTextStyle.copyWith(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Failed to submit report',
                style: commonTextStyle.copyWith(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      );
    }
  }

  final LatLng _currentCenter = LatLng(37.7749, -122.4194);

  void _zoomIn() {
    setState(() {
      _currentZoom += 1;
      mapController.move(_currentCenter, _currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom -= 1;
      mapController.move(_currentCenter, _currentZoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Report an Issue',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: _image == null
                      ? Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child:
                              const Icon(Icons.camera_alt, color: Colors.white),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_image!.path),
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: usernameController,
                  readOnly: usernameController.text.isNotEmpty,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Describe the issue',
                    labelStyle: commonTextStyle,
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedDepartment,
                  items: <String>[
                    'State Disaster Management Authorities',
                    'Central Ground Water Board',
                    'Central Water Commission',
                    'Fire Services Department',
                    'India Meteorological Department',
                    'Indian Army Engineering Corps',
                    'Indian Navy',
                    'Ministry Of JalShakti',
                    'National Disaster Management Authority',
                    'National Disaster Response Force',
                    'National Search And Rescue Agency',
                    'National Water Development Agency'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDepartment = newValue;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Department',
                    labelStyle: commonTextStyle,
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: <String>['Flood', 'Pipe Rupture', 'Drainage Issue']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategory = newValue;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: commonTextStyle,
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TypeAheadFormField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  suggestionsCallback: _getSuggestions,
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    addressController.text = suggestion;
                    _getCoordinatesFromAddress(suggestion);
                  },
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: latitudeController,
                  decoration: InputDecoration(
                    labelText: 'Latitude',
                    labelStyle: commonTextStyle,
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: longitudeController,
                  decoration: InputDecoration(
                    labelText: 'Longitude',
                    labelStyle: commonTextStyle,
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: mapController,
                        options: MapOptions(
                          initialCenter: LatLng(
                            double.tryParse(latitudeController.text) ?? 51.5,
                            double.tryParse(longitudeController.text) ?? -0.09,
                          ),
                          initialZoom: _currentZoom,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: const ['a', 'b', 'c'],
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                width: 80.0,
                                height: 80.0,
                                point: LatLng(
                                  double.tryParse(latitudeController.text) ??
                                      51.5,
                                  double.tryParse(longitudeController.text) ??
                                      -0.09,
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 40.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Column(
                          children: [
                            FloatingActionButton(
                              heroTag: 'zoomIn',
                              onPressed: _zoomIn,
                              child: const Icon(Icons.add),
                            ),
                            const SizedBox(height: 10),
                            FloatingActionButton(
                              heroTag: 'zoomOut',
                              onPressed: _zoomOut,
                              child: const Icon(Icons.remove),
                            ),
                          ],
                        ),
                      ),
                      if (_isAnalyzing)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                'Analyzing...',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: submitReport,
                    child: const Text('Submit Report'),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}

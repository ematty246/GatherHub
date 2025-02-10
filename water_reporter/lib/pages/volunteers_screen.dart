import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MaterialApp(
    home: VolunteersScreen(),
  ));
}

// Volunteers List Screen
class VolunteersScreen extends StatefulWidget {
  const VolunteersScreen({super.key});

  @override
  _VolunteersScreenState createState() => _VolunteersScreenState();
}

class _VolunteersScreenState extends State<VolunteersScreen> {
  List<String> volunteerNames = [];

  @override
  void initState() {
    super.initState();
    fetchVolunteerNames();
  }

  Future<void> fetchVolunteerNames() async {
    final response =
        await http.get(Uri.parse('http://192.168.208.86:5000/volunteer_names'));
    if (response.statusCode == 200) {
      setState(() {
        volunteerNames =
            List<String>.from(json.decode(response.body)['volunteer_names']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Volunteers"),
        backgroundColor: Colors.white,
        elevation: 4,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.6,
              child: volunteerNames.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: volunteerNames.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VolunteerDetailsScreen(
                                    volunteerName: volunteerNames[index]),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 4),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                volunteerNames[index],
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class VolunteerDetailsScreen extends StatefulWidget {
  final String volunteerName;
  VolunteerDetailsScreen({super.key, required this.volunteerName});

  @override
  _VolunteerDetailsScreenState createState() => _VolunteerDetailsScreenState();
}

class _VolunteerDetailsScreenState extends State<VolunteerDetailsScreen> {
  Map<String, String> volunteerDetails = {};

  @override
  void initState() {
    super.initState();
    fetchVolunteerDetails();
  }

  Future<void> fetchVolunteerDetails() async {
    final response =
        await http.get(Uri.parse('http://192.168.208.86:5000/volunteers'));
    if (response.statusCode == 200) {
      List volunteers = json.decode(response.body)['volunteers'];
      var details = volunteers.firstWhere(
          (vol) => vol['full_name'] == widget.volunteerName,
          orElse: () => null);

      if (details != null) {
        setState(() {
          volunteerDetails = Map<String, String>.from(details);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Volunteer Details"),
        backgroundColor: Colors.white,
        elevation: 4,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.7,
              child: volunteerDetails.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _infoBox("Name",
                                    volunteerDetails['full_name'] ?? "N/A"),
                                _infoBox(
                                    "Contact",
                                    volunteerDetails['contact_number'] ??
                                        "N/A"),
                                _infoBox("Email",
                                    volunteerDetails['email'] ?? "N/A"),
                                _infoBox("Address",
                                    volunteerDetails['address'] ?? "N/A"),
                                _infoBox(
                                    "Role",
                                    volunteerDetails['preferred_role'] ??
                                        "N/A"),
                                _infoBox(
                                    "Available Times",
                                    volunteerDetails['available_times'] ??
                                        "N/A"),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: IconButton(
                            icon: Icon(Icons.message,
                                size: 40, color: Colors.green),
                            onPressed: () async {
                              final contactNumber =
                                  volunteerDetails['contact_number'] ?? "";
                              final url = "https://wa.me/$contactNumber";

                              // Launch the URL
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                print("Could not launch WhatsApp.");
                              }
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBox(String label, String value) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 16, color: Colors.black),
          children: [
            TextSpan(
              text: "$label: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: value,
            ),
          ],
        ),
      ),
    );
  }
}

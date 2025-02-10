import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:water_reporter/pages/analysis_screen.dart';
import 'package:water_reporter/pages/ar_analysis.dart';
import 'package:water_reporter/pages/login_page.dart';
import 'package:water_reporter/pages/public_reports.dart';
import 'package:water_reporter/pages/report_screen.dart';
import 'package:water_reporter/pages/rewards_page.dart';
import 'package:water_reporter/pages/submitted_reports.dart';
import 'package:water_reporter/pages/volunteer_registration.dart';
import 'package:water_reporter/pages/volunteers_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String displayedText = '';
  String subText = '';
  final String welcomeMessage = 'Welcome to GatherHub...';
  final String additionalMessage = 'A crowdsourcing platform app';
  int disasterRegistered = 0;
  int volunteerRegistered = 8;
  final FlutterTts flutterTts = FlutterTts();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _displayCharacters();
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  Future<void> _displayCharacters() async {
    await _speak(welcomeMessage);

    for (int i = 0; i < welcomeMessage.length; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() {
        displayedText += welcomeMessage[i];
      });
    }

    await Future.delayed(const Duration(seconds: 1));
    await _speak(additionalMessage);

    for (int i = 0; i < additionalMessage.length; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() {
        subText += additionalMessage[i];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GatherHub',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Image.asset(
                    'assets/rescue.png',
                    height: 100,
                    width: 100,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              displayedText,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subText,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: PageView(
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  buildFirstPage(),
                  buildARPage(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(2, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  width: 8.0,
                  height: 8.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index ? Colors.black : Colors.grey,
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeScreen(
                        email: widget.email,
                        password: widget.password,
                      )),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LoginPage(
                        onTap: () {},
                      )),
            );
          }
        },
      ),
    );
  }

  Widget buildFirstPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildIconButton(
              context,
              'assets/icons8-upload-26.png',
              'Upload Image',
              const ReportScreen(),
            ),
            buildIconButton(
              context,
              'assets/submit.png',
              'Submitted\nReports',
              ReviewScreen(),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildIconButton(
              context,
              'assets/icons8-chart-bar-32.png',
              'Environmental\nAnalysis',
              AQIApp(),
            ),
            buildIconButton(
              context,
              'assets/image.png',
              'Leaderboard',
              LeaderboardPage(),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildARPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildIconButton(
              context,
              'assets/waste.png',
              'Waste\nAnalyzer',
              const AreaScanner(),
            ),
            buildIconButton(
              context,
              'assets/community.png',
              'Public\nReports',
              PublicReports(),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildIconButton(
              context,
              'assets/volunteer.png',
              'Volunteer\nRegistration',
              VolunteerRegistration(),
            ),
            buildIconButton(
              context,
              'assets/help.png',
              'Volunteers',
              VolunteersScreen(),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildIconButton(
      BuildContext context, String iconPath, String label, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Container(
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              height: 40,
              width: 40,
              color: Colors.black,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

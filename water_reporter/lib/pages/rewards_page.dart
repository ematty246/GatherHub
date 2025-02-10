import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LeaderboardPage extends StatefulWidget {
  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  Map<String, int> reportCount = {};
  final Map<int, String> medalLevels = {
    10: 'Bronze',
    20: 'Silver',
    30: 'Gold',
    40: 'Platinum',
    50: 'Diamond',
    60: 'Ruby',
    70: 'Emerald',
    80: 'Sapphire',
    90: 'Amethyst',
    100: 'Legendary'
  };

  final Map<String, IconData> medalIcons = {
    'Bronze': Icons.emoji_events,
    'Silver': Icons.emoji_events,
    'Gold': Icons.emoji_events,
    'Platinum': Icons.emoji_events,
    'Diamond': Icons.emoji_events,
    'Ruby': Icons.emoji_events,
    'Emerald': Icons.emoji_events,
    'Sapphire': Icons.emoji_events,
    'Amethyst': Icons.emoji_events,
    'Legendary': Icons.emoji_events,
  };

  final Map<String, Color> medalColors = {
    'Bronze': Colors.brown,
    'Silver': Colors.grey,
    'Gold': Colors.amber,
    'Platinum': Colors.blueGrey,
    'Diamond': Colors.blue,
    'Ruby': Colors.red,
    'Emerald': Colors.green,
    'Sapphire': Colors.indigo,
    'Amethyst': Colors.purple,
    'Legendary': Colors.orangeAccent,
  };

  @override
  void initState() {
    super.initState();
    fetchReportCount();
  }

  Future<void> fetchReportCount() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.208.86:5000/report_count'));
      if (response.statusCode == 200) {
        setState(() {
          reportCount = Map<String, int>.from(json.decode(response.body));
        });
        checkPromotions();
      } else {
        print('Failed to fetch report count');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void checkPromotions() {
    reportCount.forEach((username, reports) {
      medalLevels.forEach((threshold, medal) {
        if (reports == threshold) {
          showPromotionPopup(medal);
        }
      });
    });
  }

  void showPromotionPopup(String medal) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Congratulations! You have been promoted to $medal Level!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Image.asset('assets/popup.gif'),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard Page'),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/background.jpg',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.white.withOpacity(0.7),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: reportCount.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: medalLevels.entries.map((entry) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      medalIcons[entry.value],
                                      size: 40,
                                      color: medalColors[entry.value],
                                    ),
                                    Text('${entry.value}: ${entry.key}')
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 20),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor:
                                  MaterialStateProperty.resolveWith(
                                (states) => Colors.grey[200],
                              ),
                              headingTextStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              dataTextStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                              border: TableBorder.all(
                                color: Colors.black,
                                width: 2,
                              ),
                              columnSpacing: 12.0,
                              columns: [
                                DataColumn(
                                  label: Text('Username',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                DataColumn(
                                  label: Text('Reports Submitted',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                              rows: reportCount.entries.map((entry) {
                                return DataRow(
                                  color:
                                      MaterialStateProperty.resolveWith<Color?>(
                                    (Set<MaterialState> states) {
                                      return reportCount.entries
                                                      .toList()
                                                      .indexOf(entry) %
                                                  2 ==
                                              0
                                          ? Colors.grey[100]
                                          : Colors.white;
                                    },
                                  ),
                                  cells: [
                                    DataCell(
                                      Center(child: Text(entry.key)),
                                    ),
                                    DataCell(
                                      Center(
                                          child: Text(entry.value.toString())),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
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
}

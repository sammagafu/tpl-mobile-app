import 'package:flutter/material.dart';
import 'package:tpl/services/getGameWeek.dart';
import 'package:tpl/models/gameweek.dart';
import 'package:tpl/screens/views/premierLeagueDetail.dart';
import 'package:intl/intl.dart'; // Ensure you have added intl to pubspec.yaml

class PremierLeague extends StatefulWidget {
  const PremierLeague({super.key});

  @override
  State<PremierLeague> createState() => _PremierLeagueState();
}

class _PremierLeagueState extends State<PremierLeague> {
  final ApiService apiService = ApiService();
  late Future<List<GameWeek>> futureGameWeeks;

  @override
  void initState() {
    super.initState();
    futureGameWeeks = apiService.fetchAllGameWeeks();
  }

  Map<int, List<GameWeek>> groupGameWeeksByWeekNumber(
      List<GameWeek> gameWeeks) {
    final Map<int, List<GameWeek>> grouped = {};
    for (var gameWeek in gameWeeks) {
      grouped.putIfAbsent(gameWeek.weekNumber, () => []).add(gameWeek);
    }
    return grouped;
  }

  String formatMatchTime(String matchTime) {
    try {
      DateTime dateTime = DateTime.parse(matchTime);
      return DateFormat('hh:mm a').format(dateTime);
    } catch (e) {
      return 'Invalid Time';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NBC Premier League'),
      ),
      body: FutureBuilder<List<GameWeek>>(
        future: futureGameWeeks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Centering the CircularProgressIndicator
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            // User-friendly error widget
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 50),
                  const SizedBox(height: 10),
                  Text(
                    "An error occurred: ${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        futureGameWeeks = apiService.fetchAllGameWeeks();
                      });
                    },
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Empty state widget
            return const Center(
              child: Text(
                "No matchdays available.",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final gameWeeks = snapshot.data!;
          final groupedGameWeeks = groupGameWeeksByWeekNumber(gameWeeks);

          return ListView.builder(
            itemCount: groupedGameWeeks.length,
            itemBuilder: (context, index) {
              final weekNumber = groupedGameWeeks.keys.elementAt(index);
              final gameWeeksForWeek = groupedGameWeeks[weekNumber]!;

              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Gameweek $weekNumber',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Divider(),
                    Column(
                      children: gameWeeksForWeek.map((gameWeek) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: gameWeek.fixtures.map((fixture) {
                            return Card(
                              elevation: 0,
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PremierLeagueDetail(
                                        matchDetail: fixture,
                                      ),
                                    ),
                                  );
                                },
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          fixture.homeTeam.shortName,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              fixture.homeTeam.logo),
                                          radius: 16,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(formatMatchTime(fixture.matchTime)),
                                    const SizedBox(width: 4),
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              fixture.awayTeam.logo),
                                          radius: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          fixture.awayTeam.shortName,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

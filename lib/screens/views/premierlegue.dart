import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/gameweek.dart';
import '../../providers/game_week_provider.dart';
import 'premierLeagueDetail.dart';

class PremierLeague extends StatefulWidget {
  const PremierLeague({super.key});

  @override
  State<PremierLeague> createState() => _PremierLeagueState();
}

class _PremierLeagueState extends State<PremierLeague> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GameWeekProvider>(
        context,
        listen: false,
      ).fetchGameWeeks(context);
    });
  }

  Map<int, List<GameWeek>> groupGameWeeksByWeekNumber(
    List<GameWeek> gameWeeks,
  ) {
    final Map<int, List<GameWeek>> grouped = {};
    for (var gameWeek in gameWeeks) {
      grouped.putIfAbsent(gameWeek.weekNumber, () => []).add(gameWeek);
    }
    return grouped;
  }

  String formatMatchTime(DateTime matchTime) {
    // Changed parameter type to DateTime
    try {
      return DateFormat('hh:mm a').format(matchTime.toLocal());
    } catch (e) {
      return 'TBD';
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameWeekProvider = Provider.of<GameWeekProvider>(context);

    return Column(
      children: [
        if (gameWeekProvider.isLoading)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
        if (gameWeekProvider.error != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Icon(Icons.error, color: Colors.red, size: 40),
                const SizedBox(height: 10),
                Text(
                  'Error: ${gameWeekProvider.error}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => gameWeekProvider.fetchGameWeeks(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        Expanded(
          child:
              gameWeekProvider.gameWeeks.isEmpty && !gameWeekProvider.isLoading
              ? const Center(
                  child: Text(
                    'No matchdays available.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await gameWeekProvider.fetchGameWeeks(context);
                  },
                  child: ListView.builder(
                    itemCount: groupGameWeeksByWeekNumber(
                      gameWeekProvider.gameWeeks,
                    ).length,
                    itemBuilder: (context, index) {
                      final weekNumber = groupGameWeeksByWeekNumber(
                        gameWeekProvider.gameWeeks,
                      ).keys.elementAt(index);
                      final gameWeeksForWeek = groupGameWeeksByWeekNumber(
                        gameWeekProvider.gameWeeks,
                      )[weekNumber]!;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 8.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Gameweek $weekNumber',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const Divider(),
                            Column(
                              children: gameWeeksForWeek.map((gameWeek) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: gameWeek.fixtures.map((fixture) {
                                    return Card(
                                      elevation: 2,
                                      margin: const EdgeInsets.only(bottom: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListTile(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PremierLeagueDetail(
                                                    matchDetail: fixture,
                                                  ),
                                            ),
                                          );
                                        },
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                        title: Table(
                                          defaultVerticalAlignment:
                                              TableCellVerticalAlignment.middle,
                                          columnWidths: const {
                                            0: FlexColumnWidth(2),
                                            1: FixedColumnWidth(40),
                                            2: FixedColumnWidth(70),
                                            3: FixedColumnWidth(40),
                                            4: FlexColumnWidth(2),
                                          },
                                          children: [
                                            TableRow(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        right: 15,
                                                      ),
                                                  child: Text(
                                                    fixture.homeTeam.shortName,
                                                    textAlign: TextAlign.left,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                    semanticsLabel:
                                                        'Home team ${fixture.homeTeam.shortName}',
                                                  ),
                                                ),
                                                Semantics(
                                                  label:
                                                      'Logo of ${fixture.homeTeam.shortName}',
                                                  child: CircleAvatar(
                                                    backgroundImage: NetworkImage(
                                                      fixture
                                                              .homeTeam
                                                              .logo
                                                              .isNotEmpty
                                                          ? fixture
                                                                .homeTeam
                                                                .logo
                                                          : 'https://via.placeholder.com/40',
                                                    ),
                                                    radius: 20,
                                                    backgroundColor:
                                                        Colors.grey[200],
                                                  ),
                                                ),
                                                Text(
                                                  fixture.homeTeamScore != null
                                                      ? '${fixture.homeTeamScore} - ${fixture.awayTeamScore ?? ''}'
                                                      : formatMatchTime(
                                                          fixture.startTime,
                                                        ),
                                                  // Fixed call
                                                  textAlign: TextAlign.center,
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.bodyMedium,
                                                  semanticsLabel:
                                                      'Match time or score',
                                                ),
                                                Semantics(
                                                  label:
                                                      'Logo of ${fixture.awayTeam.shortName}',
                                                  child: CircleAvatar(
                                                    backgroundImage: NetworkImage(
                                                      fixture
                                                              .awayTeam
                                                              .logo
                                                              .isNotEmpty
                                                          ? fixture
                                                                .awayTeam
                                                                .logo
                                                          : 'https://via.placeholder.com/40',
                                                    ),
                                                    radius: 20,
                                                    backgroundColor:
                                                        Colors.grey[200],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        left: 15,
                                                      ),
                                                  child: Text(
                                                    fixture.awayTeam.shortName,
                                                    textAlign: TextAlign.right,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                    semanticsLabel:
                                                        'Away team ${fixture.awayTeam.shortName}',
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
                  ),
                ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/gameweek.dart';

class PremierLeagueDetail extends StatelessWidget {
  final Fixture matchDetail;

  const PremierLeagueDetail({super.key, required this.matchDetail});

  String formatMatchTime(DateTime matchTime) {
    try {
      return DateFormat('hh:mm a').format(matchTime.toLocal());
    } catch (e) {
      return 'TBD';
    }
  }

  String formatMatchDate(DateTime matchTime) {
    try {
      return DateFormat('MMMM d, yyyy').format(matchTime.toLocal());
    } catch (e) {
      return 'Unknown Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${matchDetail.homeTeam.shortName} vs ${matchDetail.awayTeam.shortName}',
          style: Theme.of(context).textTheme.titleLarge,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.2,
              width: double.infinity,
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          matchDetail.homeTeam.logo.isNotEmpty
                              ? matchDetail.homeTeam.logo
                              : 'https://via.placeholder.com/40',
                        ),
                        radius: 30,
                        backgroundColor: Colors.grey[200],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        matchDetail.homeTeam.shortName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          matchDetail.awayTeam.logo.isNotEmpty
                              ? matchDetail.awayTeam.logo
                              : 'https://via.placeholder.com/40',
                        ),
                        radius: 30,
                        backgroundColor: Colors.grey[200],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        matchDetail.awayTeam.shortName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  matchDetail.homeTeamScore != null
                      ? '${matchDetail.homeTeamScore} - ${matchDetail.awayTeamScore ?? ''}'
                      : formatMatchTime(matchDetail.startTime),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  formatMatchDate(matchDetail.startTime),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Match Details',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: const Icon(Icons.stadium),
                    title: Text('Stadium: ${matchDetail.stadium}'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(
                      'Time: ${formatMatchTime(matchDetail.startTime)}',
                    ),
                  ),
                  if (matchDetail.homeTeamScore != null)
                    ListTile(
                      leading: const Icon(Icons.score),
                      title: Text(
                        'Score: ${matchDetail.homeTeamScore} - ${matchDetail.awayTeamScore ?? ''}',
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

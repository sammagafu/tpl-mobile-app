// screens/views/premierLeagueDetail.dart

import 'package:flutter/material.dart';
import 'package:tpl/models/gameweek.dart';
import 'package:intl/intl.dart';

class PremierLeagueDetail extends StatelessWidget {
  final Fixture matchDetail;

  const PremierLeagueDetail({Key? key, required this.matchDetail})
      : super(key: key);

  String formatMatchDate(String matchDate) {
    DateTime dateTime = DateTime.parse(matchDate);
    return DateFormat('EEEE, MMM d, yyyy').format(dateTime);
  }

  String formatMatchTime(String matchTime) {
    DateTime dateTime = DateTime.parse(matchTime);
    return DateFormat('hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${matchDetail.homeTeam.shortName} vs ${matchDetail.awayTeam.shortName}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   formatMatchDate(matchDetail.matchTime),
            //   style: Theme.of(context).textTheme.bodyLarge,
            // ),
            // const SizedBox(height: 10),
            // Text(
            //   formatMatchTime(matchDetail.matchTime),
            //   style: Theme.of(context).textTheme.bodyMedium,
            // ),
            const Divider(thickness: 1, height: 30),

            // Team Logos and Names
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(matchDetail.homeTeam.logo),
                      radius: 30,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      matchDetail.homeTeam.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  formatMatchTime(matchDetail.matchTime),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Column(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(matchDetail.awayTeam.logo),
                      radius: 30,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      matchDetail.awayTeam.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // const SizedBox(height: 20),
            // const Divider(thickness: 1, height: 30),
            //
            // // Match Details
            // Text(
            //   'Match Details',
            //   style: Theme.of(context).textTheme.headlineSmall,
            // ),
            // const SizedBox(height: 10),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     const Text(
            //       'Location:',
            //       style: TextStyle(fontWeight: FontWeight.bold),
            //     ),
            //     Text(matchDetail.location),
            //   ],
            // ),
            // const SizedBox(height: 10),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     const Text(
            //       'Status:',
            //       style: TextStyle(fontWeight: FontWeight.bold),
            //     ),
            //     Text(matchDetail.status),
            //   ],
            // ),
            //
            // const SizedBox(height: 20),
            //
            // // Additional Information
            // Text(
            //   'Additional Information',
            //   style: Theme.of(context).textTheme.headlineSmall,
            // ),
            // const SizedBox(height: 10),
            // if (matchDetail.additionalInfo.isNotEmpty)
            //   Text(matchDetail.additionalInfo)
            // else
            //   const Text('No additional information available.'),
          ],
        ),
      ),
    );
  }
}

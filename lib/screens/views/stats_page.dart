import 'package:flutter/material.dart';

class StatsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Player Statistics',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            SizedBox(height: 20),
            // Placeholder for player stats
            ListView.builder(
              shrinkWrap: true,
              itemCount: 5, // Placeholder for player stats
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Player ${index + 1}'),
                  subtitle: Text('Goals: ${index * 2}'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

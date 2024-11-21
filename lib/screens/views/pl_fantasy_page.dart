import 'package:flutter/material.dart';

class PLFantasyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fantasy League'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to the Fantasy League!',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to your fantasy teams page
              },
              child: Text('Manage Your Team'),
            ),
          ],
        ),
      ),
    );
  }
}

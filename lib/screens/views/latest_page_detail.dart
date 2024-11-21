import 'package:flutter/material.dart';
import 'package:tpl/models/update.dart';

class DetailPage extends StatelessWidget {
  final Update update;

  const DetailPage({Key? key, required this.update}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(update.title),
      ),
      body: FutureBuilder(
        future: Future.delayed(Duration(seconds: 1)), // Simulate loading delay
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(0.0), // Remove padding to utilize full screen
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.25, // Adjust height as needed
                      width: double.infinity, // Full width
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)), // Rounded bottom corners
                        child: Image.network(
                          update.cover,
                          fit: BoxFit.cover, // Cover the entire area
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            update.title,
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            update.timestamp.toLocal().toString().split(' ')[0], // Displaying the date
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            update.category.name,
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            update.update,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

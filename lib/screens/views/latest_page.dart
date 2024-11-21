import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tpl/models/update.dart';
import 'package:tpl/screens/views/latest_page_detail.dart';

class LatestPage extends StatefulWidget {
  @override
  _LatestPageState createState() => _LatestPageState();
}

class _LatestPageState extends State<LatestPage> {
  late Future<List<Update>> updates;

  @override
  void initState() {
    super.initState();
    updates = fetchUpdates();
  }

  Future<List<Update>> fetchUpdates() async {
    final response = await http.get(Uri.parse('http://localhost:8000/api/v1/update/'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => Update.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load updates');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Latest Updates'),
      ),
      body: FutureBuilder<List<Update>>(
        future: updates,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No updates found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final update = snapshot.data![index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to the detail page when tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(update: update),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 7.41, horizontal: 12.0), // Adjust vertical space
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                      color: Colors.white, // Background color
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2, // Image takes up more space
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3.5),
                            child: Image.network(
                              update.cover,
                              width: double.infinity, // Image covers the entire area
                              height: 100, // Fixed height for consistency
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3, // Text takes up less space
                          child: Padding(
                            padding: const EdgeInsets.all(12.0), // Add padding around text
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  update.title,
                                    style: Theme.of(context).textTheme.bodyMedium
                                ),
                                Text(
                                  update.category.name,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );

          }
        },
      ),
    );
  }
}

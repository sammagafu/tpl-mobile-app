// getGameWeek.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tpl/models/gameweek.dart'; // Import the model

class ApiService {
  final String baseUrl =
      "http://localhost:8000/api/v1/gameweek"; // Replace with your API URL

  // Fetch all game weeks
  Future<List<GameWeek>> fetchAllGameWeeks() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      print(jsonResponse);
      return jsonResponse.map((data) => GameWeek.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load game weeks');
    }
  }
}

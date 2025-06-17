class FantasyTeam {
  final int id;
  final int
  userId; // Changed from 'user' to 'userId' to match a simple integer field
  final String name;
  final double budget;
  final int totalPoints;
  final DateTime createdAt; // Changed from 'createdAt' to 'created_at'
  final List<Player> players;

  FantasyTeam({
    required this.id,
    required this.userId,
    required this.name,
    required this.budget,
    required this.totalPoints,
    required this.createdAt,
    required this.players,
  });

  factory FantasyTeam.fromJson(Map<String, dynamic> json) {
    try {
      return FantasyTeam(
        id: json['id'] ?? 0,
        userId: json['user'] is Map
            ? json['user']['id'] ?? 0
            : (json['user'] ?? 0),
        // Handle user as object or ID
        name: json['name'] ?? 'Unnamed',
        budget: (json['budget'] is num) ? json['budget'].toDouble() : 0.0,
        totalPoints: json['total_points'] ?? 0,
        createdAt:
            DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
        players: (json['players'] as List? ?? [])
            .map((p) => Player.fromJson(p))
            .toList(),
      );
    } catch (e) {
      print("Error parsing FantasyTeam: $e");
      throw Exception('Failed to parse FantasyTeam');
    }
  }
}

class Player {
  final int id;

  // Add other player fields as needed (e.g., name, position)
  Player({required this.id});

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(id: json['id'] ?? 0);
  }
}

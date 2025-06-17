class GameWeek {
  final int id;
  final int weekNumber;
  final int seasonId;
  final DateTime startDate;
  final DateTime endDate;
  final List<Fixture> fixtures;

  GameWeek({
    required this.id,
    required this.weekNumber,
    required this.seasonId,
    required this.startDate,
    required this.endDate,
    required this.fixtures,
  });

  factory GameWeek.fromJson(Map<String, dynamic> json) {
    try {
      var list = json['fixtures'] as List? ?? [];
      List<Fixture> fixturesList = list
          .map((fixture) => Fixture.fromJson(fixture as Map<String, dynamic>))
          .toList();

      return GameWeek(
        id: json['id'] ?? 0,
        weekNumber: json['week_number'] ?? 0,
        seasonId: json['season'] is int
            ? json['season']
            : json['season']['id'] ?? 0,
        startDate:
            DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
        endDate: DateTime.tryParse(json['end_date'] ?? '') ?? DateTime.now(),
        fixtures: fixturesList,
      );
    } catch (e) {
      print("Error parsing GameWeek: $e");
      throw Exception('Failed to parse GameWeek');
    }
  }
}

class Fixture {
  final int id;
  final Team homeTeam;
  final Team awayTeam;
  final DateTime startTime;
  final String stadium;
  final int? homeTeamScore;
  final int? awayTeamScore;
  final int gameweekId;

  Fixture({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.startTime,
    required this.stadium,
    this.homeTeamScore,
    this.awayTeamScore,
    required this.gameweekId,
  });

  factory Fixture.fromJson(Map<String, dynamic> json) {
    try {
      return Fixture(
        id: json['id'] ?? 0,
        // Provide id from JSON
        homeTeam: json['home_team'] != null
            ? Team.fromJson(json['home_team'] as Map<String, dynamic>)
            : Team(id: 0, name: 'Unknown', shortName: 'UNK', logo: ''),
        awayTeam: json['away_team'] != null
            ? Team.fromJson(json['away_team'] as Map<String, dynamic>)
            : Team(id: 0, name: 'Unknown', shortName: 'UNK', logo: ''),
        startTime:
            DateTime.tryParse(json['start_time'] ?? '') ?? DateTime.now(),
        stadium: json['stadium'] ?? 'Unknown Stadium',
        homeTeamScore: json['home_team_score'] != null
            ? int.tryParse(json['home_team_score'].toString())
            : null,
        awayTeamScore: json['away_team_score'] != null
            ? int.tryParse(json['away_team_score'].toString())
            : null,
        gameweekId: json['gameweek'] is int
            ? json['gameweek']
            : json['gameweek']['id'] ?? 0,
      );
    } catch (e) {
      print("Error parsing Fixture: $e");
      throw Exception('Failed to parse Fixture');
    }
  }
}

class Team {
  final int id;
  final String name;
  final String shortName;
  final String logo;

  Team({
    required this.id,
    required this.name,
    required this.shortName,
    required this.logo,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    try {
      return Team(
        id: json['id'] ?? 0,
        name: json['name'] ?? 'Unknown',
        shortName: json['short_name'] ?? 'UNK',
        logo: json['logo'] ?? '',
      );
    } catch (e) {
      print("Error parsing Team: $e");
      throw Exception('Failed to parse Team');
    }
  }
}

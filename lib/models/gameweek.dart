class GameWeek {
  final int weekNumber;
  final int season;
  final List<Fixture> fixtures;

  GameWeek({
    required this.weekNumber,
    required this.season,
    required this.fixtures,
  });

  factory GameWeek.fromJson(Map<String, dynamic> json) {
    try {
      // Safely parse fixtures list
      var list = json['fixtures'] as List? ?? [];
      List<Fixture> fixturesList = list
          .map((fixture) => Fixture.fromJson(fixture as Map<String, dynamic>))
          .toList();

      return GameWeek(
        weekNumber: json['week_number'] ?? 0, // Default to 0 if null
        season: json['season'] ?? 0, // Default to 0 if null
        fixtures: fixturesList,
      );
    } catch (e) {
      print("Error parsing GameWeek: $e");
      return GameWeek(
          weekNumber: 0,
          season: 0,
          fixtures: []); // Return empty GameWeek on error
    }
  }
}

class Fixture {
  final Team homeTeam;
  final Team awayTeam;
  final String matchTime;
  final String matchdayStadium;

  Fixture({
    required this.homeTeam,
    required this.awayTeam,
    required this.matchTime,
    required this.matchdayStadium,
  });

  factory Fixture.fromJson(Map<String, dynamic> json) {
    try {
      return Fixture(
        homeTeam: json['home_team'] != null
            ? Team.fromJson(json['home_team'] as Map<String, dynamic>)
            : Team(name: 'Unknown', shortName: 'UNK', logo: ''),
        // Fallback for missing home_team
        awayTeam: json['away_team'] != null
            ? Team.fromJson(json['away_team'] as Map<String, dynamic>)
            : Team(name: 'Unknown', shortName: 'UNK', logo: ''),
        // Fallback for missing away_team
        matchTime: json['start_time'] ?? 'TBD',
        // Default to "TBD" if null
        matchdayStadium:
            json['stadium'] ?? 'Unknown Stadium', // Default if null
      );
    } catch (e) {
      print("Error parsing Fixture: $e");
      return Fixture(
        homeTeam: Team(name: 'Error', shortName: 'ERR', logo: ''),
        awayTeam: Team(name: 'Error', shortName: 'ERR', logo: ''),
        matchTime: 'Error',
        matchdayStadium: 'Error',
      ); // Return a default Fixture on error
    }
  }
}

class Team {
  final String name;
  final String shortName;
  final String logo;

  Team({required this.name, required this.shortName, required this.logo});

  factory Team.fromJson(Map<String, dynamic> json) {
    try {
      return Team(
        name: json['name'] ?? 'Unknown', // Default to "Unknown" if null
        shortName: json['short_name'] ?? 'UNK', // Default to "UNK" if null
        logo: json['logo'] ?? '', // Default to an empty string if null
      );
    } catch (e) {
      print("Error parsing Team: $e");
      return Team(
          name: 'Error',
          shortName: 'ERR',
          logo: ''); // Return default Team on error
    }
  }
}

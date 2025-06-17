class Update {
  final int id;
  final String cover;
  final String title;
  final String slug;
  final String update;
  final DateTime timestamp;
  final Category category;

  Update({
    required this.id,
    required this.cover,
    required this.title,
    required this.slug,
    required this.update,
    required this.timestamp,
    required this.category,
  });

  factory Update.fromJson(Map<String, dynamic> json) {
    try {
      return Update(
        id: json['id'] ?? 0,
        cover: json['cover'] ?? '',
        title: json['title'] ?? 'No Title',
        slug: json['slug'] ?? '',
        update: json['update'] ?? '',
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
        category: Category.fromJson(json['category'] ?? {}),
      );
    } catch (e) {
      throw Exception('Failed to parse Update: $e');
    }
  }
}

class Category {
  final int id;
  final String name;
  final String slug;

  Category({required this.id, required this.name, required this.slug});

  factory Category.fromJson(Map<String, dynamic> json) {
    try {
      return Category(
        id: json['id'] ?? 0,
        name: json['name'] ?? 'Unknown',
        slug: json['slug'] ?? '',
      );
    } catch (e) {
      throw Exception('Failed to parse Category: $e');
    }
  }
}

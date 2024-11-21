// lib/models/update.dart

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
    return Update(
      id: json['id'],
      cover: json['cover'],
      title: json['title'],
      slug: json['slug'],
      update: json['update'],
      timestamp: DateTime.parse(json['timestamp']),
      category: Category.fromJson(json['category']),
    );
  }
}

class Category {
  final int id;
  final String name;
  final String slug;

  Category({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
    );
  }
}

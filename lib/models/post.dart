import 'package:firebase_database/firebase_database.dart';

class Post {
  final String? id; // Nullable because Firebase will assign it after creation
  final String title;
  final String description;
  final String videoUrl;
  final String category;
  final String author;
  final int views;
  final int createdAt; // Timestamp for sorting

  Post({
    this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.category,
    required this.author,
    this.views = 0,
    required this.createdAt,
  });

  // Factory constructor to create a Post from a Firebase DataSnapshot
  factory Post.fromSnapshot(DataSnapshot snapshot) {
    final Map<dynamic, dynamic>? map = snapshot.value as Map<dynamic, dynamic>?;

    if (map == null) {
      throw Exception("Invalid data snapshot for Post");
    }

    return Post(
      id: snapshot.key,
      title: map['title'] as String? ?? 'No Title',
      description: map['description'] as String? ?? 'No description provided.',
      videoUrl: map['videoUrl'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      author: map['author'] as String? ?? 'Unknown',
      views: map['views'] as int? ?? 0,
      createdAt: map['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  // Method to convert the Post object to a map for Firebase submission
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'category': category,
      'author': author,
      'views': views,
      'createdAt': createdAt,
    };
  }
  factory Post.fromMap(String id, Map<String, dynamic> map) {
    return Post(
      id: id, // Use the key passed from the provider
      title: map['title'] as String? ?? 'No Title',
      description: map['description'] as String? ?? 'No description provided.',
      videoUrl: map['videoUrl'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      author: map['author'] as String? ?? 'Unknown',
      views: map['views'] as int? ?? 0,
      // Ensure createdAt is read as int
      createdAt: map['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }
}
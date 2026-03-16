import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
// Assuming Post model is imported from post_screen.dart (or defined elsewhere)
import 'package:physio_clinic_appointment/models/post.dart';

class RTDBPostsProvider with ChangeNotifier {
  final DatabaseReference _postsRef =
  FirebaseDatabase.instance.ref('posts');

  List<Post> _posts = [];
  List<Post> get posts => _posts;

  RTDBPostsProvider() {
    _listenToPosts();
  }

  void _listenToPosts() {
    _postsRef
        .orderByChild('createdAt') // Still good practice to order
        .onValue
        .listen((DatabaseEvent event) { // The event is a DatabaseEvent
      final dataSnapshot = event.snapshot;
      final postsMap = dataSnapshot.value as Map<dynamic, dynamic>?;

      final List<Post> loadedPosts = [];

      if (postsMap != null) {
        // Iterate through the map: {uniqueKey: postDataMap}
        postsMap.forEach((key, value) {

          // 1. Convert the post data value to a Map<String, dynamic>
          final postData = Map<String, dynamic>.from(value);

          // 2. ✨ CRITICAL FIX: Call the factory on the Post class, not the map value.
          loadedPosts.add(Post.fromMap(key.toString(), postData));
        });
      }

      // Reverse the list to show the newest posts first (RTDB returns ascending by default)
      _posts = loadedPosts.reversed.toList();
      notifyListeners();
    })
        .onError((error) {
      // Handle potential errors from the database stream
      debugPrint('Error listening to RTDB: $error');
    });
  }

  // Asynchronously adds a new post to RTDB
  Future<void> addPost(Post newPost) async {
    try {
      // push() generates a unique key for the new entry
      await _postsRef.push().set(newPost.toMap());
      debugPrint('Post successfully added to RTDB.');
    } catch (e) {
      debugPrint('Error adding post to RTDB: $e');
      throw e; // Propagate the error to the calling widget
    }
  }

  // Clean up listener (optional, but good practice if provider lifecycle is complex)
  @override
  void dispose() {
    // You might need to store the StreamSubscription if you want to explicitly cancel it
    super.dispose();
  }
}
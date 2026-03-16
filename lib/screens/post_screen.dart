import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:physio_clinic_appointment/models/post.dart';
import 'package:physio_clinic_appointment/providers/post_provider.dart';
import 'package:physio_clinic_appointment/screens/post_screen.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart'; // <--- NEW
import 'package:video_thumbnail/video_thumbnail.dart'; // <--- NEW
import 'dart:io'; // <--- NEW for File access

// --- 1. Data Model & Constants ---

// Enum for video source selection
enum VideoSourceType { url, gallery, record }
// Mock Data for the Feed
final List<Post> mockPosts = [
/*  Post(
    id: 'P001',
    title: 'Anatomy of the Rotator Cuff',
    description: 'Detailed video explaining the structure and function of the four rotator cuff muscles.',
    videoUrl: 'https://youtube.com/rc_anatomy',
    category: 'Anatomy',
    author: 'Dr. Jane Smith',

    views: 450, createdAt: null,
  ),*/
];


// --- 2. Main Stateful Widget: Posts Screen ---
class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  List<Post> _currentPosts = mockPosts;

  void _addNewPost(Post newPost) {
    setState(() {
      _currentPosts = [newPost, ..._currentPosts];
    });
    Navigator.of(context).pop(); // Close the modal
  }

  void _openNewPostModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: _NewPostModal(onPostCreated: _addNewPost),
      ),
    );
  }

  // Helper method to open the video player screen
  void _openVideoPlayer(BuildContext context, Post post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => _FullScreenVideoPlayer(
          videoUrl: post.videoUrl,
          isLocal: !post.videoUrl.startsWith('http'),
        ),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context,Post post) {
    final bool isLocalFile = !post.videoUrl.startsWith('http');
    String displayUrl = post.videoUrl.contains('/') ? post.videoUrl.split('/').last : post.videoUrl;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: GestureDetector(
        onTap: () => _openVideoPlayer(context, post),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Video Preview Area (Thumbnail/Placeholder) ---
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Container(
                    height: 200,
                    color: isLocalFile ? Colors.grey.shade300 : Colors.indigo.shade100,
                    child: isLocalFile
                        ? _LocalVideoThumbnail(videoPath: post.videoUrl) // Use the new specialized widget
                        : Center(
                      child: Icon(Icons.link, size: 70, color: Colors.black.withOpacity(0.7)),
                    ),
                  ),
                ),

                // Play Icon
                Icon(
                  Icons.play_circle_fill,
                  size: 70,
                  color: Colors.white.withOpacity(0.8),
                ),

                // Category Tag
                Positioned(
                  top: 10,
                  right: 10,
                  child: Chip(
                    label: Text(post.category, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    backgroundColor: post.category == 'Physiotherapy' ? Colors.teal.shade600 : Colors.indigo.shade600,
                  ),
                ),
              ],
            ),

            // --- Post Details ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Author: ${post.author}', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13)),
                      Row(
                        children: [
                          const Icon(Icons.visibility, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('${post.views} views', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Source: ${displayUrl}',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💡 Educational Feed'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Consumer<RTDBPostsProvider>( // <--- Use RTDBPostsProvider here
        builder: (context, postsProvider, child) {
      final posts = postsProvider.posts;
      if (posts.isEmpty) {
        return const Center(child: CircularProgressIndicator()); // Show loading while waiting for RTDB stream
      }
      return ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return _buildPostCard(context, posts[index]);
        },
      );
    },
    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewPostModal,
        label: const Text('Add New Post'),
        icon: const Icon(Icons.video_call),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
    );
  }
}
class _FullScreenVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool isLocal;

  const _FullScreenVideoPlayer({required this.videoUrl, required this.isLocal});

  @override
  State<_FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<_FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _controlsVisible = true;

  // Mock engagement data for demonstration
  int _likes = 42;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    if (widget.isLocal) {
      _controller = VideoPlayerController.file(File(widget.videoUrl));
    } else {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    }

    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          _initialized = true;
        });
        _controller.play();
        _hideControlsDelayed();
      }
    }).catchError((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading video: $error')),
        );
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _controlsVisible = !_controlsVisible;
    });
    if (_controlsVisible) {
      _hideControlsDelayed();
    }
  }

  void _hideControlsDelayed() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _controller.value.isPlaying && _controlsVisible) {
        setState(() {
          _controlsVisible = false;
        });
      }
    });
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likes += _isLiked ? 1 : -1;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Helper to format duration for display
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isLocal ? 'Local Video' : 'Network Video'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // --- Video Player Area with Full Controls ---
          GestureDetector(
            onTap: _toggleControls,
            child: Container(
              color: Colors.black,
              child: Center(
                child:_initialized
                    ? AspectRatio(
                  // Use the controller's aspect ratio, but default to 16/9 (or another safe value)
                  // if the value is zero, infinity, or not a number.
                  aspectRatio: _controller.value.aspectRatio == 0 || !_controller.value.isInitialized
                      ? 16 / 9
                      : _controller.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      VideoPlayer(_controller),

                      // Custom Controls Overlay (Play/Pause, Seekbar, etc.)
                      AnimatedOpacity(
                        opacity: _controlsVisible ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: _VideoControlsOverlay(
                          controller: _controller,
                          onToggleControls: _toggleControls,
                          formatDuration: _formatDuration,
                        ),
                      ),
                    ],
                  ),
                )
                    : const SizedBox(
                  height: 250,
                  child: Center(child: CircularProgressIndicator(color: Colors.white)),
                ),
              ),
            ),
          ),

          // --- Engagement Section (Likes/Comments/Info) ---
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Post-Surgical Knee Rehab Protocol', // Example Title
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text('Author: PT. Mark Johnson', style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
                  const Divider(height: 20),

                  // Likes and Comments Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildEngagementButton(
                          _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                          'Like (${_likes})',
                          _isLiked ? Colors.teal : Colors.grey,
                          _toggleLike
                      ),
                      const SizedBox(width: 20),
                      _buildEngagementButton(Icons.comment_outlined, 'Comment (15)', Colors.grey, () {
                        // Action: Scroll to comment input field
                      }),
                      const SizedBox(width: 20),
                      _buildEngagementButton(Icons.share, 'Share', Colors.grey, () {}),
                    ],
                  ),
                  const Divider(height: 20),

                  // Comment Area
                  const Text('Recent Comments (15):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                  const SizedBox(height: 8),

                  // Comment Input Field (More attractive)
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.grey.shade300)
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        const Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                                hintText: 'Add a public comment...',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 10)
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.teal),
                          onPressed: () {
                            // Action: Send comment
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Comment List
                  Expanded(
                    child: ListView(
                      children: const [
                        _CommentTile(name: 'Alice', time: '2 hours ago', text: 'Great explanation!'),
                        _CommentTile(name: 'Bob', time: '5 hours ago', text: 'Very useful for my exam prep.'),
                        _CommentTile(name: 'Charlie', time: '1 day ago', text: 'Could you cover the biomechanics in more detail next time?'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: color),
      label: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
      ),
    );
  }
}

// --- Custom Control Overlay Widget (Enhanced) ---
class _VideoControlsOverlay extends StatelessWidget {
  const _VideoControlsOverlay({
    required this.controller,
    required this.onToggleControls,
    required this.formatDuration,
  });

  final VideoPlayerController controller;
  final VoidCallback onToggleControls;
  final String Function(Duration) formatDuration;

  @override
  Widget build(BuildContext context) {
    // We use a ValueListenableBuilder to rebuild the controls only when the controller state changes
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, VideoPlayerValue value, child) {
        return Stack(
          children: <Widget>[
            // 1. Transparent Play/Pause Center Area (always present when controls are visible)
            Center(
              child: Container(
                color: Colors.black38, // Slightly darker backdrop for controls
                child: Center(
                  child: IconButton(
                    icon: Icon(
                      value.isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 80.0,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      value.isPlaying ? controller.pause() : controller.play();
                      // Keep controls visible when paused, toggle when playing
                      if (!value.isPlaying) {
                        onToggleControls();
                      }
                    },
                  ),
                ),
              ),
            ),

            // 2. Bottom Control Bar (Time and Progress)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black45,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    // Current Time
                    Text(
                      formatDuration(value.position),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),

                    const SizedBox(width: 8),

                    // Progress Indicator (Seek Bar)
                    Expanded(
                      child: SizedBox(
                        height: 20, // Ensure there is enough height for the progress bar
                        child: VideoProgressIndicator(
                          controller,
                          allowScrubbing: true,
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          colors: const VideoProgressColors(
                            playedColor: Colors.teal,
                            bufferedColor: Colors.white38,
                            backgroundColor: Colors.white12,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Total Duration
                    Text(
                      formatDuration(value.duration),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),

                    // Fullscreen Button (Placeholder)
                    IconButton(
                      icon: const Icon(Icons.fullscreen, color: Colors.white, size: 24),
                      onPressed: () {
                        // Action: Toggle Fullscreen Mode
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fullscreen mode toggled (Placeholder)')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// --- Attractive Comment Tile Widget ---
class _CommentTile extends StatelessWidget {
  final String name;
  final String time;
  final String text;

  const _CommentTile({required this.name, required this.time, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.indigo.shade100,
            child: Text(name[0], style: TextStyle(color: Colors.indigo.shade700)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: const TextStyle(fontSize: 14, height: 1.3),
                ),

                // Reply/Like actions (Placeholder)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    children: [
                      Text('Like', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      const SizedBox(width: 15),
                      Text('Reply', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- 4. Local Video Thumbnail Generator (Stateful Widget) ---

class _LocalVideoThumbnail extends StatefulWidget {
  final String videoPath;
  const _LocalVideoThumbnail({required this.videoPath});

  @override
  State<_LocalVideoThumbnail> createState() => _LocalVideoThumbnailState();
}

class _LocalVideoThumbnailState extends State<_LocalVideoThumbnail> {
  String? _thumbnailPath;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  Future<void> _generateThumbnail() async {
    final thumbnail = await VideoThumbnail.thumbnailFile(
      video: widget.videoPath,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 300,
      quality: 75,
    );
    if (mounted && thumbnail != null) {
      setState(() {
        _thumbnailPath = thumbnail;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_thumbnailPath != null) {
      return Image.file(
        File(_thumbnailPath!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: 200,
      );
    }
    return Center(child: CircularProgressIndicator(color: Colors.indigo.shade700));
  }
}


// --- 5. New Post Creation Modal (Original class structure maintained) ---
class _NewPostModal extends StatefulWidget {
  final Function(Post) onPostCreated;
  const _NewPostModal({required this.onPostCreated});

  @override
  State<_NewPostModal> createState() => _NewPostModalState();
}

class _NewPostModalState extends State<_NewPostModal> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  String _title = '';
  String _description = '';
  String _author = 'Guest Contributor';
  String _category = 'Physiotherapy';

  VideoSourceType _sourceType = VideoSourceType.url;
  String? _videoSourceIdentifier;

  final List<String> _categories = ['Physiotherapy', 'Anatomy', 'Pharmacology', 'General Medical'];

  Future<void> _pickVideo(VideoSourceType type) async {
    final ImageSource source =
    type == VideoSourceType.gallery ? ImageSource.gallery : ImageSource.camera;

    try {
      final XFile? video = await _picker.pickVideo(source: source);

      if (video != null) {
        setState(() {
          _videoSourceIdentifier = video.path;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video successfully ${type == VideoSourceType.gallery ? 'selected' : 'recorded'}.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video operation cancelled.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking video: $e')),
      );
    }
  }


// --- In _NewPostModalState class (post_screen.dart) ---

  void _submitPost() async { // Make the function asynchronous
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final postsProvider = Provider.of<RTDBPostsProvider>(context, listen: false);

      String? finalVideoUrl = _videoSourceIdentifier;

      if (finalVideoUrl == null || finalVideoUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please provide a video source (URL or file selection).')),
        );
        return;
      }

      final newPost = Post(
        // ID will be assigned by RTDB, so it can be null here or use a dummy.
        // It's best to omit it if the Post model allows a nullable ID.
        // We will remove the explicit ID assignment below.
        title: _title,
        description: _description,
        videoUrl: finalVideoUrl,
        category: _category,
        author: _author,
        views: 0,
        // CRITICAL: Add the timestamp for sorting/creation tracking
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      try {
        // 1. Call the provider's method to save the post to Firebase RTDB.
        await postsProvider.addPost(newPost);

        // 2. Dismiss the modal after successful database submission.
        Navigator.of(context).pop();

        // 3. Show success message.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post submitted successfully!'), backgroundColor: Colors.teal),
        );

      } catch (e) {
        debugPrint('Failed to submit post via provider: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit post: ${e.toString()}')),
        );
      }

      // Removed the old local call: widget.onPostCreated(newPost);
      // The provider's listener will now update the main screen.
    }
  }

// ... (rest of the class)

  Widget _buildSourceChip(VideoSourceType type, String label, IconData icon) {
    final isSelected = _sourceType == type;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      selectedColor: Colors.teal.shade300,
      backgroundColor: Colors.grey.shade200,
      labelStyle: TextStyle(
        color: isSelected ? Colors.teal.shade900 : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _sourceType = type;
            _videoSourceIdentifier = null;
          });
        }
      },
    );
  }

  Widget _buildSourceInput() {
    switch (_sourceType) {
      case VideoSourceType.url:
        return TextFormField(
          decoration: const InputDecoration(labelText: 'External Video URL', prefixIcon: Icon(Icons.link)),
          validator: (value) => value!.isEmpty ? 'Please provide a valid link.' : null,
          onSaved: (value) => _videoSourceIdentifier = value!,
        );

      case VideoSourceType.gallery:
      case VideoSourceType.record:
        return _buildFilePickerPlaceholder(
          _sourceType == VideoSourceType.gallery ? 'Choose Video from Gallery' : 'Record New Video',
          _sourceType == VideoSourceType.gallery ? Icons.folder_open : Icons.videocam_sharp,
          _videoSourceIdentifier,
        );
    }
  }

  Widget _buildFilePickerPlaceholder(String buttonText, IconData icon, String? selectedFile) {
    String displayFileName = selectedFile != null && selectedFile.contains('/')
        ? selectedFile.split('/').last
        : (selectedFile ?? 'No file chosen.');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Video File:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickVideo(_sourceType),
                icon: Icon(icon),
                label: Text(selectedFile != null ? 'Change Selection' : buttonText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade50,
                  foregroundColor: Colors.indigo.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          selectedFile != null ? 'Selected: $displayFileName' : displayFileName,
          style: TextStyle(color: selectedFile != null ? Colors.teal.shade800 : Colors.red, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25.0)),
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.2)),
        ],
      ),
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Submit Educational Content',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              const Divider(height: 20),

              // --- 1. Content Source Selection (New) ---
              const Text(
                'Video Source:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                children: [
                  _buildSourceChip(VideoSourceType.url, 'External URL', Icons.link),
                  _buildSourceChip(VideoSourceType.gallery, 'Gallery', Icons.collections),
                  _buildSourceChip(VideoSourceType.record, 'Record', Icons.videocam),
                ],
              ),
              const SizedBox(height: 20),

              // --- 2. Conditional Video Input (New) ---
              _buildSourceInput(),
              const SizedBox(height: 25),

              // --- 3. Remaining Fields ---
              TextFormField(
                decoration: const InputDecoration(labelText: 'Video Title', prefixIcon: Icon(Icons.title)),
                validator: (value) => value!.isEmpty ? 'Please enter a title.' : null,
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 15),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Short Description', prefixIcon: Icon(Icons.description)),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Please enter a description.' : null,
                onSaved: (value) => _description = value!,
              ),
              const SizedBox(height: 25),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _category = newValue!;
                  });
                },
              ),
              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitPost,
                  icon: const Icon(Icons.send),
                  label: const Text('Post Content', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
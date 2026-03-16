import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:physio_clinic_appointment/functionality/video_calling/signaling_service.dart';

class VideoCallLobby extends StatefulWidget { // <-- CLASS NAME RENAMED
  const VideoCallLobby({super.key});

  @override
  State<VideoCallLobby> createState() => _VideoCallLobbyState(); // <-- STATE CLASS NAME RENAMED
}

class _VideoCallLobbyState extends State<VideoCallLobby> { // <-- STATE CLASS NAME RENAMED
  final TextEditingController _roomIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [Permission.camera, Permission.microphone].request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Call Lobby')), // <-- Updated AppBar Title
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- CREATE CALL BUTTON (Caller) ---
              ElevatedButton.icon(
                icon: const Icon(Icons.video_call),
                label: const Text('Start New Call (Caller)'),
                onPressed: () => _navigateToCallScreen(context, null),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 40),

              const Text('OR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // --- JOIN CALL INPUT (Callee) ---
              TextField(
                controller: _roomIdController,
                decoration: InputDecoration(
                  labelText: 'Enter Room ID to Join',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _roomIdController.clear(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.call_received),
                label: const Text('Join Call (Callee)'),
                onPressed: () {
                  if (_roomIdController.text.isNotEmpty) {
                    _navigateToCallScreen(context, _roomIdController.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCallScreen(BuildContext context, String? roomId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => CallScreen(roomId: roomId),
      ),
    );
  }
}


// ------------------------------------------------------------------
// B. CALL SCREEN: The main video view (No changes here, remains CallScreen)
// ------------------------------------------------------------------

class CallScreen extends StatefulWidget {
  final String? roomId;

  const CallScreen({this.roomId, super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final SignalingService _signaling = SignalingService();
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  String? _roomId;
  bool _localVideo = true;
  bool _localAudio = true;

  @override
  void initState() {
    super.initState();
    _localRenderer.initialize();
    _remoteRenderer.initialize();
    _startCall();
  }

  void _startCall() async {
    // 1. Get user media and set the local view
    final localStream = await _signaling.openUserMedia(_localRenderer, _remoteRenderer);

    if (widget.roomId == null) {
      // Caller: Create room
      _roomId = await _signaling.createCallRoom(localStream, _remoteRenderer);
      setState(() {});
    } else {
      // Callee: Join room
      _roomId = widget.roomId;
      await _signaling.joinCallRoom(_roomId!, localStream, _remoteRenderer);
      setState(() {});
    }
  }

  void _toggleCamera() {
    _signaling.localStream?.getVideoTracks().forEach((track) {
      track.enabled = !_localVideo;
    });
    setState(() => _localVideo = !_localVideo);
  }

  void _toggleMic() {
    _signaling.localStream?.getAudioTracks().forEach((track) {
      track.enabled = !_localAudio;
    });
    setState(() => _localAudio = !_localAudio);
  }

  void _switchCamera() {
    _signaling.localStream?.getVideoTracks().forEach((track) {
      track.switchCamera();
    });
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    if (_roomId != null) {
      _signaling.hangUp(_roomId!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_roomId == null ? 'Connecting...' : 'Room ID: $_roomId'),
      ),
      body: Stack(
        children: [
          // Remote Video (Main View)
          Positioned.fill(
            child: RTCVideoView(_remoteRenderer, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
          ),

          // Local Video (Picture-in-Picture)
          Positioned(
            right: 20,
            top: 20,
            child: SizedBox(
              width: 120,
              height: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: RTCVideoView(_localRenderer, mirror: true),
              ),
            ),
          ),

          // Control Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute/Unmute
                  FloatingActionButton(
                    heroTag: 'mic',
                    onPressed: _toggleMic,
                    backgroundColor: _localAudio ? Colors.white : Colors.red,
                    child: Icon(
                      _localAudio ? Icons.mic : Icons.mic_off,
                      color: _localAudio ? Colors.teal : Colors.white,
                    ),
                  ),
                  // End Call
                  FloatingActionButton(
                    heroTag: 'hangup',
                    onPressed: () => Navigator.of(context).pop(),
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.call_end, color: Colors.white),
                  ),
                  // Toggle Camera On/Off
                  FloatingActionButton(
                    heroTag: 'video',
                    onPressed: _toggleCamera,
                    backgroundColor: _localVideo ? Colors.white : Colors.red,
                    child: Icon(
                      _localVideo ? Icons.videocam : Icons.videocam_off,
                      color: _localVideo ? Colors.teal : Colors.white,
                    ),
                  ),
                  // Switch Camera (Front/Back)
                  FloatingActionButton(
                    heroTag: 'switch',
                    onPressed: _switchCamera,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.switch_camera, color: Colors.teal),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
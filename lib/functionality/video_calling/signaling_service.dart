import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:firebase_database/firebase_database.dart'; // Changed to Realtime Database

class SignalingService {
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  // Use FirebaseDatabase instance
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  // Google's public STUN servers for NAT traversal
  static const Map<String, dynamic> _configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302',
          'stun:stun3.l.google.com:19302',
          'stun:stun4.l.google.com:19302',
        ],
      },
    ],
  };

  // ---------------------------------------------------------------
  // 1️⃣ LOCAL MEDIA SETUP (No change)
  // ---------------------------------------------------------------
  Future<MediaStream> openUserMedia(
      RTCVideoRenderer localRenderer, RTCVideoRenderer remoteRenderer) async {
    final mediaConstraints = {'audio': true, 'video': true};

    final stream =
    await navigator.mediaDevices.getUserMedia(mediaConstraints);
    localStream = stream;

    localRenderer.srcObject = localStream;

    return localStream!;
  }

  // ---------------------------------------------------------------
  // 2️⃣ CREATE PEER CONNECTION (RTDB Candidate Logic)
  // ---------------------------------------------------------------
  Future<void> initializePeerConnection(
      MediaStream localStream, String roomId, bool isCaller) async {
    peerConnection = await createPeerConnection(_configuration, {});

    // Add local media tracks
    for (var track in localStream.getTracks()) {
      peerConnection?.addTrack(track, localStream);
    }

    // When ICE candidate is generated, send to Realtime Database
    peerConnection?.onIceCandidate = (candidate) {
      if (candidate == null) return;

      String path = isCaller ? 'callerCandidates' : 'calleeCandidates';

      // Use push() to generate a unique key for each candidate
      _db
          .ref('rooms/$roomId/$path')
          .push()
          .set(candidate.toMap());
    };

    // When remote track received (video/audio)
    peerConnection?.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty && event.track.kind == 'video') {
        // remoteRenderer.srcObject = event.streams[0]; // handled outside
      }
    };
  }

  // ---------------------------------------------------------------
  // 3️⃣ CALLER: CREATE OFFER & ROOM (RTDB Write)
  // ---------------------------------------------------------------
  Future<String> createCallRoom(
      MediaStream localStream, RTCVideoRenderer remoteRenderer) async {
    // Create a new room reference with a unique key
    final roomRef = _db.ref('rooms').push();
    final String roomId = roomRef.key!; // Get the auto-generated key

    // Initialize peer connection
    await initializePeerConnection(localStream, roomId, true);

    // Create and set offer
    final offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);

    // Save offer to Realtime Database
    await roomRef.set({'offer': offer.toMap()});

    // Listen for answer and remote ICE candidates
    _listenForAnswerAndCandidates(roomId);

    return roomId;
  }

  // ---------------------------------------------------------------
  // 4️⃣ CALLEE: JOIN ROOM & SEND ANSWER (RTDB Read/Write)
  // ---------------------------------------------------------------
  Future<void> joinCallRoom(String roomId, MediaStream localStream,
      RTCVideoRenderer remoteRenderer) async {
    await initializePeerConnection(localStream, roomId, false);
    final roomRef = _db.ref('rooms/$roomId');

    // Get caller’s offer using once()
    final roomSnapshot = await roomRef.once();
    final roomData = roomSnapshot.snapshot.value as Map?;

    if (roomData == null) throw Exception('Room not found or no data');

    final offer = roomData['offer'];

    if (offer == null) throw Exception('Room offer not found');

    // Set offer as remote description
    await peerConnection!.setRemoteDescription(
      RTCSessionDescription(offer['sdp'], offer['type']),
    );

    // Create and set answer
    final answer = await peerConnection!.createAnswer();
    await peerConnection!.setLocalDescription(answer);

    // Save answer to Realtime Database
    await roomRef.update({'answer': answer.toMap()});

    // Listen for caller’s ICE candidates
    _listenForRemoteCandidates(roomId, true);
  }

  // ---------------------------------------------------------------
  // 5️⃣ LISTEN FOR ANSWER & ICE CANDIDATES (RTDB Listen)
  // ---------------------------------------------------------------
  void _listenForAnswerAndCandidates(String roomId) {
    final roomRef = _db.ref('rooms/$roomId');

    // Listen for answer using onValue
    roomRef.onValue.listen((event) async {
      final data = event.snapshot.value as Map?;
      if (data == null) return;

      // Check if answer is received and remoteDescription not yet set
      if (data['answer'] != null &&
          (await peerConnection?.getRemoteDescription()) == null) {
        final answer = data['answer'];
        await peerConnection!.setRemoteDescription(
          RTCSessionDescription(answer['sdp'], answer['type']),
        );
      }
    });

    // Caller listens for callee’s ICE candidates
    _listenForRemoteCandidates(roomId, false);
  }

  // ---------------------------------------------------------------
  // 6️⃣ LISTEN FOR REMOTE ICE CANDIDATES (RTDB Listen)
  // ---------------------------------------------------------------
  void _listenForRemoteCandidates(String roomId, bool isCaller) {
    // The collection name now becomes a node path
    final String remotePath =
    isCaller ? 'calleeCandidates' : 'callerCandidates';

    _db
        .ref('rooms/$roomId/$remotePath')
    // Use onChildAdded to only listen for new candidates
        .onChildAdded
        .listen((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return;

      // Realtime Database doesn't have a change type like Firestore,
      // but onChildAdded ensures we only process NEW candidates.
      final candidate = RTCIceCandidate(
        data['candidate'],
        data['sdpMid'],
        data['sdpMLineIndex'],
      );

      peerConnection?.addCandidate(candidate);
    });
  }

  // ---------------------------------------------------------------
  // 7️⃣ CLEANUP / HANGUP (RTDB Delete)
  // ---------------------------------------------------------------
  Future<void> hangUp(String roomId) async {
    // Stop local media tracks
    localStream?.getTracks().forEach((track) => track.stop());
    await peerConnection?.close();

    // Delete Realtime Database room
    await _db.ref('rooms/$roomId').remove();
  }
}
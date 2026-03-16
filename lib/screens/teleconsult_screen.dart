import 'package:flutter/material.dart';
import 'package:physio_clinic_appointment/functionality/communication/chat_screen.dart';
import 'package:physio_clinic_appointment/functionality/video_calling/videocalllobby.dart';

// Primary Brand Color
const Color _primaryColor = Color(0xFF0FAF7C);

class TeleconsultScreen extends StatelessWidget {
  const TeleconsultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teleconsult & Virtual Clinic', style: TextStyle(color: Colors.white)),
        backgroundColor: _primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. Consultation Status Card
          _buildStatusCard(context),
          const SizedBox(height: 24),

          // 2. Quick Actions Section
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _QuickActionButton(
                icon: Icons.video_call_rounded,
                label: 'Start Instant Call',
                color: _primaryColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const VideoCallLobby()),
                  );
                },//_simulateVideoCall(context, 'Instant'),
              ),
              _QuickActionButton(
                icon: Icons.chat_bubble_outline,
                label: 'View Chat History',
                color: const Color(0xFF2AB7A9),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatScreen()),
                    );
                  }
              ),
              _QuickActionButton(
                icon: Icons.settings_phone,
                label: 'Setup Call Settings',
                color: Colors.blueGrey,
                onTap: () => _showSnackbar(context, 'Opening Call Settings...'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 3. Upcoming Consultations List
          const Text(
            'Upcoming Teleconsults',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
          ),
          const SizedBox(height: 12),
          _UpcomingConsultCard(
            patientName: 'Priya Soni',
            time: '10:00 AM',
            date: 'Today',
            status: 'Confirmed',
            onTap: () => _simulateVideoCall(context, 'Priya Soni'),
          ),
          _UpcomingConsultCard(
            patientName: 'Arjun Verma',
            time: '02:30 PM',
            date: 'Today',
            status: 'Confirmed',
            onTap: () => _simulateVideoCall(context, 'Arjun Verma'),
          ),
          _UpcomingConsultCard(
            patientName: 'Neha Sharma',
            time: '09:00 AM',
            date: 'Tomorrow',
            status: 'Scheduled',
            onTap: () => _showSnackbar(context, 'Appointment with Neha is scheduled for tomorrow.'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.monitor_heart, color: _primaryColor, size: 28),
                SizedBox(width: 12),
                Text(
                  'Your Virtual Availability',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const Divider(height: 25),
            const Text(
              'Ready for Next Consult',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You are currently logged in and ready to join scheduled teleconsults.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showSnackbar(context, 'Toggling status...'),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Set Status to Busy'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA726),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _simulateVideoCall(BuildContext context, String patientName) {
    // A function to simulate launching the video call UI
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: _SimulatedCallScreen(patientName: patientName),
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

// Helper Widget for Quick Action Buttons
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: MediaQuery.of(context).size.width / 3.8,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper Widget for Upcoming Consult Cards
class _UpcomingConsultCard extends StatelessWidget {
  final String patientName;
  final String time;
  final String date;
  final String status;
  final VoidCallback onTap;

  const _UpcomingConsultCard({
    required this.patientName,
    required this.time,
    required this.date,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = status == 'Confirmed' ? _primaryColor : Colors.blueAccent;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: statusColor.withOpacity(0.15),
          child: Icon(Icons.person, color: statusColor),
        ),
        title: Text(
          patientName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text('$date at $time | Status: $status'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status == 'Confirmed' ? 'JOIN CALL' : 'WAITING',
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

// Helper Widget for Simulated Call Interface
class _SimulatedCallScreen extends StatelessWidget {
  final String patientName;
  const _SimulatedCallScreen({required this.patientName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white54,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          // Main Video Area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam_off, color: Colors.white70, size: 60),
                        SizedBox(height: 10),
                       // Text('Connecting to $patientName...', style: TextStyle(color: Colors.white70, fontSize: 18)),
                      ],
                    ),
                  ),
                  // Doctor's small video feed
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      width: 100,
                      height: 150,
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Center(
                        child: Text('You', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                  // Call timer
                  const Positioned(
                    top: 20,
                    left: 20,
                    child: Text('00:00', style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Call Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _CallControlIcon(icon: Icons.mic_off, label: 'Mute', color: Colors.redAccent, onPressed: () {}),
              _CallControlIcon(icon: Icons.videocam_off, label: 'Camera', color: Colors.redAccent, onPressed: () {}),
              _CallControlIcon(icon: Icons.chat_bubble_outline, label: 'Chat', color: Colors.blueGrey, onPressed: () {}),
              _CallControlIcon(icon: Icons.folder_open, label: 'Records', color: Colors.blueGrey, onPressed: () {}),
              FloatingActionButton(
                onPressed: () => Navigator.pop(context),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                child: const Icon(Icons.call_end, size: 30),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Helper Widget for Call Control Icons
class _CallControlIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _CallControlIcon({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(50),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(icon, color: color, size: 24),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; // <<< IMPORT THE PACKAGE

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Mock data for the professional user
  final Map<String, dynamic> _mockProfileData = const {
    // Personal Details
    'fullName': 'Dr. Alistair Finch',
    'specialty': 'Orthopedic Physiotherapist',
    'title': 'Clinical Director',
    'email': 'alistair.finch@proclinic.com',
    'phone': '+91 98765 43210',
    'dateOfBirth': '1985-11-20',

    // Professional Details
    'registrationNumber': 'PT-10982-IN',
    'licensingBody': 'Indian Association of Physiotherapists',
    'experienceYears': 15,
    'languagesSpoken': ['English', 'Hindi', 'Marathi'],

    // Clinic/Practice Details
    'clinicName': 'Rehab Dynamics Center',
    'clinicAddress': '12A, Stellar Towers, BKC, Mumbai 400051',
    'clinicHours': 'Mon-Fri, 9:00 AM - 6:00 PM',
    'gstin': '27ABCDE1234F1Z5',

    // Credentials & Certifications
    'certifications': [
      'Dry Needling Certification (DNCI)',
      'Advanced Manual Therapy',
      'Sports Injury Management',
    ],
  };

  void _showActionSnackbar(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action (Simulated action)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // <<< NEW FUNCTION: Handles the native sharing dialog >>>
  void _shareProfile(BuildContext context) async {
    // Construct the text content to be shared
    final String profileText = """
**Professional Profile: Dr. Alistair Finch**

Title: ${_mockProfileData['title']}
Specialty: ${_mockProfileData['specialty']}
Clinic: ${_mockProfileData['clinicName']}
Address: ${_mockProfileData['clinicAddress']}

Contact:
Phone: ${_mockProfileData['phone']}
Email: ${_mockProfileData['email']}

Experience: ${_mockProfileData['experienceYears']} years
Registration: ${_mockProfileData['registrationNumber']}

(Visit my digital profile link here: https://yourdomain.com/profile/alistairfinch)
    """;

    // Use Share.share to open the native sharing sheet
    await Share.share(
      profileText,
      subject: 'My Professional Profile - Dr. Alistair Finch', // Used for email subjects
    );
  }

  // Builder for a general information field
  Widget _buildInfoRow(String label, String value, {IconData icon = Icons.info_outline}) {
    // ... (Your existing _buildInfoRow implementation)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.indigo.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Builder for a section header
  Widget _buildSectionHeader(String title, IconData icon) {
    // ... (Your existing _buildSectionHeader implementation)
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.indigo, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.indigo,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Professional Profile'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showActionSnackbar(context, 'Opening Profile Editor'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // --- Header & Summary Card ---
            Container(
              color: Colors.indigo.shade50,
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.indigo.shade200,
                    child: const Icon(Icons.medication_liquid, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _mockProfileData['fullName']!,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_mockProfileData['title']} | ${_mockProfileData['specialty']}',
                    style: TextStyle(fontSize: 16, color: Colors.indigo.shade700, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),

            // 1. Contact Information
            _buildSectionHeader('Contact Information', Icons.contact_mail),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  _buildInfoRow('Email', _mockProfileData['email']!, icon: Icons.email),
                  const Divider(indent: 16, endIndent: 16),
                  _buildInfoRow('Phone', _mockProfileData['phone']!, icon: Icons.phone),
                  const Divider(indent: 16, endIndent: 16),
                  _buildInfoRow('D.O.B', _mockProfileData['dateOfBirth']!, icon: Icons.cake),
                ],
              ),
            ),

            // 2. Professional Credentials
            _buildSectionHeader('Professional Credentials', Icons.badge),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  _buildInfoRow('Registration No.', _mockProfileData['registrationNumber']!, icon: Icons.qr_code),
                  const Divider(indent: 16, endIndent: 16),
                  _buildInfoRow('Licensing Body', _mockProfileData['licensingBody']!, icon: Icons.account_balance),
                  const Divider(indent: 16, endIndent: 16),
                  _buildInfoRow('Experience', '${_mockProfileData['experienceYears']} years', icon: Icons.military_tech),
                ],
              ),
            ),

            // 3. Practice Details
            _buildSectionHeader('Practice Details', Icons.location_city),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  _buildInfoRow('Clinic Name', _mockProfileData['clinicName']!, icon: Icons.local_hospital),
                  const Divider(indent: 16, endIndent: 16),
                  _buildInfoRow('Address', _mockProfileData['clinicAddress']!, icon: Icons.location_on),
                  const Divider(indent: 16, endIndent: 16),
                  _buildInfoRow('Working Hours', _mockProfileData['clinicHours']!, icon: Icons.access_time),
                  const Divider(indent: 16, endIndent: 16),
                  _buildInfoRow('GSTIN', _mockProfileData['gstin']!, icon: Icons.receipt_long),
                ],
              ),
            ),

            // 4. Skills and Certifications
            _buildSectionHeader('Skills & Certifications', Icons.star),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Languages Spoken
                    const Text('Languages Spoken', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: (_mockProfileData['languagesSpoken'] as List<String>)
                          .map((lang) => Chip(
                        label: Text(lang),
                        backgroundColor: Colors.teal.shade50,
                      ))
                          .toList(),
                    ),
                    const Divider(height: 30),
                    // Certifications
                    const Text('Certifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                    ...(_mockProfileData['certifications'] as List<String>).map((cert) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: Icon(Icons.verified, color: Colors.green.shade600),
                      title: Text(cert),
                    )),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 5. Quick Actions - UPDATED onPressed
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.share, color: Colors.white),
                label: const Text('Share Digital Profile', style: TextStyle(fontSize: 16, color: Colors.white)),
                onPressed: () => _shareProfile(context), // <<< CALL THE NEW SHARE FUNCTION
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

// --- 1. Data Model for a Scheduled Event/Appointment ---
class Appointment {
  final String id;
  final DateTime date;
  final TimeOfDay time;
  final String patientName;
  final String service;
  final Color color;

  Appointment({
    required this.id,
    required this.date,
    required this.time,
    required this.patientName,
    required this.service,
    required this.color,
  });

  // Helper to combine date and time for sorting
  DateTime get dateTime => DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );

  // Helper to format time (since we don't have intl package)
  String get formattedTime => '${time.hourOfPeriod.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}';
}

// --- 2. Main Stateful Widget: Appointments Screen ---
class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  // Mock Appointment Data
  final List<Appointment> _allAppointments = [
    Appointment(
      id: 'A001',
      date: DateTime(2025, 12, 12),
      time: const TimeOfDay(hour: 9, minute: 0),
      patientName: 'Rohan Sharma',
      service: 'Initial Assessment (Knee)',
      color: Colors.blue.shade200,
    ),
    Appointment(
      id: 'A002',
      date: DateTime(2025, 12, 12),
      time: const TimeOfDay(hour: 10, minute: 30),
      patientName: 'Priya Verma',
      service: 'Follow-up Session (Back)',
      color: Colors.green.shade200,
    ),
    Appointment(
      id: 'A003',
      date: DateTime(2025, 12, 13),
      time: const TimeOfDay(hour: 14, minute: 0),
      patientName: 'Amit Singh',
      service: 'Deep Tissue Massage',
      color: Colors.orange.shade200,
    ),
    Appointment(
      id: 'A004',
      date: DateTime(2025, 12, 14),
      time: const TimeOfDay(hour: 16, minute: 45),
      patientName: 'Jane Doe',
      service: 'Virtual Consultation',
      color: Colors.purple.shade200,
    ),
  ];

  late DateTime _selectedDate;
  late List<Appointment> _filteredAppointments;

  @override
  void initState() {
    super.initState();
    // Initialize with today's date (or the date of the first mock appointment for demonstration)
    _selectedDate = DateTime(2025, 12, 12);
    _filterAppointments();
  }

  // --- Utility Methods ---

  void _filterAppointments() {
    setState(() {
      _filteredAppointments = _allAppointments
          .where((app) =>
      app.date.year == _selectedDate.year &&
          app.date.month == _selectedDate.month &&
          app.date.day == _selectedDate.day)
          .toList();

      // Sort by time
      _filteredAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2026, 12, 31),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _filterAppointments();
      });
    }
  }

  // Helper to format the selected date for display
  String _formatDisplayDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // --- 3. UI Builder Methods ---

  Widget _buildAppointmentTile(Appointment appointment) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: appointment.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: appointment.color.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                appointment.formattedTime,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Confirmed',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Patient and Service
          Text(
            appointment.patientName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            appointment.service,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
            ),
          ),

          // Actions
          const Divider(color: Colors.black26, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Calling ${appointment.patientName}...')),
                  );
                },
                icon: const Icon(Icons.call, size: 18),
                label: const Text('Call'),
                style: TextButton.styleFrom(foregroundColor: Colors.indigo),
              ),
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Viewing EMR for ${appointment.patientName}...')),
                  );
                },
                icon: const Icon(Icons.file_copy, size: 18),
                label: const Text('EMR'),
                style: TextButton.styleFrom(foregroundColor: Colors.indigo),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    if (_filteredAppointments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today, size: 60, color: Colors.grey),
              const SizedBox(height: 10),
              Text('No appointments scheduled for ${_formatDisplayDate(_selectedDate)}.',
                  style: const TextStyle(fontSize: 18)),
              const Text('Select a different date or add a new booking.',
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredAppointments.length,
      itemBuilder: (context, index) {
        return _buildAppointmentTile(_filteredAppointments[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🗓️ Appointments'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Date Selector Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Display Selected Date
                Text(
                  'Appointments for: ${_formatDisplayDate(_selectedDate)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
                // Date Picker Button
                TextButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: const Icon(Icons.edit_calendar, color: Colors.indigo),
                  label: const Text('Change Date', style: TextStyle(color: Colors.indigo)),
                ),
              ],
            ),
          ),

          // Appointment List / Timeline
          Expanded(
            child: _buildTimeline(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Opening Add Appointment interface...')),
          );
        },
        label: const Text('Add New Appointment'),
        icon: const Icon(Icons.add_box),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
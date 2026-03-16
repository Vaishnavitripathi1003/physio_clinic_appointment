// --- Data Model for a Prescription (Updated) ---
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:physio_clinic_appointment/models/dateformat_model.dart';
import 'package:physio_clinic_appointment/models/prescription_model.dart';
import 'package:physio_clinic_appointment/screens/prescription_screen.dart';






// --- Main Stateful Screen ---
class PrescriptionScreen extends StatefulWidget {
  const PrescriptionScreen({super.key});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  // Mock data for prescriptions and appointment
  List<Prescription> _prescriptions = [
    Prescription(
      medication: 'Amoxicillin',
      dosage: '500 mg',
      frequency: 'Three times a day',
      datePrescribed: DateTime(2025, 10, 20),
      prescribingDoctor: 'Dr. Sarah Chen',
      startDate: DateTime(2025, 10, 20),
      endDate: DateTime(2025, 10, 27),
    ),
    Prescription(
      medication: 'Lisinopril',
      dosage: '10 mg',
      frequency: 'Once a day',
      datePrescribed: DateTime(2025, 11, 5),
      prescribingDoctor: 'Dr. John Smith',
      startDate: DateTime(2025, 11, 5),
      endDate: null, // Ongoing
    ),
  ];

  // Appointment details now combined
  Map<String, dynamic> _nextAppointment = {
    'date': DateTime(2025, 12, 15),
    'time': TimeOfDay(hour: 10, minute: 30),
    'doctor': 'Dr. Sarah Chen',
    'location': 'City Medical Center, Room 3A',
  };

  final DateFormat _dateFormatter = DateFormat.yMMMd();
  final DateFormat _timeFormatter = DateFormat.Hm();

  // --- Utility Functions ---

  void _addPrescription(Prescription newPrescription) {
    setState(() {
      _prescriptions.add(newPrescription);
    });
    Navigator.of(context).pop();
  }

  // ... (Download/Share handlers remain the same) ...

  void _handleDownload() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloading prescription list...')),
    );
  }

  void _handleShare() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing prescription list...')),
    );
  }

  Future<void> _selectNextAppointmentDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _nextAppointment['date'],
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null && pickedDate != _nextAppointment['date']) {
      // Show Time Picker immediately after date selection
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _nextAppointment['time'],
      );

      if (pickedTime != null) {
        setState(() {
          _nextAppointment['date'] = pickedDate;
          _nextAppointment['time'] = pickedTime;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment set for: ${_dateFormatter.formats(pickedDate)} at ${pickedTime.format(context)}')),
        );
      }
    }
  }

  // Shows a modal bottom sheet to add a new prescription
  void _showAddPrescriptionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SingleChildScrollView(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AddPrescriptionForm(onAdd: _addPrescription),
      ),
    );
  }

  Widget _buildPrescriptionList() {
    if (_prescriptions.isEmpty) {
      return const Center(
          child: Text('No current prescriptions. Add one below!'));
    }
    return ListView.builder(
      itemCount: _prescriptions.length,
      itemBuilder: (ctx, index) {
        final p = _prescriptions[index];
        final endDateText = p.endDate != null ? _dateFormatter.formats(p.endDate!) : 'Ongoing';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          elevation: 4,
          child: ListTile(
            leading: const Icon(Icons.medication_liquid_outlined, color: Colors.indigo),
            title: Text(p.medication,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dose: ${p.dosage} - ${p.frequency}', style: const TextStyle(fontSize: 14)),
                Text('Prescribed by: ${p.prescribingDoctor}', style: const TextStyle(fontSize: 14)),
              ],
            ),
            isThreeLine: true,
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Starts: ${_dateFormatter.formats(p.startDate)}', style: const TextStyle(fontSize: 12, color: Colors.green)),
                Text('Ends: $endDateText', style: TextStyle(fontSize: 12, color: p.endDate != null ? Colors.red : Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Helper to format TimeOfDay
    final nextAppointmentTime = _nextAppointment['time'].format(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📋 Prescriptions & Appointments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share Prescriptions',
            onPressed: _handleShare,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download Prescriptions',
            onPressed: _handleDownload,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // --- Next Appointment Card (Enhanced) ---
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              color: Colors.blue.shade50,
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.event_available, color: Colors.blue),
                title: Text(
                  'Appointment with ${_nextAppointment['doctor']}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date: ${_dateFormatter.formats(_nextAppointment['date'])} at $nextAppointmentTime',
                      style: const TextStyle(fontSize: 15),
                    ),
                    Text('Location: ${_nextAppointment['location']}', style: const TextStyle(fontSize: 14)),
                  ],
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.edit, size: 20, color: Colors.blue),
                onTap: _selectNextAppointmentDate,
              ),
            ),
          ),
          // --- Prescriptions List Header ---
          const Padding(
            padding: EdgeInsets.fromLTRB(15, 10, 15, 5),
            child: Text(
              'Current Medications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          // --- Prescriptions List (Takes remaining space) ---
          Expanded(
            child: _buildPrescriptionList(),
          ),
        ],
      ),
      // --- Floating Action Button to Add Prescription ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPrescriptionSheet,
        tooltip: 'Add New Prescription',
        label: const Text('Add Prescription'),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// --- Add Prescription Form Widget (Updated) ---
class AddPrescriptionForm extends StatefulWidget {
  final Function(Prescription) onAdd;

  const AddPrescriptionForm({super.key, required this.onAdd});

  @override
  State<AddPrescriptionForm> createState() => _AddPrescriptionFormState();
}

class _AddPrescriptionFormState extends State<AddPrescriptionForm> {
  final _formKey = GlobalKey<FormState>();
  String _medication = '';
  String _dosage = '';
  String _frequency = 'Once Daily';
  String _prescribingDoctor = ''; // New state variable
  DateTime _datePrescribed = DateTime.now();
  DateTime _startDate = DateTime.now();
  DateTime? _endDate; // Nullable

  final List<String> _frequencies = [
    'Once Daily',
    'Twice Daily',
    'Three times a day',
    'Every 4 hours',
    'As needed (PRN)',
  ];

  final DateFormat _dateFormatter = DateFormat.yMMMd();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newPrescription = Prescription(
        medication: _medication,
        dosage: _dosage,
        frequency: _frequency,
        datePrescribed: _datePrescribed,
        prescribingDoctor: _prescribingDoctor,
        startDate: _startDate,
        endDate: _endDate,
      );
      widget.onAdd(newPrescription);
    }
  }

  void _presentDatePicker(
      {required String title,
        required DateTime initialDate,
        required Function(DateTime) onDateTimeChanged,
        required DateTime minimumDate,
        DateTime? maximumDate}) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDate,
                  minimumDate: minimumDate,
                  maximumDate: maximumDate ?? DateTime.now(),
                  onDateTimeChanged: onDateTimeChanged,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Add New Prescription',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.indigo)),
            const SizedBox(height: 20),

            // Medication Name
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Medication Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medical_information, color: Colors.blue),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required.';
                return null;
              },
              onSaved: (value) => _medication = value!,
            ),
            const SizedBox(height: 15),

            // Prescribing Doctor
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Prescribing Doctor',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person, color: Colors.blue),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required.';
                return null;
              },
              onSaved: (value) => _prescribingDoctor = value!, // Save new field
            ),
            const SizedBox(height: 15),

            // Dosage
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Dosage (e.g., 10mg, 5ml)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.scatter_plot, color: Colors.blue),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required.';
                return null;
              },
              onSaved: (value) => _dosage = value!,
            ),
            const SizedBox(height: 15),

            // Frequency Dropdown
            DropdownButtonFormField<String>(
              value: _frequency,
              decoration: const InputDecoration(
                labelText: 'Frequency',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.schedule, color: Colors.blue),
              ),
              items: _frequencies.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) => setState(() => _frequency = newValue!),
              onSaved: (value) => _frequency = value!,
            ),
            const SizedBox(height: 15),

            // --- Date Pickers ---
            const Text('Prescription Dates', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const Divider(),

            // Date Prescribed
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history, color: Colors.blue),
              title: const Text('Date Prescribed'),
              trailing: Text(
                _dateFormatter.formats(_datePrescribed),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              onTap: () => _presentDatePicker(
                  title: 'Prescribed Date',
                  initialDate: _datePrescribed,
                  minimumDate: DateTime(2020),
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (pickedDate) => setState(() => _datePrescribed = pickedDate)),
            ),

            // Start Date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.start, color: Colors.green),
              title: const Text('Start Date'),
              trailing: Text(
                _dateFormatter.formats(_startDate),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              onTap: () => _presentDatePicker(
                  title: 'Start Date',
                  initialDate: _startDate,
                  minimumDate: _datePrescribed, // Cannot start before prescribed
                  onDateTimeChanged: (pickedDate) => setState(() => _startDate = pickedDate)),
            ),

            // End Date (Optional)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(_endDate != null ? Icons.stop : Icons.stop_circle_outlined, color: Colors.red),
              title: const Text('End Date (Optional)'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _endDate != null ? _dateFormatter.formats(_endDate!) : 'Ongoing',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _endDate != null ? Colors.red : Colors.grey),
                  ),
                  if (_endDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 20, color: Colors.red),
                      onPressed: () => setState(() => _endDate = null),
                    ),
                ],
              ),
              onTap: () => _presentDatePicker(
                  title: 'End Date',
                  initialDate: _endDate ?? _startDate.add(const Duration(days: 7)),
                  minimumDate: _startDate, // Must end after start
                  onDateTimeChanged: (pickedDate) => setState(() => _endDate = pickedDate)),
              enabled: _endDate == null || _endDate!.isAfter(_startDate), // Disabled if error state
            ),

            const SizedBox(height: 30),

            // Submit Button
            ElevatedButton.icon(
              onPressed: _submitForm,
              icon: const Icon(Icons.save),
              label: const Text('Save Prescription'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// NOTE: The DateFormat helper class is included here for the code to run,
// but in a real project, you should use 'package:intl/intl.dart'.
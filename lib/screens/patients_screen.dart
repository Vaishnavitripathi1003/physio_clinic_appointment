// ... (imports remain unchanged)

import 'package:flutter/material.dart';
import 'package:physio_clinic_appointment/models/patient_model.dart';
import 'package:physio_clinic_appointment/providers/auth_provider.dart';
import 'package:physio_clinic_appointment/providers/patient_provider.dart';
import 'package:provider/provider.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final pProv = Provider.of<PatientProvider>(context, listen: false);

      if (auth.currentDoctor?.id != null) {
        // 1. ✅ Now passing a String ID to loadPatientsForDoctor
        pProv.loadPatientsForDoctor(auth.currentDoctor!.id!);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final pProv = Provider.of<PatientProvider>(context);

    // currentDoctorId is correctly treated as String?
    final currentDoctorId = auth.currentDoctor?.id;
    final patients = pProv.patients;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
        backgroundColor: const Color(0xFF0FAF7C),
      ),
      body: (currentDoctorId == null || patients.isEmpty)
          ? Center(
        child: currentDoctorId == null
            ? const Text('Please log in as a Doctor.')
            : const Text('No patients registered for this doctor yet.'),
      )
          : ListView.builder(
        itemCount: patients.length,
        itemBuilder: (context, i) {
          final p = patients[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(p.name),
              subtitle: Text(
                  '${p.disease ?? ''} • ${p.age != null ? '${p.age} yrs' : ''}'),
              trailing: PopupMenuButton<String>(
                onSelected: (s) async {
                  // p.id is a String (Firebase key), passed to deletePatient(String id)
                  if (s == 'delete' && p.id != null) await pProv.deletePatient(p.id!);
                  if (s == 'edit') _showEdit(context, pProv, p);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0FAF7C),
        child: const Icon(Icons.add),
        onPressed: () {
          // 2. ✅ Pass currentDoctorId (String?) directly, removed 'as int'
          if (currentDoctorId != null) {
            _showAdd(context, pProv, currentDoctorId);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error: Doctor ID not found.')),
            );
          }
        },
      ),
    );
  }

  // 🧩 Add Patient
  // 3. ✅ Changed doctorId parameter type from int to String
  void _showAdd(BuildContext context, PatientProvider prov, String doctorId) {

    final _form = GlobalKey<FormState>();
    final _name = TextEditingController();
    String gender = 'Female';
    final _age = TextEditingController();
    final _phone = TextEditingController();
    final _disease = TextEditingController();
    String blood = 'O+';
    String marital = 'Single';
    final _notes = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => AnimatedPadding(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Add Patient',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _name,
                        decoration:
                        const InputDecoration(labelText: 'Full name'),
                        validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _age,
                              decoration:
                              const InputDecoration(labelText: 'Age'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _phone,
                              decoration:
                              const InputDecoration(labelText: 'Phone'),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _disease,
                        decoration: const InputDecoration(
                            labelText: 'Disease / Problem'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: blood,
                              items: [
                                'O+',
                                'A+',
                                'B+',
                                'AB+',
                                'O-',
                                'A-',
                                'B-',
                                'AB-'
                              ]
                                  .map((e) => DropdownMenuItem(
                                  value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (v) => setState(() => blood = v!),
                              decoration: const InputDecoration(
                                  labelText: 'Blood Group'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: marital,
                              items: ['Single', 'Married', 'Other']
                                  .map((e) => DropdownMenuItem(
                                  value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (v) => setState(() => marital = v!),
                              decoration: const InputDecoration(
                                  labelText: 'Marital Status'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Gender',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      Column(
                        children: ['Female', 'Male', 'Other']
                            .map(
                              (g) => RadioListTile<String>(
                            title: Text(g),
                            value: g,
                            groupValue: gender,
                            onChanged: (v) =>
                                setState(() => gender = v!),
                          ),
                        )
                            .toList(),
                      ),
                      TextFormField(
                        controller: _notes,
                        decoration:
                        const InputDecoration(labelText: 'Notes'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        onPressed: () async {
                          if (!_form.currentState!.validate()) return;
                          final p = PatientModel(
                            // doctorId is now correctly String
                            doctorId: doctorId,
                            name: _name.text.trim(),
                            gender: gender,
                            age: int.tryParse(_age.text.trim()),
                            phone: _phone.text.trim(),
                            disease: _disease.text.trim(),
                            bloodGroup: blood,
                            maritalStatus: marital,
                            notes: _notes.text.trim(),
                            createdAt: DateTime.now().toIso8601String(),
                          );
                          await prov.addPatient(p);
                          Navigator.pop(ctx);
                        },
                        label: const Text('Save'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0FAF7C),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // 🧩 Edit Patient (No changes needed here as p.id and p.doctorId are already String)
  void _showEdit(BuildContext context, PatientProvider prov, PatientModel p) {
    final _form = GlobalKey<FormState>();
    final _name = TextEditingController(text: p.name);
    String gender = p.gender ?? 'Female';
    final _age = TextEditingController(text: p.age?.toString() ?? '');
    final _phone = TextEditingController(text: p.phone);
    final _disease = TextEditingController(text: p.disease ?? '');
    String blood = p.bloodGroup ?? 'O+';
    String marital = p.maritalStatus ?? 'Single';
    final _notes = TextEditingController(text: p.notes ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => AnimatedPadding(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Edit Patient',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _name,
                        decoration:
                        const InputDecoration(labelText: 'Full name'),
                        validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _age,
                              decoration:
                              const InputDecoration(labelText: 'Age'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _phone,
                              decoration:
                              const InputDecoration(labelText: 'Phone'),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: _disease,
                        decoration: const InputDecoration(
                            labelText: 'Disease / Problem'),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: blood,
                              items: [
                                'O+',
                                'A+',
                                'B+',
                                'AB+',
                                'O-',
                                'A-',
                                'B-',
                                'AB-'
                              ]
                                  .map((e) => DropdownMenuItem(
                                  value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (v) => setState(() => blood = v!),
                              decoration: const InputDecoration(
                                  labelText: 'Blood Group'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: marital,
                              items: ['Single', 'Married', 'Other']
                                  .map((e) => DropdownMenuItem(
                                  value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (v) => setState(() => marital = v!),
                              decoration: const InputDecoration(
                                  labelText: 'Marital Status'),
                            ),
                          ),
                        ],
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Gender',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      Column(
                        children: ['Female', 'Male', 'Other']
                            .map(
                              (g) => RadioListTile<String>(
                            title: Text(g),
                            value: g,
                            groupValue: gender,
                            onChanged: (v) =>
                                setState(() => gender = v!),
                          ),
                        )
                            .toList(),
                      ),
                      TextFormField(
                        controller: _notes,
                        decoration:
                        const InputDecoration(labelText: 'Notes'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        onPressed: () async {
                          if (!_form.currentState!.validate()) return;
                          final updated = PatientModel(
                            id: p.id,
                            doctorId: p.doctorId,
                            name: _name.text.trim(),
                            gender: gender,
                            age: int.tryParse(_age.text.trim()),
                            phone: _phone.text.trim(),
                            disease: _disease.text.trim(),
                            bloodGroup: blood,
                            maritalStatus: marital,
                            notes: _notes.text.trim(),
                            createdAt: p.createdAt,
                          );
                          await prov.updatePatient(updated);
                          Navigator.pop(ctx);
                        },
                        label: const Text('Update'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0FAF7C),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
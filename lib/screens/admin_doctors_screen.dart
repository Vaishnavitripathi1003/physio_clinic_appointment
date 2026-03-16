import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// FIX: Change relative imports to consistent package imports using your package name
// If your package name is 'physio_clinic_appointment', use this:
import 'package:physio_clinic_appointment/providers/doctor_provider.dart';
import 'package:physio_clinic_appointment/models/doctor_model.dart';

class AdminDoctorsScreen extends StatelessWidget {
  const AdminDoctorsScreen({super.key});

  // ---------- WIDGET BUILDER ----------
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<DoctorProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white, // Default background
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 180.0, // Increased height for visual appeal
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent, // Transparent to show the body's gradient
              flexibleSpace: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: FlexibleSpaceBar(
                    centerTitle: true,
                    titlePadding: const EdgeInsets.only(bottom: 16),
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        Text(
                          'Manage Doctors 👩‍⚕️',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Admin Dashboard',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF5563DE), Color(0xFF74ABE2)], // Reversed gradient for better top look
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  onPressed: () => prov.loadDoctors(),
                ),
                const SizedBox(width: 6),
              ],
            ),
          ];
        },
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF74ABE2), Color(0xFF5563DE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: FutureBuilder<void>(
            future: prov.loadDoctors(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.white));
              }

              return Consumer<DoctorProvider>(
                builder: (context, prov, _) {
                  final docs = prov.doctors;

                  // Placeholder for search bar logic to apply filtering
                  final filteredDocs = prov.filteredDoctors.isNotEmpty
                      ? prov.filteredDoctors
                      : docs;

                  return Column(
                    children: [
                      // ---------- Search Bar (Modernized) ----------
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8, left: 16, right: 16, bottom: 8),
                        child: TextField(
                        //  onChanged: prov.filterDoctors,
                          style: const TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                            hintText: 'Search doctor by name or specialization...',
                            hintStyle: TextStyle(color: Colors.grey.shade600),
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF5563DE)),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Color(0xFF5563DE), width: 2),
                            ),
                          ),
                        ),
                      ),

                      // ---------- Doctors List or Empty State ----------
                      Expanded(
                        child: filteredDocs.isEmpty
                            ? _buildEmptyState(context, prov, docs.isEmpty)
                            : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filteredDocs.length,
                          itemBuilder: (context, i) {
                            final d = filteredDocs[i];
                            return DoctorCard(
                              doctor: d,
                              prov: prov,
                              onEdit: () => _showEdit(context, prov, d),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF5563DE),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add Doctor'),
        onPressed: () =>
            _showAdd(context, Provider.of<DoctorProvider>(context, listen: false)),
      ),
    );
  }

  // Helper method for Empty State
  Widget _buildEmptyState(
      BuildContext context, DoctorProvider prov, bool isInitialEmpty) {
    if (isInitialEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.medical_information_rounded,
                color: Colors.white, size: 64),
            const SizedBox(height: 12),
            const Text('No doctors available',
                style: TextStyle(fontSize: 18, color: Colors.white)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _showAdd(context, prov),
              icon: const Icon(Icons.add),
              label: const Text('Add Doctor'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.indigo,
              ),
            ),
          ],
        ),
      );
    } else {
      // Empty state for when the search filter yields no results
      return const Center(
        child: Text(
          'No doctors match your search query.',
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
      );
    }
  }

  // ---------- ADD DOCTOR BOTTOM SHEET ----------
  void _showAdd(BuildContext context, DoctorProvider prov, [DoctorModel? doctor]) {
    // Check if we are in 'Edit' mode
    final isEditing = doctor != null;

    final _form = GlobalKey<FormState>();
    final _name = TextEditingController(text: doctor?.name);
    final _phone = TextEditingController(text: doctor?.phone);
    final _email = TextEditingController(text: doctor?.email);
    final _exp = TextEditingController(text: doctor?.experience?.toString());
    final _fee = TextEditingController(text: doctor?.fee?.toString());
    final _clinic = TextEditingController(text: doctor?.clinicName);
    final _reg = TextEditingController(text: doctor?.regNo);

    // Initial values for dropdowns/radios
    String gender = doctor?.gender ?? 'Female';
    String availability = doctor?.availability ?? 'Full Day';
    String? specialization = doctor?.specialization;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                top: 16,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: StatefulBuilder(builder: (ctx, setState) {
                  return Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                            child: Container(
                              width: 60,
                              height: 5,
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2.5)),
                            )),
                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            isEditing ? 'Edit Doctor' : 'Add New Doctor',
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF5563DE)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // TextFields
                        _buildTextField(_name, 'Full Name', Icons.person),
                        const SizedBox(height: 12),
                        // Gender Radio Buttons
                        const Text('Gender',
                            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                        Row(
                          children: [
                            _buildGenderRadio(setState, 'Male', gender, (v) => gender = v!),
                            _buildGenderRadio(setState, 'Female', gender, (v) => gender = v!),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Specialization Dropdown
                        _buildDropdown(
                          'Specialization',
                          specialization,
                          [
                            'Cardiology',
                            'Dermatology',
                            'Pediatrics',
                            'Orthopedics',
                            'Neurology',
                            'General'
                          ],
                              (v) => setState(() => specialization = v),
                        ),
                        const SizedBox(height: 12),

                        // Experience and Fee
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(_exp, 'Experience (yrs)', Icons.star, TextInputType.number),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTextField(_fee, 'Fee', Icons.attach_money, TextInputType.number),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Phone and Email
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(_phone, 'Phone', Icons.phone, TextInputType.phone),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTextField(_email, 'Email', Icons.email, TextInputType.emailAddress),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Availability Dropdown
                        _buildDropdown(
                          'Availability',
                          availability,
                          ['Morning', 'Afternoon', 'Evening', 'Full Day'],
                              (v) => setState(() => availability = v!),
                        ),
                        const SizedBox(height: 12),

                        // Clinic Name and Registration No
                        _buildTextField(_clinic, 'Clinic Name', Icons.local_hospital),
                        const SizedBox(height: 12),
                        _buildTextField(_reg, 'Registration No', Icons.credit_card),
                        const SizedBox(height: 24),

                        // Save Button
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (!_form.currentState!.validate()) return;

                              final newDoctor = DoctorModel(
                                id: doctor?.id, // Keep ID if editing
                                name: _name.text.trim(),
                                gender: gender,
                                specialization: specialization,
                                phone: _phone.text.trim(),
                                email: _email.text.trim(),
                                experience: int.tryParse(_exp.text.trim()) ?? 0,
                                availability: availability,
                                fee: double.tryParse(_fee.text.trim()) ?? 0.0,
                                clinicName: _clinic.text.trim(),
                                regNo: _reg.text.trim(),
                              );

                              if (isEditing) {
                                await prov.editDoctor(newDoctor);
                              } else {
                                await prov.addDoctor(newDoctor);
                              }

                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(isEditing
                                        ? 'Doctor updated successfully!'
                                        : 'Doctor added successfully!')),
                              );
                            },
                            icon: Icon(isEditing ? Icons.edit : Icons.save),
                            label: Text(isEditing ? 'Update Doctor' : 'Save Doctor'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5563DE),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                }),
              ),
            );
          },
        );
      },
    );
  }

  // Helper method for standard text fields
  Widget _buildTextField(TextEditingController controller, String labelText, IconData icon, [TextInputType keyboardType = TextInputType.text]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.indigo),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF5563DE)),
        ),
      ),
      validator: (v) =>
      (labelText == 'Full Name' && (v == null || v.trim().isEmpty)) ? 'Required' : null,
    );
  }

  // Helper method for radio tiles
  Widget _buildGenderRadio(StateSetter setState, String value, String groupValue, ValueChanged<String?> onChanged) {
    return Expanded(
      child: RadioListTile<String>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        title: Text(value),
        activeColor: const Color(0xFF5563DE),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  // Helper method for dropdowns
  Widget _buildDropdown(String labelText, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF5563DE)),
        ),
      ),
      onChanged: onChanged,
    );
  }


  // ---------- EDIT DOCTOR BOTTOM SHEET (Correctly implemented) ----------
  void _showEdit(BuildContext context, DoctorProvider prov, DoctorModel d) {
    _showAdd(context, prov, d); // Pass the doctor model to the reusable _showAdd
  }
}

// Custom Widget for an attractive Doctor Card (Glassmorphism-inspired)
class DoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  final DoctorProvider prov;
  final VoidCallback onEdit;

  const DoctorCard({
    required this.doctor,
    required this.prov,
    required this.onEdit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2), // Light background for contrast
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Subtle blur for glass effect
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Text(
                doctor.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF5563DE),
                    fontSize: 20),
              ),
            ),
            title: Text(
              doctor.name,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.white), // White text on gradient background
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  doctor.specialization ?? 'General Practitioner',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
                if (doctor.availability != null)
                  Text("Available: ${doctor.availability!}",
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 13, fontStyle: FontStyle.italic)),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (s) async {
                if (s == 'delete') {
                  await prov.deleteDoctor(doctor.id!);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Doctor deleted successfully')));
                  }
                }
                if (s == 'edit') {
                  onEdit();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit Doctor 📝')),
                PopupMenuItem(value: 'delete', child: Text('Delete Doctor 🗑️', style: TextStyle(color: Colors.red))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

// --- 1. Data Model for a Clinical Note ---
class ClinicalNote {
  final String id;
  final DateTime date;
  String subject; // e.g., "Post-Op Checkup", "Initial Assessment"
  String content; // The main body of the clinical notes (could be SOAP or free text)

  ClinicalNote({
    required this.id,
    required this.date,
    required this.subject,
    required this.content,
  });

  // Factory constructor for creating a new note with a unique ID and current date
  factory ClinicalNote.create({
    required String subject,
    required String content,
  }) {
    return ClinicalNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      subject: subject,
      content: content,
    );
  }

  // Helper to format the date
  String get formattedDate => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

// --- 2. Main Stateful Widget: EMR Screen ---
class EMRScreen extends StatefulWidget {
  const EMRScreen({super.key});

  @override
  State<EMRScreen> createState() => _EMRScreenState();
}

class _EMRScreenState extends State<EMRScreen> {
  // Mock EMR Data
  List<ClinicalNote> _notes = [
    ClinicalNote(
      id: '1',
      date: DateTime(2025, 11, 1),
      subject: 'Initial Assessment: Right Knee Pain',
      content: 'Patient reports sharp pain (7/10) with weight-bearing. Limited range of motion (ROM) in flexion. Started with gentle mobilization and TENS application.',
    ),
    ClinicalNote(
      id: '2',
      date: DateTime(2025, 11, 5),
      subject: 'Follow-up Session: Mobilization',
      content: 'Pain reduced to 4/10. ROM improved by 10 degrees. Increased passive flexion exercises. Will introduce strengthening bands next week.',
    ),
  ];

  // --- Utility Methods ---

  // Handles adding or editing a note
  void _saveNote(ClinicalNote newNote) {
    setState(() {
      final index = _notes.indexWhere((note) => note.id == newNote.id);
      if (index != -1) {
        // Update existing note
        _notes[index] = newNote;
      } else {
        // Add new note (ID generated in the factory constructor)
        _notes.insert(0, newNote); // Insert at the top
      }
    });
    Navigator.of(context).pop();
  }

  void _deleteNote(String id) {
    setState(() {
      _notes.removeWhere((note) => note.id == id);
    });
    // Optional: Show a snackbar confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Clinical note deleted.')),
    );
  }

  void _showNoteModal({ClinicalNote? noteToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: _NoteForm(
          onSave: _saveNote,
          initialNote: noteToEdit,
        ),
      ),
    );
  }

  // --- UI Builder Methods ---

  Widget _buildNoteList() {
    if (_notes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.description_outlined, size: 60, color: Colors.grey),
              SizedBox(height: 10),
              Text('No Clinical Notes found.', style: TextStyle(fontSize: 18)),
              Text('Tap the "+" button to add a new assessment or session note.', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _notes.length,
      itemBuilder: (ctx, index) {
        final note = _notes[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          elevation: 3,
          child: ListTile(
            leading: const Icon(Icons.library_books, color: Colors.indigo, size: 30),
            title: Text(note.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              note.content.length > 100
                  ? '${note.content.substring(0, 100)}...'
                  : note.content,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(note.formattedDate, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blue)),
                const SizedBox(height: 4),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
            onTap: () => _showNoteModal(noteToEdit: note), // View/Edit
            onLongPress: () {
              // Option to delete note
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Note?'),
                  content: Text('Are you sure you want to delete the note: "${note.subject}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _deleteNote(note.id);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Delete', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EMR / Clinical Notes'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _buildNoteList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNoteModal(noteToEdit: null),
        label: const Text('Add New Note'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// --- 3. Note Form Widget for Add/Edit Functionality ---
class _NoteForm extends StatefulWidget {
  final ClinicalNote? initialNote;
  final Function(ClinicalNote) onSave;

  const _NoteForm({this.initialNote, required this.onSave});

  @override
  __NoteFormState createState() => __NoteFormState();
}

class __NoteFormState extends State<_NoteForm> {
  final _formKey = GlobalKey<FormState>();
  late String _subject;
  late String _content;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    // Initialize form fields with existing note data or defaults
    _subject = widget.initialNote?.subject ?? '';
    _content = widget.initialNote?.content ?? '';
    _date = widget.initialNote?.date ?? DateTime.now();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Determine if we are creating a new note or updating an existing one
      final noteToSave = widget.initialNote != null
          ? ClinicalNote(
        id: widget.initialNote!.id,
        date: _date,
        subject: _subject,
        content: _content,
      )
          : ClinicalNote.create(
        subject: _subject,
        content: _content,
      );

      widget.onSave(noteToSave);
    }
  }

  // Simple date picker helper (since we don't have intl)
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialNote != null;
    final noteDate = ClinicalNote(id: '', date: _date, subject: '', content: '').formattedDate;

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              isEditing ? 'Edit Clinical Note' : 'New Clinical Note',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            const Divider(),

            // Date Picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today, color: Colors.blue),
              title: const Text('Date of Note'),
              trailing: Text(
                noteDate,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 15),

            // Subject/Title Field
            TextFormField(
              initialValue: _subject,
              decoration: const InputDecoration(
                labelText: 'Note Subject/Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Subject is required.';
                return null;
              },
              onSaved: (value) => _subject = value!,
            ),
            const SizedBox(height: 15),

            // Content/Body Field
            TextFormField(
              initialValue: _content,
              maxLines: 10,
              minLines: 5,
              decoration: const InputDecoration(
                labelText: 'Clinical Notes (e.g., SOAP or Free Text)',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Content cannot be empty.';
                return null;
              },
              onSaved: (value) => _content = value!,
            ),
            const SizedBox(height: 25),

            // Save Button
            ElevatedButton.icon(
              onPressed: _submitForm,
              icon: Icon(isEditing ? Icons.edit : Icons.save),
              label: Text(isEditing ? 'Update Note' : 'Create Note'),
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
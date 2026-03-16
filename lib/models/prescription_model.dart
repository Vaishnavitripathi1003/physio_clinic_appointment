// Updated Prescription Model (as defined above)
class Prescription {
  final String medication;
  final String dosage;
  final String frequency;
  final DateTime datePrescribed;
  final String prescribingDoctor;
  final DateTime startDate;
  final DateTime? endDate;

  Prescription({
    required this.medication,
    required this.dosage,
    required this.frequency,
    required this.datePrescribed,
    required this.prescribingDoctor,
    required this.startDate,
    this.endDate,
  });
}
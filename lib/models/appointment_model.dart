class AppointmentModel {
  int? id;
  int patientId;
  int doctorId;
  String datetime;
  String? status;
  String? symptoms;
  String? diagnosis;
  String? treatment;
  String? paymentMode;

  AppointmentModel({this.id, required this.patientId, required this.doctorId, required this.datetime, this.status, this.symptoms, this.diagnosis, this.treatment, this.paymentMode});

  Map<String, dynamic> toMap() => {
    'id': id,
    'patientId': patientId,
    'doctorId': doctorId,
    'datetime': datetime,
    'status': status,
    'symptoms': symptoms,
    'diagnosis': diagnosis,
    'treatment': treatment,
    'paymentMode': paymentMode,
  };

  factory AppointmentModel.fromMap(Map<String, dynamic> m) => AppointmentModel(
    id: m['id'],
    patientId: m['patientId'],
    doctorId: m['doctorId'],
    datetime: m['datetime'],
    status: m['status'],
    symptoms: m['symptoms'],
    diagnosis: m['diagnosis'],
    treatment: m['treatment'],
    paymentMode: m['paymentMode'],
  );
}

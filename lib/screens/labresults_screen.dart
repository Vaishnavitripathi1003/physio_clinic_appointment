import 'package:flutter/material.dart';
import 'dart:math';

// --- 1. Enumeration for Result Status ---
enum ResultStatus {
  normal,
  high,
  low,
  critical,
  pending,
}

// --- 2. Data Model for a Single Lab Result ---
class LabResult {
  final String id;
  final DateTime orderDate;
  final DateTime sampleCollectedDate; // New field
  final DateTime resultDate;
  final String testName;
  final double resultValue;
  final String unit;
  final double refRangeLow;
  final double refRangeHigh;
  final ResultStatus status;
  final String labFacility;
  final String patientId;        // New field
  final String patientName;      // New field
  final String prescribedBy;     // New field

  LabResult({
    required this.id,
    required this.orderDate,
    required this.sampleCollectedDate, // Required
    required this.resultDate,
    required this.testName,
    required this.resultValue,
    required this.unit,
    required this.refRangeLow,
    required this.refRangeHigh,
    required this.status,
    required this.labFacility,
    required this.patientId, // Required
    required this.patientName, // Required
    required this.prescribedBy, // Required
  });

  // Helper to format dates
  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  // Explicit formatters for clarity
  String get formattedResultDate => _formatDate(resultDate);
  String get formattedOrderDate => _formatDate(orderDate);
  String get formattedSampleCollectedDate => _formatDate(sampleCollectedDate);


  // Helper to get color based on status
  Color get statusColor {
    switch (status) {
      case ResultStatus.critical:
        return Colors.red.shade700;
      case ResultStatus.high:
      case ResultStatus.low:
        return Colors.orange.shade700;
      case ResultStatus.pending:
        return Colors.grey.shade500;
      case ResultStatus.normal:
      default:
        return Colors.green.shade700;
    }
  }

  // Helper to get descriptive status text
  String get statusText {
    switch (status) {
      case ResultStatus.critical:
        return 'CRITICAL ABNORMAL';
      case ResultStatus.high:
        return 'High';
      case ResultStatus.low:
        return 'Low';
      case ResultStatus.pending:
        return 'Pending';
      case ResultStatus.normal:
      default:
        return 'Normal';
    }
  }
}

// --- 3. Main Stateless Widget: Lab Results Screen ---
class LabResultsScreen extends StatelessWidget {
  const LabResultsScreen({super.key});

  // Mock Lab Data (Simulating fetched results)
  static final List<LabResult> _mockResults = [
    LabResult(
      id: 'L001',
      patientName: 'Rohan Sharma',
      patientId: 'P1001',
      prescribedBy: 'Dr. A. K. Varma',
      orderDate: DateTime(2025, 10, 20),
      sampleCollectedDate: DateTime(2025, 10, 20),
      resultDate: DateTime(2025, 10, 21),
      testName: 'Complete Blood Count (CBC)',
      resultValue: 14.5,
      unit: 'g/dL',
      refRangeLow: 13.0,
      refRangeHigh: 17.0,
      status: ResultStatus.normal,
      labFacility: 'City Diagnostics Lab',
    ),
    LabResult(
      id: 'L002',
      patientName: 'Priya Verma',
      patientId: 'P1002',
      prescribedBy: 'Dr. S. K. Gupta',
      orderDate: DateTime(2025, 10, 20),
      sampleCollectedDate: DateTime(2025, 10, 20),
      resultDate: DateTime(2025, 10, 21),
      testName: 'Fasting Blood Glucose',
      resultValue: 135, // High
      unit: 'mg/dL',
      refRangeLow: 70,
      refRangeHigh: 99,
      status: ResultStatus.high,
      labFacility: 'City Diagnostics Lab',
    ),
    LabResult(
      id: 'L003',
      patientName: 'Amit Singh',
      patientId: 'P1003',
      prescribedBy: 'Dr. M. J. Khan',
      orderDate: DateTime(2025, 11, 1),
      sampleCollectedDate: DateTime(2025, 11, 1),
      resultDate: DateTime(2025, 11, 2),
      testName: 'Serum Potassium',
      resultValue: 2.8, // Critical Low
      unit: 'mEq/L',
      refRangeLow: 3.5,
      refRangeHigh: 5.1,
      status: ResultStatus.critical,
      labFacility: 'Starlight Hospital Lab',
    ),
    LabResult(
      id: 'L004',
      patientName: 'Jane Doe',
      patientId: 'P1004',
      prescribedBy: 'Dr. A. B. Shetty',
      orderDate: DateTime(2025, 11, 5),
      sampleCollectedDate: DateTime(2025, 11, 5),
      resultDate: DateTime(2025, 11, 5).add(const Duration(days: 3)), // Simulate 3 days wait
      testName: 'Vitamin D, 25-Hydroxy',
      resultValue: 0, // Placeholder for pending
      unit: 'ng/mL',
      refRangeLow: 30,
      refRangeHigh: 100,
      status: ResultStatus.pending,
      labFacility: 'City Diagnostics Lab',
    ),
  ];

  // --- Utility Functions ---

  void _showResultDetails(BuildContext context, LabResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ResultDetailModal(result: result),
    );
  }

  void _openNewLabOrderModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: const _NewLabOrderModal(),
      ),
    );
  }

  // --- UI Builder Methods ---

  Widget _buildResultTile(BuildContext context, LabResult result) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: result.status == ResultStatus.critical
            ? BorderSide(color: result.statusColor, width: 2) // Red border for critical
            : BorderSide.none,
      ),
      child: ListTile(
        leading: Icon(
          result.status == ResultStatus.critical
              ? Icons.error_outline
              : result.status == ResultStatus.pending
              ? Icons.hourglass_empty
              : Icons.check_circle_outline,
          color: result.statusColor,
          size: 36,
        ),
        title: Text(
          result.testName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patient: ${result.patientName} (ID: ${result.patientId})', // Displaying Patient details
              style: TextStyle(color: Colors.indigo.shade700, fontWeight: FontWeight.w600),
            ),
            Text(
              'Result Date: ${result.formattedResultDate} | Lab: ${result.labFacility}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              result.statusText,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: result.statusColor,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            result.status != ResultStatus.pending
                ? Text(
              '${result.resultValue} ${result.unit}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            )
                : const Text('...'),
          ],
        ),
        onTap: () => _showResultDetails(context, result),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 Lab Orders & Results'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: _mockResults.length,
        itemBuilder: (context, index) {
          return _buildResultTile(context, _mockResults[index]);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNewLabOrderModal(context),
        label: const Text('Place New Order'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// --- 4. Result Detail Modal ---
class _ResultDetailModal extends StatelessWidget {
  final LabResult result;

  const _ResultDetailModal({required this.result});

  Widget _buildDetailRow(String label, String value, {Color? valueColor, FontWeight weight = FontWeight.normal}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: weight,
              color: valueColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  result.testName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.indigo),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: result.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  result.statusText,
                  style: TextStyle(
                    color: result.statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),

          // --- Patient and Admin Details ---
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildDetailRow('Patient Name', result.patientName, weight: FontWeight.bold),
                _buildDetailRow('Patient ID', result.patientId),
                _buildDetailRow('Prescribed By', result.prescribedBy),
              ],
            ),
          ),
          const Divider(height: 20),

          // Core Result Details
          _buildDetailRow(
            'Result Value',
            '${result.resultValue} ${result.unit}',
            valueColor: result.status == ResultStatus.normal ? Colors.green.shade700 : result.statusColor,
            weight: FontWeight.bold,
          ),

          _buildDetailRow('Reference Range', '${result.refRangeLow} - ${result.refRangeHigh} ${result.unit}'),

          const Divider(height: 20),

          // Administrative Details
          _buildDetailRow('Order Date', result.formattedOrderDate),
          _buildDetailRow('Sample Collected', result.formattedSampleCollectedDate),
          _buildDetailRow('Result Release Date', result.formattedResultDate),
          _buildDetailRow('Lab Facility', result.labFacility),

          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Viewing PDF/Full Report...')),
              );
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('View Full Report (PDF)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ],
      ),
    );
  }
}

// --- 5. New Lab Order Creation Modal ---
class _NewLabOrderModal extends StatefulWidget {
  const _NewLabOrderModal();

  @override
  State<_NewLabOrderModal> createState() => __NewLabOrderModalState();
}

class __NewLabOrderModalState extends State<_NewLabOrderModal> {
  final _formKey = GlobalKey<FormState>();

  // Form State variables, corresponding to LabResult fields
  String _testName = '';
  double? _resultValue;
  String _unit = 'mg/dL';
  double? _refRangeLow;
  double? _refRangeHigh;
  ResultStatus _status = ResultStatus.pending; // Default status is pending
  String _labFacility = 'City Diagnostics Lab';
  String _patientId = '';
  String _patientName = '';
  String _prescribedBy = '';

  // Date variables (crucial for new order)
  DateTime? _orderDate;
  DateTime? _sampleCollectedDate;
  DateTime? _resultDate;

  final List<String> _commonUnits = ['g/dL', 'mg/dL', 'mEq/L', 'ng/mL', '%'];
  final List<String> _labFacilities = ['City Diagnostics Lab', 'Starlight Hospital Lab', 'General Clinic Lab'];


  // --- Date Picker Utility ---
  Future<void> _selectDate(BuildContext context, {required Function(DateTime) onSelect, required DateTime? initialDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      onSelect(picked);
    }
  }

  // --- Submission Logic ---
  void _submitOrder() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Ensure required dates are set
      if (_orderDate == null || _sampleCollectedDate == null || _resultDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select all three required dates.')),
        );
        return;
      }

      // Create a mock LabResult object (typically you'd send this to a backend/database)
      final newResult = LabResult(
        id: 'L' + (Random().nextInt(9999) + 1000).toString(), // Mock ID
        orderDate: _orderDate!,
        sampleCollectedDate: _sampleCollectedDate!,
        resultDate: _resultDate!,
        testName: _testName,
        // Since it's a new order, we will set result fields only if status is NOT pending.
        resultValue: _status != ResultStatus.pending ? (_resultValue ?? 0.0) : 0.0,
        unit: _unit,
        refRangeLow: _refRangeLow ?? 0.0,
        refRangeHigh: _refRangeHigh ?? 0.0,
        status: _status,
        labFacility: _labFacility,
        patientId: _patientId,
        patientName: _patientName,
        prescribedBy: _prescribedBy,
      );

      debugPrint('--- NEW LAB ORDER SUBMITTED ---');
      debugPrint('Test: ${_testName} for ${_patientName}');
      debugPrint('Status: ${newResult.statusText}');
      debugPrint('Order Date: ${newResult.formattedOrderDate}');

      // In a real app, you would send newResult to your provider/API here.
      // For this mock, we just close the modal.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('New Lab Order for "${_testName}" placed successfully!')),
      );

      Navigator.of(context).pop();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Header ---
              Text(
                'New Lab Order Entry ➕',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.teal.shade700),
              ),
              const Divider(height: 25),

              // --- Patient & Prescriber Details ---
              Text('Patient & Administration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Patient Full Name', prefixIcon: Icon(Icons.person)),
                validator: (value) => value!.isEmpty ? 'Enter patient name' : null,
                onSaved: (value) => _patientName = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Patient ID (e.g., P1005)', prefixIcon: Icon(Icons.badge)),
                validator: (value) => value!.isEmpty ? 'Enter patient ID' : null,
                onSaved: (value) => _patientId = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Prescribed By (Doctor)', prefixIcon: Icon(Icons.medical_services)),
                validator: (value) => value!.isEmpty ? 'Enter prescriber name' : null,
                onSaved: (value) => _prescribedBy = value!,
              ),
              const SizedBox(height: 20),

              // --- Test Details ---
              Text('Test Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Test Name (e.g., Lipid Panel)', prefixIcon: Icon(Icons.science)),
                validator: (value) => value!.isEmpty ? 'Enter test name' : null,
                onSaved: (value) => _testName = value!,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Lab Facility', prefixIcon: Icon(Icons.local_hospital)),
                value: _labFacility,
                items: _labFacilities.map((String facility) {
                  return DropdownMenuItem<String>(value: facility, child: Text(facility));
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _labFacility = newValue!;
                  });
                },
                onSaved: (value) => _labFacility = value!,
              ),
              const SizedBox(height: 20),

              // --- Date Pickers ---
              Text('Order & Sample Dates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
              _buildDateSelection('Order Date', _orderDate, (date) => setState(() => _orderDate = date), Icons.calendar_today),
              _buildDateSelection('Sample Collected Date', _sampleCollectedDate, (date) => setState(() => _sampleCollectedDate = date), Icons.watch_later),

              // Only allow setting result date if order is pending/normal (not always needed at order time)
              _buildDateSelection('Expected Result Date', _resultDate, (date) => setState(() => _resultDate = date), Icons.date_range),
              const SizedBox(height: 20),

              // --- Result Data (Conditional based on Status) ---
              Text('Result Status & Value', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
              DropdownButtonFormField<ResultStatus>(
                decoration: const InputDecoration(labelText: 'Result Status', prefixIcon: Icon(Icons.assignment_turned_in)),
                value: _status,
                items: ResultStatus.values.map((ResultStatus status) {
                  return DropdownMenuItem<ResultStatus>(value: status, child: Text(status.name.toUpperCase()));
                }).toList(),
                onChanged: (ResultStatus? newValue) {
                  setState(() {
                    _status = newValue!;
                  });
                },
                onSaved: (value) => _status = value!,
              ),
              const SizedBox(height: 10),

              // Only show result fields if status is not 'pending'
              if (_status != ResultStatus.pending) ...[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Result Value', prefixIcon: Icon(Icons.score)),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) => value!.isEmpty ? 'Enter result value' : null,
                  onSaved: (value) => _resultValue = double.tryParse(value!),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Reference Range Low', prefixIcon: Icon(Icons.arrow_downward)),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onSaved: (value) => _refRangeLow = double.tryParse(value!),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Reference Range High', prefixIcon: Icon(Icons.arrow_upward)),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onSaved: (value) => _refRangeHigh = double.tryParse(value!),
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Unit', prefixIcon: Icon(Icons.straighten)),
                  value: _unit,
                  items: _commonUnits.map((String unit) {
                    return DropdownMenuItem<String>(value: unit, child: Text(unit));
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _unit = newValue!;
                    });
                  },
                  onSaved: (value) => _unit = value!,
                ),
              ],


              const SizedBox(height: 30),

              // --- Submit Button ---
              ElevatedButton.icon(
                onPressed: _submitOrder,
                icon: const Icon(Icons.send),
                label: const Text('Submit New Lab Order'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for Date selection
  Widget _buildDateSelection(String label, DateTime? selectedDate, Function(DateTime) onSelect, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          TextButton(
            onPressed: () => _selectDate(context, onSelect: onSelect, initialDate: selectedDate),
            child: Text(
              selectedDate == null
                  ? 'SELECT DATE'
                  : '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
              style: TextStyle(
                color: selectedDate == null ? Colors.red.shade700 : Colors.indigo.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


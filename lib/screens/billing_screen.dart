import 'package:flutter/material.dart';

// --- 1. Data Model for Invoice Item ---
class InvoiceItem {
  final String description;
  final int quantity;
  final double unitPrice;
  final double gstRate; // e.g., 0.18 for 18%

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.gstRate,
  });

  // Calculated properties
  double get taxableAmount => quantity * unitPrice;
  double get gstAmount => taxableAmount * gstRate;
  double get total => taxableAmount + gstAmount;
}

// --- 2. Main Stateful Widget: Billing Screen ---
class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Invoice State
  List<InvoiceItem> _items = [
    InvoiceItem(description: 'Physiotherapy Session', quantity: 1, unitPrice: 800.0, gstRate: 0.18),
    InvoiceItem(description: 'Massage Oil (Litre)', quantity: 2, unitPrice: 350.0, gstRate: 0.12),
  ];
  String _invoiceNumber = 'INV-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}-001';
  DateTime _invoiceDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  double _discountPercentage = 5.0; // 5% discount

  // Form input controllers for adding new items
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();
  double _selectedGstRate = 0.18; // Default GST 18%

  // GST Rate options (as required in India)
  final List<double> _gstRates = [0.0, 0.05, 0.12, 0.18, 0.28]; // 0%, 5%, 12%, 18%, 28%

  // --- 3. Calculation Logic ---

  double get _subtotal {
    return _items.fold(0.0, (sum, item) => sum + item.taxableAmount);
  }

  double get _totalGstAmount {
    return _items.fold(0.0, (sum, item) => sum + item.gstAmount);
  }

  double get _discountAmount {
    return _subtotal * (_discountPercentage / 100.0);
  }

  double get _grandTotal {
    return (_subtotal - _discountAmount) + _totalGstAmount;
  }

  // --- 4. Utility Functions ---

  String _formatCurrency(double amount) {
    return '₹ ${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _addItem() {
    if (_formKey.currentState!.validate()) {
      final newItem = InvoiceItem(
        description: _descriptionController.text,
        quantity: int.parse(_quantityController.text),
        unitPrice: double.parse(_unitPriceController.text),
        gstRate: _selectedGstRate,
      );

      setState(() {
        _items.add(newItem);
        _descriptionController.clear();
        _quantityController.clear();
        _unitPriceController.clear();
      });
      Navigator.of(context).pop(); // Close the modal
    }
  }

  void _showAddItemModal(BuildContext context) {
    // Reset inputs for new item
    _descriptionController.clear();
    _quantityController.clear();
    _unitPriceController.clear();
    _selectedGstRate = 0.18;

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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add New Service/Product', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (val) => val!.isEmpty ? 'Enter a description' : null,
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (val) => int.tryParse(val!) == null ? 'Invalid number' : null,
              ),
              TextFormField(
                controller: _unitPriceController,
                decoration: const InputDecoration(labelText: 'Unit Price (₹)'),
                keyboardType: TextInputType.number,
                validator: (val) => double.tryParse(val!) == null ? 'Invalid price' : null,
              ),
              const SizedBox(height: 10),
              // GST Rate Dropdown
              DropdownButtonFormField<double>(
                value: _selectedGstRate,
                decoration: const InputDecoration(
                  labelText: 'GST Rate',
                  border: OutlineInputBorder(),
                ),
                items: _gstRates.map((rate) {
                  return DropdownMenuItem(
                    value: rate,
                    child: Text('${(rate * 100).toInt()}% GST'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGstRate = value!;
                  });
                },
                validator: (value) => value == null ? 'Select GST Rate' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add),
                label: const Text('Add Item to Invoice'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 5. UI Builder Methods ---

  Widget _buildHeader() {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('INVOICE', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.indigo)),
            const Divider(),
            _buildInfoRow('Invoice No:', _invoiceNumber),
            _buildInfoRow('Invoice Date:', _formatDate(_invoiceDate)),
            _buildInfoRow('Due Date:', _formatDate(_dueDate)),
            const SizedBox(height: 15),
            Text('Billed To:', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const Text('Mr. Rohan Sharma, Appointment ID: #9034'),
            const Text('Address: 123 Health Ave, Pune, Maharashtra'),
            const Text('GSTIN: 27AAAAA1234A1Z5 (Mock)'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildItemsTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            ),
            child: Row(
              children: const [
                Expanded(flex: 3, child: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Price', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Total (Inc. GST)', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          // Item Rows
          ..._items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text('${item.description} (${(item.gstRate * 100).toInt()}% GST)', style: TextStyle(fontSize: 13, color: Colors.grey.shade700))),
                  Expanded(flex: 1, child: Text('${item.quantity}')),
                  Expanded(flex: 2, child: Text(_formatCurrency(item.unitPrice), textAlign: TextAlign.right)),
                  Expanded(flex: 2, child: Text(_formatCurrency(item.total), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            );
          }).toList(),
          if (_items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text('No items added yet.')),
            ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(top: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow('Subtotal (Taxable Value):', _formatCurrency(_subtotal)),
            _buildInfoRow('Total GST Amount:', _formatCurrency(_totalGstAmount)),
            _buildInfoRow('Discount (${_discountPercentage.toStringAsFixed(0)}%):', '- ${_formatCurrency(_discountAmount)}'),
            const Divider(height: 20),
            _buildInfoRow(
              'GRAND TOTAL (INR):',
              _formatCurrency(_grandTotal),
            ),
            const SizedBox(height: 10),
            Text(
              'Amount in words: One Thousand, Five Hundred Seventy-Five Rupees Only (Mock)',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧾 Billing & Invoice Creator'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // 1. Invoice Header
            _buildHeader(),

            // 2. Items Table
            _buildItemsTable(),

            const SizedBox(height: 10),

            // 3. Add Item Button
            ElevatedButton.icon(
              onPressed: () => _showAddItemModal(context),
              icon: const Icon(Icons.add_shopping_cart, size: 20),
              label: const Text('Add Service/Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade50,
                foregroundColor: Colors.green.shade800,
              ),
            ),

            // 4. Summary & Calculations
            _buildSummary(),

            // 5. Terms and Conditions
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Terms & Conditions:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(
                    '1. Goods once sold will not be taken back.\n2. Payment due within 7 days of invoice date.\n3. All disputes are subject to Pune jurisdiction.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const Divider(height: 30),
                  const Center(
                    child: Text('Authorized Signature', style: TextStyle(fontStyle: FontStyle.italic)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Action buttons at the bottom
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invoice data saved successfully!')),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text('Save Draft'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Generating PDF for ${_invoiceNumber}...')),
                  );
                },
                icon: const Icon(Icons.print),
                label: const Text('Print / Export PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
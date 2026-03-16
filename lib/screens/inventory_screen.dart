import 'package:flutter/material.dart';

// --- 1. Data Model for an Inventory Item ---
class InventoryItem {
  final String id;
  final String name;
  final String dosage;
  final int quantity;
  final DateTime expiryDate;
  final double unitCost;
  final int lowStockThreshold;
  final String location; // E.g., Shelf A, Cabinet 3
  final String category; // New: e.g., 'Medication', 'Vaccine', 'Supply'

  InventoryItem({
    required this.id,
    required this.name,
    required this.dosage,
    required this.quantity,
    required this.expiryDate,
    required this.unitCost,
    this.lowStockThreshold = 10,
    required this.location,
    required this.category, // New mandatory field
  });

  // Helper to determine if stock is critical
  bool get isLowStock => quantity <= lowStockThreshold;

  // Helper to check for expiry (within 30 days is near expiry)
  bool get isExpired {
    final now = DateTime.now();
    return expiryDate.isBefore(now.subtract(const Duration(days: 1)));
  }

  // Helper to check for near expiry (within 30 days)
  bool get isNearExpiry {
    final now = DateTime.now();
    final nearExpiryDate = now.add(const Duration(days: 30));
    return expiryDate.isAfter(now) && expiryDate.isBefore(nearExpiryDate);
  }

  // Helper to format date (no intl dependency)
  String get formattedExpiryDate => '${expiryDate.day.toString().padLeft(2, '0')}/${expiryDate.month.toString().padLeft(2, '0')}/${expiryDate.year}';
}

// --- 2. Main Stateful Widget: Inventory Screen ---
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _searchQuery = '';
  String _categoryFilter = 'All Categories';
  String _statusFilter = 'All Statuses'; // Options: 'All Statuses', 'Low Stock', 'Expired', 'Near Expiry'

  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = ['All Categories', 'Medication', 'Vaccine', 'Supply'];
  final List<String> _statuses = ['All Statuses', 'Low Stock', 'Expired', 'Near Expiry'];

  // Mock Inventory Data (Updated with category)
  final List<InventoryItem> _allItems = [
    InventoryItem(
      id: 'D001',
      name: 'Amoxicillin',
      dosage: '500mg capsules',
      quantity: 45,
      expiryDate: DateTime(2026, 8, 1),
      unitCost: 0.15,
      location: 'Aisle 1, Shelf B',
      category: 'Medication',
    ),
    InventoryItem(
      id: 'D002',
      name: 'Paracetamol',
      dosage: '650mg tablets',
      quantity: 5, // Low stock
      expiryDate: DateTime(2025, 12, 10), // Near expiry
      unitCost: 0.05,
      lowStockThreshold: 10,
      location: 'Aisle 2, Drawer 1',
      category: 'Medication',
    ),
    InventoryItem(
      id: 'V003',
      name: 'Flu Vaccine',
      dosage: '0.5ml injection',
      quantity: 10, // Low stock
      expiryDate: DateTime(2025, 11, 20),
      unitCost: 15.00,
      location: 'Fridge 1',
      category: 'Vaccine',
    ),
    InventoryItem(
      id: 'S004',
      name: 'Sterile Gloves',
      dosage: 'Size M',
      quantity: 150,
      expiryDate: DateTime(2027, 3, 15),
      unitCost: 1.20,
      location: 'Storage Room',
      category: 'Supply',
    ),
    InventoryItem(
      id: 'D005',
      name: 'Expired Test Drug',
      dosage: '10mg',
      quantity: 2,
      expiryDate: DateTime(2024, 1, 1), // Expired
      unitCost: 5.00,
      location: 'Quarantine Bin',
      category: 'Medication',
    ),
    InventoryItem(
      id: 'S006',
      name: 'Bandages',
      dosage: 'Assorted',
      quantity: 300,
      expiryDate: DateTime(2028, 5, 5),
      unitCost: 0.50,
      location: 'First Aid',
      category: 'Supply',
    ),
  ];

  // --- Utility Methods: Combined Filtering Logic ---

  List<InventoryItem> get _filteredItems {
    // 1. Start with all items
    Iterable<InventoryItem> items = _allItems;

    // 2. Apply Search Filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      items = items.where((item) {
        return item.name.toLowerCase().contains(query) ||
            item.dosage.toLowerCase().contains(query) ||
            item.id.toLowerCase().contains(query);
      });
    }

    // 3. Apply Category Filter (Dropdown)
    if (_categoryFilter != 'All Categories') {
      items = items.where((item) => item.category == _categoryFilter);
    }

    // 4. Apply Status Filter (Segmented Buttons)
    if (_statusFilter == 'Low Stock') {
      // Exclude expired items from 'Low Stock' for cleaner triage
      items = items.where((item) => item.isLowStock && !item.isExpired);
    } else if (_statusFilter == 'Expired') {
      items = items.where((item) => item.isExpired);
    } else if (_statusFilter == 'Near Expiry') {
      items = items.where((item) => item.isNearExpiry && !item.isExpired);
    }

    return items.toList();
  }

  void _updateSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  // --- 3. UI Builder Methods ---

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Category Dropdown
          const Padding(
            padding: EdgeInsets.only(bottom: 4, top: 4),
            child: Text('Filter by Category:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          DropdownButtonFormField<String>(
            value: _categoryFilter,
            items: _categories.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _categoryFilter = newValue;
                });
              }
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: Colors.indigo.shade50,
            ),
          ),

          const SizedBox(height: 12),

          // Row 2: Status Filter (Segmented Control / Radio Button style)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('Filter by Status:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _statuses.map((status) {
              bool isSelected = _statusFilter == status;
              Color color = Colors.grey.shade100;
              Color textColor = Colors.black;

              if (status == 'Low Stock' && isSelected) {
                color = Colors.yellow.shade700;
                textColor = Colors.white;
              } else if (status == 'Expired' && isSelected) {
                color = Colors.red.shade700;
                textColor = Colors.white;
              } else if (status == 'All Statuses' && isSelected) {
                color = Colors.indigo.shade500;
                textColor = Colors.white;
              }

              return ChoiceChip(
                label: Text(status),
                selected: isSelected,
                selectedColor: color,
                backgroundColor: Colors.grey.shade200,
                labelStyle: TextStyle(
                  color: isSelected ? textColor : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (selected) {
                  setState(() {
                    _statusFilter = status;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildInventoryTile(BuildContext context, InventoryItem item) {
    // Determine the color and icon for the leading indicator
    Color leadingColor = Colors.blue.shade100;
    IconData leadingIcon = Icons.medical_services_outlined;

    if (item.isExpired) {
      leadingColor = Colors.red.shade700;
      leadingIcon = Icons.warning_amber;
    } else if (item.isNearExpiry) {
      leadingColor = Colors.orange.shade200;
      leadingIcon = Icons.timer_outlined;
    } else if (item.isLowStock) {
      leadingColor = Colors.yellow.shade200;
      leadingIcon = Icons.error_outline;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        // Add border color if the item is low or expired
        side: BorderSide(
          color: item.isExpired ? Colors.red.shade500 : (item.isLowStock ? Colors.orange.shade300 : Colors.transparent),
          width: item.isExpired || item.isLowStock ? 1.5 : 0,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: leadingColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(leadingIcon, color: Colors.black87),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.dosage, style: TextStyle(color: Colors.grey.shade600)),
            Text('ID: ${item.id} | Location: ${item.location} | Cat: ${item.category}',
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Quantity Display
            Text(
              'Qty: ${item.quantity}',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: item.isExpired
                    ? Colors.red.shade900
                    : (item.isLowStock ? Colors.orange.shade800 : Colors.green.shade800),
              ),
            ),
            const SizedBox(height: 4),
            // Expiry Status
            Text(
              item.isExpired ? 'EXPIRED' : (item.isNearExpiry ? 'NEAR EXPIRY' : 'Exp: ${item.formattedExpiryDate}'),
              style: TextStyle(
                fontSize: 11,
                fontWeight: item.isExpired || item.isNearExpiry ? FontWeight.bold : FontWeight.normal,
                color: item.isExpired ? Colors.red.shade700 : (item.isNearExpiry ? Colors.orange.shade700 : Colors.grey.shade500),
              ),
            ),
          ],
        ),
        onTap: () => _showDetailModal(context, item),
      ),
    );
  }

  void _showDetailModal(BuildContext context, InventoryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _InventoryDetailModal(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('💊 Inventory / Pharmacy Stock'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _updateSearch,
              decoration: InputDecoration(
                labelText: 'Search Medication or ID',
                hintText: 'e.g., Amoxicillin, D001',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _updateSearch('');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              ),
            ),
          ),

          // --- Filter Bar (New Functionality) ---
          _buildFilterBar(),

          // Low Stock/Expired Alert Banner (Sticky)
          if (items.any((i) => i.isLowStock || i.isExpired))
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              margin: const EdgeInsets.only(bottom: 8),
              color: Colors.red.shade50,
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ATTENTION: ${items.where((i) => i.isExpired).length} expired and ${items.where((i) => i.isLowStock && !i.isExpired).length} low stock items found in this view.',
                      style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

          // Inventory List
          Expanded(
            child: items.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey.shade400),
                    const SizedBox(height: 10),
                    const Text('No items match the selected filters.', style: TextStyle(fontSize: 18)),
                    Text('Search Query: "$_searchQuery"', style: TextStyle(color: Colors.grey.shade600)),
                    Text('Category: $_categoryFilter | Status: $_statusFilter', style: TextStyle(color: Colors.grey.shade600)),
                    const SizedBox(height: 20),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _updateSearch('');
                          _categoryFilter = 'All Categories';
                          _statusFilter = 'All Statuses';
                        });
                      },
                      icon: const Icon(Icons.restart_alt, color: Colors.indigo),
                      label: const Text('Clear All Filters', style: TextStyle(color: Colors.indigo)),
                    ),
                  ],
                ),
              ),
            )
                : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _buildInventoryTile(context, items[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Opening form to add new inventory item...')),
          );
        },
        label: const Text('Add New Stock'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// --- 4. Inventory Detail Modal (Reused) ---
class _InventoryDetailModal extends StatelessWidget {
  final InventoryItem item;

  const _InventoryDetailModal({required this.item});

  Widget _buildDetailRow(String label, String value, {Color? valueColor, FontWeight weight = FontWeight.normal}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                fontWeight: weight,
                color: valueColor ?? Colors.black,
              ),
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
          // Header and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  item.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.indigo),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: item.isExpired ? Colors.red.shade100 : (item.isLowStock ? Colors.orange.shade100 : Colors.green.shade100),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  item.isExpired ? 'EXPIRED' : (item.isLowStock ? 'LOW STOCK' : 'In Stock'),
                  style: TextStyle(
                    color: item.isExpired ? Colors.red.shade900 : (item.isLowStock ? Colors.orange.shade900 : Colors.green.shade900),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),

          // Core Details
          _buildDetailRow('Item ID', item.id),
          _buildDetailRow('Category', item.category),
          _buildDetailRow('Dosage/Specification', item.dosage),
          _buildDetailRow(
            'Current Quantity',
            '${item.quantity}',
            weight: FontWeight.bold,
            valueColor: item.isLowStock ? Colors.orange.shade800 : Colors.green.shade800,
          ),
          _buildDetailRow('Low Stock Threshold', '${item.lowStockThreshold} units'),

          const Divider(height: 20),

          // Administrative Details
          _buildDetailRow('Expiry Date', item.formattedExpiryDate,
            valueColor: item.isExpired ? Colors.red.shade700 : (item.isNearExpiry ? Colors.orange.shade700 : null),
            weight: item.isExpired || item.isNearExpiry ? FontWeight.bold : FontWeight.normal,
          ),
          _buildDetailRow('Storage Location', item.location),
          _buildDetailRow('Unit Cost', '\$${item.unitCost.toStringAsFixed(2)}'),
          _buildDetailRow('Total Value (Est.)', '\$${(item.unitCost * item.quantity).toStringAsFixed(2)}', weight: FontWeight.w600),

          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Re-ordering ${item.name} initiated.')),
                    );
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Re-order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
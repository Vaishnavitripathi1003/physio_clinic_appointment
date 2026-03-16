import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/dashboard_screen.dart' hide AuthProvider;
import '../screens/schedule_screen.dart';
import '../screens/appointments_screen.dart';
import '../screens/patients_screen.dart';
import '../screens/teleconsult_screen.dart';
import '../screens/emr_screen.dart';
import '../screens/prescription_screen.dart';
import '../screens/billing_screen.dart';
import '../screens/inventory_screen.dart';
import '../screens/labresults_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final doctor = auth.currentDoctor;

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0FAF7C), Color(0xFF2AB7A9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white24,
                  child: Text(
                    doctor?.name.substring(0, 1).toUpperCase() ?? 'D',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor?.name ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctor?.clinicName ?? '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Verified',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: 8),
                _drawerItem(
                  context,
                  Icons.grid_view,
                  'Dashboard',
                      () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DashboardScreen(),
                    ),
                  ),
                ),
                _drawerItem(
                  context,
                  Icons.schedule,
                  'My Schedule',
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ScheduleScreen(),
                    ),
                  ),
                ),
                _drawerItem(
                  context,
                  Icons.event_note,
                  'Appointments',
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AppointmentsScreen(),
                    ),
                  ),
                ),
                _drawerItem(
                  context,
                  Icons.person,
                  'Patients',
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PatientsScreen(),
                    ),
                  ),
                ),
                _drawerItem(
                  context,
                  Icons.call,
                  'Teleconsult / Calls',
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TeleconsultScreen(),
                    ),
                  ),
                ),
                _drawerItem(
                  context,
                  Icons.note,
                  'EMR / Clinical Notes',
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EMRScreen(),
                    ),
                  ),
                ),
                _drawerItem(
                  context,
                  Icons.receipt_long,
                  'Prescriptions',
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrescriptionScreen(),
                    ),
                  ),
                ),
                _drawerItem(
                  context,
                  Icons.payment,
                  'Billing & Invoices',
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BillingScreen(),
                    ),
                  ),
                ),
                const Divider(),
                _drawerItem(
                  context,
                  Icons.inventory,
                  'Inventory / Pharmacy',
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InventoryScreen(),
                    ),
                  ),
                ),
                _drawerItem(
                  context,
                  Icons.science,
                  'Lab Orders & Results',
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LabResultsScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
      BuildContext context,
      IconData icon,
      String title,
      VoidCallback onTap,
      ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF0FAF7C)),
      title: Text(title),
      onTap: onTap,
    );
  }
}

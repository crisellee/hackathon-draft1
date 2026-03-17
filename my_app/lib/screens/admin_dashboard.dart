import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/concern.dart';
import '../services/concern_service.dart';
import '../services/report_service.dart';
import 'concern_detail_screen.dart';
import 'package:intl/intl.dart';

final concernsStreamProvider = StreamProvider<List<Concern>>((ref) {
  return ref.watch(concernServiceProvider).streamAllConcerns();
});

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  ConcernCategory? _filterCategory;
  String? _filterDept;

  @override
  Widget build(BuildContext context) {
    final concernsAsync = ref.watch(concernsStreamProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Staff Management Console', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        actions: [
          TextButton.icon(
            onPressed: () => ref.read(concernServiceProvider).enforceSLA(),
            icon: const Icon(Icons.refresh_rounded, size: 18, color: Colors.red),
            label: const Text('Audit SLA', style: TextStyle(color: Colors.red)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: concernsAsync.when(
        data: (concerns) {
          var filtered = concerns;
          if (_filterCategory != null) filtered = filtered.where((c) => c.category == _filterCategory).toList();
          if (_filterDept != null) filtered = filtered.where((c) => c.department == _filterDept).toList();
          
          return _buildMainContent(filtered, concerns);
        },
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (err, stack) => Center(child: Text('System Error: $err')),
      ),
    );
  }

  Widget _buildMainContent(List<Concern> filtered, List<Concern> all) {
    final now = DateTime.now();
    final slaBreaches = all.where((c) =>
      (c.status == ConcernStatus.routed && now.difference(c.createdAt).inDays >= 2) ||
      (c.status == ConcernStatus.read && c.lastUpdatedAt != null && now.difference(c.lastUpdatedAt!).inDays >= 5)
    ).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Professional Metrics Bar ---
          Row(
            children: [
              _metricTile('Active Cases', all.length.toString(), Icons.folder_open, Colors.blue),
              _metricTile('Resolved', all.where((c) => c.status == ConcernStatus.resolved).length.toString(), Icons.check_circle_outline, Colors.green),
              _metricTile('SLA Breach', slaBreaches.toString(), Icons.notification_important_outlined, Colors.red),
            ],
          ),
          const SizedBox(height: 32),

          // --- Action Bar ---
          Row(
            children: [
              const Text('Request Registry', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              _buildFilterDropdowns(),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => ReportService().generateAndPrintReport(filtered),
                icon: const Icon(Icons.print_rounded, size: 18),
                label: const Text('Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- Registry Data Table ---
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
                  columnSpacing: 40,
                  columns: const [
                    DataColumn(label: Text('REF ID', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('STUDENT', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('CATEGORY', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('SUBMITTED', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: filtered.map((c) => _buildDataRow(c)).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(Concern c) {
    return DataRow(
      cells: [
        DataCell(Text(c.id.substring(0, 8).toUpperCase(), style: const TextStyle(fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.w500))),
        DataCell(Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.studentName, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            Text(c.program, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        )),
        DataCell(Text(c.category.name.toUpperCase(), style: const TextStyle(fontSize: 12))),
        DataCell(_statusBadge(c.status)),
        DataCell(Text(DateFormat('yyyy-MM-dd HH:mm').format(c.createdAt), style: const TextStyle(fontSize: 12))),
        DataCell(IconButton(
          icon: const Icon(Icons.open_in_new_rounded, size: 18, color: Colors.red),
          onPressed: () => Navigator.push(context, MaterialPageRoute(
            builder: (context) => ConcernDetailScreen(concern: c, isAdmin: true),
          )),
        )),
      ],
    );
  }

  Widget _statusBadge(ConcernStatus status) {
    Color color = Colors.grey;
    switch (status) {
      case ConcernStatus.submitted: color = Colors.blue; break;
      case ConcernStatus.routed: color = Colors.purple; break;
      case ConcernStatus.read: color = Colors.orange; break;
      case ConcernStatus.screened: color = Colors.teal; break;
      case ConcernStatus.resolved: color = Colors.green; break;
      case ConcernStatus.escalated: color = Colors.red; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  Widget _metricTile(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 16),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdowns() {
    return Row(
      children: [
        DropdownButton<ConcernCategory>(
          value: _filterCategory,
          hint: const Text('All Categories', style: TextStyle(fontSize: 13)),
          underline: const SizedBox(),
          items: [
            const DropdownMenuItem(value: null, child: Text('All Categories')),
            ...ConcernCategory.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name.toUpperCase()))),
          ],
          onChanged: (v) => setState(() => _filterCategory = v),
        ),
        const SizedBox(width: 16),
        DropdownButton<String>(
          value: _filterDept,
          hint: const Text('All Depts', style: TextStyle(fontSize: 13)),
          underline: const SizedBox(),
          items: [
            const DropdownMenuItem(value: null, child: Text('All Departments')),
            ...['COA', 'COE', 'CCS', 'CBAE'].map((e) => DropdownMenuItem(value: e, child: Text(e))),
          ],
          onChanged: (v) => setState(() => _filterDept = v),
        ),
      ],
    );
  }
}

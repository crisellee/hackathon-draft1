import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
<<<<<<< HEAD
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

=======
import 'package:fl_chart/fl_chart.dart';
import '../models/concern.dart';
import '../services/concern_service.dart';
import '../services/report_service.dart';
import 'audit_trail_view.dart';
import 'package:intl/intl.dart';


final concernsStreamProvider = StreamProvider<List<Concern>>((ref) {
  return ref.watch(concernServiceProvider).getConcerns();
});


class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});


>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2
  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

<<<<<<< HEAD
=======

>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2
class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  ConcernCategory? _filterCategory;
  String? _filterDept;

<<<<<<< HEAD
=======

>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2
  @override
  Widget build(BuildContext context) {
    final concernsAsync = ref.watch(concernsStreamProvider);

<<<<<<< HEAD
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
=======

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard - ConcernTrack'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Trigger SLA Check',
            onPressed: () => ref.read(concernServiceProvider).checkSLAEnforcement(),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export PDF Report',
            onPressed: () => _exportPDF(context, concernsAsync.value ?? []),
          ),
>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2
        ],
      ),
      body: concernsAsync.when(
        data: (concerns) {
<<<<<<< HEAD
          var filtered = concerns;
          if (_filterCategory != null) filtered = filtered.where((c) => c.category == _filterCategory).toList();
          if (_filterDept != null) filtered = filtered.where((c) => c.department == _filterDept).toList();
          
          return _buildMainContent(filtered, concerns);
        },
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (err, stack) => Center(child: Text('System Error: $err')),
=======
          var filteredConcerns = concerns;
          if (_filterCategory != null) {
            filteredConcerns = filteredConcerns.where((c) => c.category == _filterCategory).toList();
          }
          if (_filterDept != null) {
            filteredConcerns = filteredConcerns.where((c) => c.assignedTo == _filterDept).toList();
          }
          return _buildDashboard(context, filteredConcerns, concerns, ref);
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.red)),
        error: (err, stack) => Center(child: Text('Error: $err')),
>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2
      ),
    );
  }

<<<<<<< HEAD
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
=======

  Widget _buildDashboard(BuildContext context, List<Concern> filtered, List<Concern> allConcerns, WidgetRef ref) {
    final total = allConcerns.length;
    final resolved = allConcerns.where((c) => c.status == ConcernStatus.resolved).length;
    final escalated = allConcerns.where((c) => c.status == ConcernStatus.escalated).length;

    final now = DateTime.now();
    final slaBreaches = allConcerns.where((c) =>
    (c.status == ConcernStatus.routed && now.difference(c.createdAt).inDays >= 2) ||
        (c.status == ConcernStatus.read && c.lastUpdatedAt != null && now.difference(c.lastUpdatedAt!).inDays >= 5)
    ).length;


    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetricsCards(total, resolved, escalated, slaBreaches),
          const SizedBox(height: 24),
          _buildFilterBar(),
          const SizedBox(height: 24),
          const Text('Category Distribution (All)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(height: 200, child: _buildCategoryChart(allConcerns)),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Concerns (${filtered.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () => _exportCSV(context, filtered),
                icon: const Icon(Icons.table_view, color: Colors.red),
                label: const Text('Export CSV', style: TextStyle(color: Colors.red)),
>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2
              ),
            ],
          ),
          const SizedBox(height: 16),
<<<<<<< HEAD

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
=======
          if (filtered.isEmpty)
            const Center(child: Padding(
              padding: EdgeInsets.all(40.0),
              child: Text('No concerns match the current filters.', style: TextStyle(color: Colors.grey)),
            ))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final concern = filtered[index];
                final isSlaBreached = (concern.status == ConcernStatus.routed && now.difference(concern.createdAt).inDays >= 2) ||
                    (concern.status == ConcernStatus.read && concern.lastUpdatedAt != null && now.difference(concern.lastUpdatedAt!).inDays >= 5);

                return Card(
                  elevation: isSlaBreached ? 4 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: isSlaBreached ? const BorderSide(color: Colors.red, width: 1.5) : BorderSide.none,
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(concern.status).withOpacity(0.2),
                      child: Icon(
                          isSlaBreached ? Icons.priority_high : _getStatusIcon(concern.status),
                          color: isSlaBreached ? Colors.red : _getStatusColor(concern.status)
                      ),
                    ),
                    title: Text(concern.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        '${concern.category.name.toUpperCase()} • ${concern.status.name.toUpperCase()}\n'
                            'Dept: ${concern.assignedTo ?? "Pending"}'
                    ),
                    isThreeLine: true,
                    trailing: _buildStatusAction(context, concern, ref),
                    onTap: () => _handleConcernTap(context, concern, ref),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }


  IconData _getStatusIcon(ConcernStatus status) {
    switch (status) {
      case ConcernStatus.submitted: return Icons.send;
      case ConcernStatus.routed: return Icons.alt_route;
      case ConcernStatus.read: return Icons.mark_email_read;
      case ConcernStatus.screened: return Icons.fact_check;
      case ConcernStatus.resolved: return Icons.check_circle;
      case ConcernStatus.escalated: return Icons.warning;
    }
  }


  Widget _buildFilterBar() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filters', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<ConcernCategory>(
                    decoration: const InputDecoration(labelText: 'Category', contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                    value: _filterCategory,
                    onChanged: (val) => setState(() => _filterCategory = val),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Categories')),
                      ...ConcernCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.name.toUpperCase()))),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Department', contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                    value: _filterDept,
                    onChanged: (val) => setState(() => _filterDept = val),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All Departments')),
                      DropdownMenuItem(value: 'COA', child: Text('COA')),
                      DropdownMenuItem(value: 'COE', child: Text('COE')),
                      DropdownMenuItem(value: 'CCS', child: Text('CCS')),
                      DropdownMenuItem(value: 'CBAE', child: Text('CBAE')),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear_all, color: Colors.red),
                  tooltip: 'Clear All Filters',
                  onPressed: () => setState(() {
                    _filterCategory = null;
                    _filterDept = null;
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  void _handleConcernTap(BuildContext context, Concern concern, WidgetRef ref) {
    if (concern.status == ConcernStatus.routed) {
      ref.read(concernServiceProvider).updateStatus(concern.id, ConcernStatus.read, 'admin_user');
    }
    _showDetails(context, concern);
  }


  Widget _buildMetricsCards(int total, int resolved, int escalated, int slaBreaches) {
    return Column(
      children: [
        Row(
          children: [
            _metricCard('Total', total.toString(), Colors.red, Icons.list_alt),
            _metricCard('Resolved', resolved.toString(), Colors.green, Icons.check_circle_outline),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _metricCard('Escalated', escalated.toString(), Colors.orange, Icons.trending_up),
            _metricCard('SLA Breaches', slaBreaches.toString(), Colors.red, Icons.report_problem),
          ],
        ),
      ],
    );
  }


  Widget _metricCard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildCategoryChart(List<Concern> concerns) {
    final counts = <ConcernCategory, int>{};
    for (var cat in ConcernCategory.values) {
      counts[cat] = concerns.where((c) => c.category == cat).length;
    }


    if (concerns.isEmpty) return const Center(child: Text('No data for chart'));


    return PieChart(
      PieChartData(
        sections: counts.entries.map((e) {
          return PieChartSectionData(
            value: e.value.toDouble(),
            title: '${e.key.name}\n${e.value}',
            color: _getCategoryColor(e.key),
            radius: 80,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }).toList(),
      ),
    );
  }


  Color _getCategoryColor(ConcernCategory category) {
    switch (category) {
      case ConcernCategory.academic: return Colors.red;
      case ConcernCategory.financial: return Colors.orange;
      case ConcernCategory.welfare: return Colors.pink;
    }
  }


  Color _getStatusColor(ConcernStatus status) {
    switch (status) {
      case ConcernStatus.submitted: return Colors.grey;
      case ConcernStatus.routed: return Colors.red;
      case ConcernStatus.read: return Colors.orange;
      case ConcernStatus.screened: return Colors.cyan;
      case ConcernStatus.resolved: return Colors.green;
      case ConcernStatus.escalated: return Colors.red;
    }
  }


  Widget _buildStatusAction(BuildContext context, Concern concern, WidgetRef ref) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'history') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AuditTrailView(concernId: concern.id)));
        } else {
          final status = ConcernStatus.values.firstWhere((e) => e.name == value);
          ref.read(concernServiceProvider).updateStatus(concern.id, status, 'admin_user');
        }
      },
      itemBuilder: (context) {
        // Filter out 'escalated' as requested
        final filteredStatuses = ConcernStatus.values.where((s) => s != ConcernStatus.escalated).toList();
        return [
          ...filteredStatuses.map((s) => PopupMenuItem(value: s.name, child: Text('Mark as ${s.name.toUpperCase()}'))),
          const PopupMenuDivider(),
          const PopupMenuItem(value: 'history', child: Text('Full Audit History')),
        ];
      },
      child: const Icon(Icons.more_vert),
    );
  }


  void _showDetails(BuildContext context, Concern concern) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(concern.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _detailRow('Status', concern.status.name.toUpperCase(), _getStatusColor(concern.status)),
                    _detailRow('Category', concern.category.name.toUpperCase(), Colors.black87),
                    _detailRow('Student', concern.isAnonymous ? "Anonymous Submission" : "ID: ${concern.studentId}", Colors.black87),
                    _detailRow('Program', concern.program, Colors.black87),
                    _detailRow('Department', concern.assignedTo ?? 'Unassigned', Colors.red),
                    const SizedBox(height: 20),
                    const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                      child: Text(concern.description, style: const TextStyle(fontSize: 16, height: 1.5)),
                    ),
                    const SizedBox(height: 24),
                    const Text('Attachments:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    if (concern.attachments.isEmpty)
                      const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('No files attached.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)))
                    else
                      ...concern.attachments.map((a) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: const Icon(Icons.file_present, color: Colors.red),
                          title: Text(a.split('/').last),
                          trailing: const Icon(Icons.download_rounded),
                        ),
                      )),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AuditTrailView(concernId: concern.id)));
                      },
                      icon: const Icon(Icons.history_edu),
                      label: const Text('View Action Log (Audit Trail)'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _detailRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
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
=======

  void _exportPDF(BuildContext context, List<Concern> concerns) async {
    final reportService = ReportService();
    await reportService.generateAndPrintReport(concerns, category: _filterCategory?.name, department: _filterDept);
  }


  void _exportCSV(BuildContext context, List<Concern> concerns) async {
    final reportService = ReportService();
    await reportService.exportToCSV(concerns);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV Data logged to console (Exported)')));
  }
}

>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2

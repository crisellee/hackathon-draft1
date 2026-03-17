import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/concern.dart';
import '../services/concern_service.dart';
import '../services/report_service.dart';
import 'concern_detail_screen.dart';
import 'audit_trail_view.dart';
import 'package:intl/intl.dart';

final concernsStreamProvider = StreamProvider<List<Concern>>((ref) {
  return ref.watch(concernServiceProvider).getConcerns();
});

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {

  ConcernCategory? _filterCategory;
  String? _filterDept;

  DateTime? _selectedMonth;

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
            onPressed: () => ref.read(concernServiceProvider).checkSLAEnforcement(),
            icon: const Icon(Icons.refresh_rounded, size: 18, color: Colors.red),
            label: const Text('Audit SLA', style: TextStyle(color: Colors.red)),
          ),

          IconButton(
            icon: const Icon(Icons.forum_outlined),
            tooltip: 'Support Logs',
            onPressed: () => _showSupportLogs(context),
          ),

          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Select Month',
            onPressed: () => _pickMonth(context),
          ),

          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export PDF Report',
            onPressed: () => _exportPDF(context, concernsAsync.value ?? []),
          ),
        ],
      ),

      body: concernsAsync.when(
        data: (concerns) {

          var filtered = concerns;

          if (_filterCategory != null) {
            filtered = filtered.where((c) => c.category == _filterCategory).toList();
          }

          if (_filterDept != null) {
            filtered = filtered.where((c) => c.assignedTo == _filterDept).toList();
          }

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

          Row(
            children: [
              _metricTile('Active Cases', all.length.toString(), Icons.folder_open, Colors.blue),
              _metricTile('Resolved', all.where((c) => c.status == ConcernStatus.resolved).length.toString(), Icons.check_circle_outline, Colors.green),
              _metricTile('SLA Breach', slaBreaches.toString(), Icons.notification_important_outlined, Colors.red),
            ],
          ),

          const SizedBox(height: 24),

          _buildMonthlyAnalytics(all),

          const SizedBox(height: 24),

          const Text('Category Distribution (All)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

          const SizedBox(height: 16),

          SizedBox(height: 200, child: _buildCategoryChart(all)),

          const SizedBox(height: 24),

          /// NEW ANALYTICS GRAPH
          _buildMonthlyAnalyticsGraph(all),

          const SizedBox(height: 32),

          Row(
            children: [
              const Text('Request Registry', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              _buildFilterDropdowns(),
              const SizedBox(width: 12),

              ElevatedButton.icon(
                onPressed: () => _exportPDF(context, filtered),
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

          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.02 * 255).toInt()), blurRadius: 10)],
            ),

            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),

              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,

                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
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

  Future<void> _pickMonth(BuildContext context) async {

    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  Widget _buildMonthlyAnalytics(List<Concern> concerns) {

    if (_selectedMonth == null) {
      return const SizedBox();
    }

    final monthly = concerns.where((c) =>
    c.createdAt.year == _selectedMonth!.year &&
        c.createdAt.month == _selectedMonth!.month).toList();

    final resolved = monthly.where((c) => c.status == ConcernStatus.resolved).length;
    final pending = monthly.length - resolved;

    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            "Monthly Analytics (${DateFormat('MMMM yyyy').format(_selectedMonth!)})",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              _metricTile("Total Cases", monthly.length.toString(), Icons.folder, Colors.blue),
              _metricTile("Resolved", resolved.toString(), Icons.check_circle, Colors.green),
              _metricTile("Pending", pending.toString(), Icons.pending_actions, Colors.orange),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMonthlyAnalyticsGraph(List<Concern> concerns) {

    final Map<int, int> monthlyCounts = {};

    for (var i = 1; i <= 12; i++) {
      monthlyCounts[i] = 0;
    }

    for (var c in concerns) {
      final month = c.createdAt.month;
      monthlyCounts[month] = (monthlyCounts[month] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Analytics Report (Monthly Cases)",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 250,

            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = [
                          'J','F','M','A','M','J','J','A','S','O','N','D'
                        ];
                        if (value.toInt() < 0 || value.toInt() > 11) {
                          return const SizedBox();
                        }
                        return Text(months[value.toInt()]);
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(12, (index) {
                      final count = monthlyCounts[index + 1] ?? 0;
                      return FlSpot(index.toDouble(), count.toDouble());
                    }),
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                  )
                ],
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
        DataCell(Row(
          children: [
            IconButton(
              icon: const Icon(Icons.open_in_new_rounded, size: 18, color: Colors.red),
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                builder: (context) => ConcernDetailScreen(concern: c, isAdmin: true),
              )),
            ),
            _buildStatusAction(context, c, ref),
          ],
        )),
      ],
    );
  }

  Widget _statusBadge(ConcernStatus status) {
    Color color = _getStatusColor(status);
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
      case ConcernStatus.submitted: return Colors.blue;
      case ConcernStatus.routed: return Colors.purple;
      case ConcernStatus.read: return Colors.orange;
      case ConcernStatus.screened: return Colors.teal;
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
        final filteredStatuses = ConcernStatus.values.where((s) => s != ConcernStatus.escalated).toList();
        return [
          ...filteredStatuses.map((s) => PopupMenuItem(value: s.name, child: Text('Mark as ${s.name.toUpperCase()}'))),
          const PopupMenuDivider(),
          const PopupMenuItem(value: 'history', child: Text('Full Audit History')),
        ];
      },
      child: const Icon(Icons.more_vert, size: 18),
    );
  }

  void _showSupportLogs(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              AppBar(
                title: const Text("Student AI Chat Logs"),
                automaticallyImplyLeading: false,
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                actions: [
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))
                ],
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('support_chats')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No chat logs found."));
                    }
                    final chats = snapshot.data!.docs;
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        final data = chats[index].data() as Map<String, dynamic>;
                        final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: data['role'] == 'user' ? Colors.red : Colors.blue,
                            child: Icon(data['role'] == 'user' ? Icons.person : Icons.smart_toy, color: Colors.white, size: 20),
                          ),
                          title: Text(data['message'] ?? ""),
                          subtitle: Text(
                            "ID: ${data['studentId']} • ${timestamp != null ? DateFormat('MMM dd, HH:mm').format(timestamp) : 'Pending'}",
                            style: const TextStyle(fontSize: 11),
                          ),
                          isThreeLine: true,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _exportPDF(BuildContext context, List<Concern> concerns) async {
    final reportService = ReportService();
    await reportService.generateAndPrintReport(concerns, category: _filterCategory?.name, department: _filterDept);
  }
}

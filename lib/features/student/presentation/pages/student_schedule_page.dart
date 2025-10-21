import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../student/domain/entities/activity_item.dart';
import '../bloc/student_bloc.dart';
import '../../../student/domain/entities/student.dart' as student_domain;

class StudentSchedulePage extends StatefulWidget {
  final student_domain.Student? initialStudent;
  const StudentSchedulePage({super.key, this.initialStudent});

  @override
  State<StudentSchedulePage> createState() => _StudentSchedulePageState();
}

class _StudentSchedulePageState extends State<StudentSchedulePage> {
  student_domain.Student? _student;
  DateTime _start = _mondayOfWeek(DateTime.now());
  DateTime _end = _mondayOfWeek(DateTime.now()).add(const Duration(days: 6));
  List<ActivityItem> _items = [];
  bool _loading = false;
  String? _error;

  static DateTime _mondayOfWeek(DateTime d) => d.subtract(Duration(days: (d.weekday + 6) % 7));

  @override
  void initState() {
    super.initState();
    _student = widget.initialStudent;
    // If student not provided, user must pick from list first
    if (_student == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final picked = await Navigator.pushNamed(context, '/student/list', arguments: {'pickMode': true});
        if (picked is student_domain.Student) {
          setState(() => _student = picked);
          _load();
        } else {
          if (mounted) Navigator.pop(context);
        }
      });
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    if (_student == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
  final repo = context.read<StudentBloc>().repository;
      final items = await repo.getActivities(
        studentId: _student!.id,
        startWeek: _fmtDate(_start),
        endWeek: _fmtDate(_end),
      );
      setState(() => _items = items);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  String _fmtDate(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final days = List.generate(7, (i) => _start.add(Duration(days: i)));
    final grouped = <int, List<ActivityItem>>{}; // key: dayIndex 0..6
    for (final it in _items) {
      final idx = it.date.difference(_start).inDays;
      if (idx >= 0 && idx < 7) {
        (grouped[idx] ??= []).add(it);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _start,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        final monday = _mondayOfWeek(picked);
                        setState(() {
                          _start = monday;
                          _end = monday.add(const Duration(days: 6));
                        });
                        _load();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_outlined, size: 20),
                          const SizedBox(width: 8),
                          Text('${_fmtDate(_start)} — ${_fmtDate(_end)}'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _loading ? null : _load,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reload'),
                ),
              ],
            ),
          ),
          if (_loading) const LinearProgressIndicator(minHeight: 2),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: _buildTable(days, grouped),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<DateTime> days, Map<int, List<ActivityItem>> grouped) {
    // Collect all unique time slots across the week
    final slots = <String>{}; // e.g., 07:00-08:00
    for (final list in grouped.values) {
      for (final a in list) {
        if (a.startTime.length >= 5 && a.endTime.length >= 5) {
          slots.add('${a.startTime.substring(0, 5)}-${a.endTime.substring(0, 5)}');
        }
      }
    }
    final orderedSlots = slots.toList()..sort((a, b) => a.compareTo(b));
    if (orderedSlots.isEmpty) {
      // Ensure at least one row to keep table shape
      orderedSlots.add('07:00-08:00');
    }

    final headerCells = <Widget>[
      _th('SLOT'),
      for (final d in days) _th('${_weekdayShort(d.weekday)}\n${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}', center: true),
    ];

    final rows = <TableRow>[
      TableRow(children: headerCells),
      for (final slot in orderedSlots)
        _rowFor(slot, grouped),
    ];

    return Table(
      columnWidths: {
        0: const FlexColumnWidth(1.2),
        for (int i = 1; i <= 7; i++) i: const FlexColumnWidth(1),
      },
      border: TableBorder.all(color: Colors.grey.shade300, width: 0.8),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: rows,
    );
  }

  TableRow _rowFor(String slot, Map<int, List<ActivityItem>> grouped) {
    final parts = slot.split('-');
    final start = parts[0];
    final end = parts.length > 1 ? parts[1] : '';
    return TableRow(
      children: [
        _td(Text('$start - $end', style: const TextStyle(fontWeight: FontWeight.w600))),
        for (int i = 0; i < 7; i++)
          _td(_cellFor(grouped[i] ?? const [], start, end)),
      ],
    );
  }

  Widget _th(String text, {bool center = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      color: Colors.grey.shade100,
      alignment: center ? Alignment.center : Alignment.centerLeft,
      child: Text(
        text,
        textAlign: center ? TextAlign.center : TextAlign.left,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _td(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      constraints: const BoxConstraints(minHeight: 44),
      child: child,
    );
  }

  Widget _cellFor(List<ActivityItem> items, String start, String end) {
    final match = items.firstWhere(
      (e) => e.startTime.startsWith(start) && e.endTime.startsWith(end),
      orElse: () => ActivityItem(id: 0, name: '', date: DateTime.now(), dayOfWeek: '', startTime: start, endTime: end),
    );
    if (match.id == 0 || match.name.isEmpty) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF3498DB).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        match.name,
        style: const TextStyle(fontSize: 12),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String _weekdayShort(int weekday) {
    const names = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return names[(weekday + 6) % 7];
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../student/domain/entities/student.dart' as student_domain;
import '../../domain/entities/admission_term.dart';
import '../bloc/admission_bloc.dart';

class AdmissionFormPage extends StatelessWidget {
  final student_domain.Student? initialStudent; // optional when opened from menu
  const AdmissionFormPage({super.key, this.initialStudent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admission Form')),
      body: BlocConsumer<AdmissionBloc, AdmissionState>(
        listener: (context, state) async {
          if (state is AdmissionError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is AdmissionSubmitSuccess) {
            if (!context.mounted) return;
            // Capture Navigator before awaiting to avoid using BuildContext across async gaps
            final navigator = Navigator.of(context);
            // Don't await the dialog to avoid an async gap involving this BuildContext
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Admission Submitted'),
                content: const Text('Your admission form has been submitted. Please finish your payment.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      // Use captured NavigatorState to avoid referencing context after await
                      navigator.pushReplacementNamed('/admission/forms');
                    },
                    child: const Text('View All Forms'),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AdmissionInitial) {
            // Kick off loading and show a spinner instead of a blank screen
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<AdmissionBloc>().add(LoadActiveTerm());
            });
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdmissionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdmissionError) {
            final msg = state.message;
            final isAuth = msg.toLowerCase().contains('auth');
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text('Unable to load admission term', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(msg, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade700)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<AdmissionBloc>().add(LoadActiveTerm());
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (isAuth)
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                        },
                        icon: const Icon(Icons.login),
                        label: const Text('Go to Login'),
                      ),
                    ),
                ],
              ),
            );
          }
          if (state is AdmissionLoaded) {
            return _FormContent(state: state, initialStudent: initialStudent);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _FormContent extends StatefulWidget {
  final AdmissionLoaded state;
  final student_domain.Student? initialStudent;
  const _FormContent({required this.state, required this.initialStudent});

  @override
  State<_FormContent> createState() => _FormContentState();
}

class _FormContentState extends State<_FormContent> {
  late int _studentId;
  int? _selectedClassId; // currentClassId to send
  final List<int> _checkedHistory = <int>[]; // checkedClassIds history
  int? _lastCheckedClassId; // last class sent

  String _fmtDate(String s) {
    if (s.isEmpty) return s;
    try {
      final d = DateTime.parse(s);
      final dd = d.day.toString().padLeft(2, '0');
      final mm = d.month.toString().padLeft(2, '0');
      return '$dd/$mm/${d.year}';
    } catch (_) {
      final core = s.length >= 10 ? s.substring(0, 10) : s;
      final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(core);
      if (match != null) {
        final y = match.group(1)!;
        final m = match.group(2)!;
        final d = match.group(3)!;
        return '$d/$m/$y';
      }
      return core;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialStudent != null) {
      _studentId = widget.initialStudent!.id;
      _checkedHistory.addAll(widget.state.checkedClassIds);
    } else {
      _studentId = 0; // force choosing a child first
    }
    // If API returns exactly one class, preselect it
    if (widget.state.term.classes.length == 1) {
      _selectedClassId = widget.state.term.classes.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final term = widget.state.term;
    final latest = widget.state.lastAvailabilityResult;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _termHeader(term),
          const SizedBox(height: 12),
          if (_studentId == 0) ...[
            const Text('Choose a child to start re-checking availability'),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  // Capture messenger before await to avoid context-after-await
                  final messenger = ScaffoldMessenger.of(context);
                  // Navigate to student list; pick one and return it
                  final picked = await Navigator.pushNamed(
                    context,
                    '/student/list',
                    arguments: {'pickMode': true},
                  );
                  if (!mounted) return;
                  // If your student list can't return a selection, we can add a dedicated picker later.
                  if (picked is student_domain.Student) {
                    setState(() {
                      _studentId = picked.id;
                    });
                    // Initial check will be performed after user chooses an active class
                  } else {
                    // Use messenger captured before await
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Please select a child from the list')),
                    );
                  }
                },
                icon: const Icon(Icons.child_care),
                label: const Text('Select Child'),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text('Choose class', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: term.classes.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final c = term.classes[i];
                final selected = _selectedClassId == c.id;
                return ListTile(
                  leading: Icon(
                    selected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: selected ? Theme.of(context).colorScheme.primary : Colors.grey,
                  ),
                  title: Text(c.name),
                  subtitle: Text('${c.academicYear} • ${c.numberOfWeeks} weeks • ${_fmtDate(c.startDate)} • Cost: ${c.cost}'),
                  onTap: () {
                    if (_studentId == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a child first')),
                      );
                      return;
                    }
                    setState(() => _selectedClassId = c.id);
                  },
                );
              },
            ),
          ),
          if (latest != null) ...[
            const Divider(),
            const SizedBox(height: 8),
            Text('Last check result:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            _ResultBox(json: latest),
            const SizedBox(height: 12),
            _ProceedToFormButton(
              term: term,
              selectedStudentId: _studentId,
            ),
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_studentId == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a child first')),
                  );
                  return;
                }
                // Ensure a class is selected
                if (_selectedClassId == null) {
                  // If only one active, auto-select was attempted; otherwise prompt
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please choose an active class')),
                  );
                  return;
                }
                // Build history: add last checked class if switching
                if (_lastCheckedClassId != null && _lastCheckedClassId != _selectedClassId) {
                  if (!_checkedHistory.contains(_lastCheckedClassId)) {
                    _checkedHistory.add(_lastCheckedClassId!);
                  }
                }
                context.read<AdmissionBloc>().add(SelectStudentAndRecheck(
                      studentId: _studentId,
                      currentClassId: _selectedClassId!,
                      checkedClassIds: List<int>.from(_checkedHistory),
                    ));
                _lastCheckedClassId = _selectedClassId;
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Re-check availability'),
            ),
          )
        ],
      ),
    );
  }

  Widget _termHeader(AdmissionTerm term) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Active Admission Term', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Year: ${term.academicYear} | Classes: ${term.numberOfClasses}'),
          Text('From: ${_fmtDate(term.startDate)}  To: ${_fmtDate(term.endDate)}'),
          Text('Registered: ${term.currentRegisteredStudents}/${term.maxNumberRegistration}'),
          Text('Status: ${term.status}'),
        ],
      ),
    );
  }
}

class _ResultBox extends StatelessWidget {
  final Map<String, dynamic> json;
  const _ResultBox({required this.json});
  @override
  Widget build(BuildContext context) {
    final error = json['error']?.toString();
    final status = json['statusResponseCode']?.toString().toLowerCase();
    final message = json['message']?.toString();

    // Prefer concise success message
    String? conciseMessage;
    if (error == null && status == 'ok' && message != null) {
      final msgLc = message.toLowerCase();
      if (msgLc.contains('no schedule') || msgLc.contains('no conflict')) {
        conciseMessage = 'No schedule conflict';
      }
    }

    final isSuccess = conciseMessage != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: error != null
              ? Colors.redAccent
              : isSuccess
                  ? Colors.green
                  : Colors.grey.shade300,
        ),
        color: error != null
            ? Colors.redAccent.withValues(alpha: 0.05)
            : isSuccess
                ? Colors.green.withValues(alpha: 0.05)
                : null,
      ),
      child: error != null
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent),
                const SizedBox(width: 8),
                Expanded(child: Text(error, style: const TextStyle(color: Colors.redAccent))),
              ],
            )
          : isSuccess
              ? Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(conciseMessage, style: const TextStyle(color: Colors.green)),
                  ],
                )
              : Text(message ?? json.toString()),
    );
  }
}

class _ProceedToFormButton extends StatelessWidget {
  final AdmissionTerm term;
  final int selectedStudentId;
  const _ProceedToFormButton({required this.term, required this.selectedStudentId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Continue to Admission Form'),
        onPressed: selectedStudentId == 0
            ? null
            : () {
                final bloc = context.read<AdmissionBloc>();
                final st = bloc.state;
                if (st is! AdmissionLoaded) return;
                // Prefill selectedForForm with currently checked classes from bloc
                final pre = st.checkedClassIds;
                bloc.add(SetSelectedForForm(pre));
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (ctx) => _SelectClassesSheet(term: term),
                );
              },
      ),
    );
  }
}

class _SelectClassesSheet extends StatelessWidget {
  final AdmissionTerm term;
  const _SelectClassesSheet({required this.term});

  @override
  Widget build(BuildContext context) {
    String fmtDateLocal(String s) {
      if (s.isEmpty) return s;
      try {
        final d = DateTime.parse(s);
        final dd = d.day.toString().padLeft(2, '0');
        final mm = d.month.toString().padLeft(2, '0');
        return '$dd/$mm/${d.year}';
      } catch (_) {
        final core = s.length >= 10 ? s.substring(0, 10) : s;
        final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(core);
        if (match != null) {
          final y = match.group(1)!;
          final m = match.group(2)!;
          final d = match.group(3)!;
          return '$d/$m/$y';
        }
        return core;
      }
    }
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (ctx, controller) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.class_rounded),
                  const SizedBox(width: 8),
                  Text('Select classes to include', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BlocBuilder<AdmissionBloc, AdmissionState>(
                  builder: (context, state) {
                    if (state is! AdmissionLoaded) return const SizedBox.shrink();
                    final selected = state.selectedForForm.toSet();
                    return ListView.separated(
                      controller: controller,
                      itemCount: term.classes.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final c = term.classes[i];
                        final checked = selected.contains(c.id);
                        return CheckboxListTile(
                          value: checked,
                          onChanged: (_) => context.read<AdmissionBloc>().add(ToggleSelectedForForm(c.id)),
                          title: Text(c.name),
                          subtitle: Text('${c.academicYear} • ${c.numberOfWeeks} weeks • ${fmtDateLocal(c.startDate)} • Cost: ${c.cost}'),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save_alt),
                  label: const Text('Submit Admission Form'),
                  onPressed: () {
                    final bloc = context.read<AdmissionBloc>();
                    final st = bloc.state;
                    if (st is! AdmissionLoaded) return;
                    if (st.selectedForForm.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select at least one class')),
                      );
                      return;
                    }
                    // Submit without creating an async gap; then close sheet and notify
                    bloc.add(SubmitAdmissionForm());
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(context); // close sheet
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Admission form submitted')),
                    );
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

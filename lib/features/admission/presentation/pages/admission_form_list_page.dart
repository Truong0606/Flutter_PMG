import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/admission_form_item.dart';
import '../bloc/admission_bloc.dart';

class AdmissionFormListPage extends StatelessWidget {
  const AdmissionFormListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Admission Forms')),
      body: BlocBuilder<AdmissionBloc, AdmissionState>(
        builder: (context, state) {
          // We'll fetch in an effect below using Repository directly (simple approach)
          return const _LoaderWrapper();
        },
      ),
    );
  }
}

class _LoaderWrapper extends StatefulWidget {
  const _LoaderWrapper();
  @override
  State<_LoaderWrapper> createState() => _LoaderWrapperState();
}

class _LoaderWrapperState extends State<_LoaderWrapper> {
  late Future<List<AdmissionFormItem>> _future;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<AdmissionBloc>();
    _future = _load(bloc);
  }

  Future<List<AdmissionFormItem>> _load(AdmissionBloc bloc) async {
    // We access repository via bloc to keep DI simple
    return await bloc.repository.listAdmissionForms();
  }

  String _fmtDate(String? s) {
    if (s == null || s.isEmpty) return '-';
    try {
      final d = DateTime.parse(s);
      final dd = d.day.toString().padLeft(2, '0');
      final mm = d.month.toString().padLeft(2, '0');
      return '$dd/$mm/${d.year}';
    } catch (_) {
      return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AdmissionFormItem>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent),
                const SizedBox(height: 8),
                Text('Failed to load forms'),
                Text(snap.error.toString(), textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => setState(() => _future = _load(context.read<AdmissionBloc>())),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                )
              ],
            ),
          );
        }
        final list = snap.data ?? const [];
        if (list.isEmpty) {
          return const Center(child: Text('No admission forms yet'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final it = list[i];
            final status = (it.status.isEmpty ? 'unknown' : it.status).replaceAll('_', ' ');
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade50,
                child: const Icon(Icons.assignment_turned_in, color: Colors.blue),
              ),
              title: Text('Form #${it.id} • $status'),
              subtitle: Text('Term: ${it.admissionTermId} • Classes: ${it.classIds.join(', ')}\nCreated: ${_fmtDate(it.submittedDate ?? it.createdAt)}'),
              isThreeLine: true,
              onTap: () => Navigator.pushNamed(context, '/admission/form/detail', arguments: it),
            );
          },
        );
      },
    );
  }
}

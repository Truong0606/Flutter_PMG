import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../domain/entities/admission_form_item.dart';
import '../bloc/admission_bloc.dart';

class AdmissionFormDetailPage extends StatefulWidget {
  const AdmissionFormDetailPage({super.key});

  @override
  State<AdmissionFormDetailPage> createState() => _AdmissionFormDetailPageState();
}

class _AdmissionFormDetailPageState extends State<AdmissionFormDetailPage> {
  AdmissionFormItem? _item;
  bool _refreshing = false;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_item == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is AdmissionFormItem) {
        _item = args;
      }
    }
  }

  Future<void> _refreshForm() async {
    if (_item == null) return;
    try {
      setState(() => _refreshing = true);
      final bloc = context.read<AdmissionBloc>();
      final list = await bloc.repository.listAdmissionForms();
      final updated = list.where((e) => e.id == _item!.id).cast<AdmissionFormItem?>().firstWhere(
            (e) => e != null,
            orElse: () => _item,
          );
      if (!mounted) return;
      setState(() {
        _item = updated ?? _item;
        _refreshing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _refreshing = false);
    }
  }

  Future<void> _openPayment(BuildContext context, int id) async {
    final repo = context.read<AdmissionBloc>().repository;
    try {
      final urlStr = await repo.getAdmissionPaymentUrl(id);
      // Always use in-app WebView so we can intercept the callback and return to app
      if (!context.mounted) return;
      final result = await Navigator.push(context, MaterialPageRoute(
        builder: (_) => _PaymentWebView(url: urlStr),
      ));
      // After awaiting navigation, re-check mounted before using context
      if (!context.mounted) return;
      if (result is Map && result['message'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'].toString())),
        );
      }
      // Refresh the form to reflect latest status immediately
      await _refreshForm();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final it = _item;

    return Scaffold(
      appBar: AppBar(title: Text(it == null ? 'Admission Form' : 'Form #${it.id}')),
      body: it == null
          ? const Center(child: Text('No data'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_refreshing) const LinearProgressIndicator(minHeight: 2),
                ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.blue.shade50, child: const Icon(Icons.assignment_outlined, color: Colors.blue)),
                  title: Text('Status: ${it.status}'),
                  subtitle: Text('Created: ${_fmtDate(it.createdAt)}\nUpdated: ${_fmtDate(it.updatedAt)}'),
                ),
                const Divider(),
                const SizedBox(height: 8),
                Text('Student', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                _kv('ID', it.studentId.toString()),
                if (it.student != null) ...[
                  _kv('Name', (it.student!['name'] ?? '-').toString()),
                  _kv('Gender', (it.student!['gender'] ?? '-').toString()),
                  _kv('DoB', (it.student!['dateOfBirth'] ?? '-').toString()),
                  _kv('Place of Birth', (it.student!['placeOfBirth'] ?? '-').toString()),
                ],
                const SizedBox(height: 8),
                Text('Term', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                _kv('Term ID', it.admissionTermId.toString()),
                _kv('Start', _fmtDate(it.admissionTermStartDate)),
                _kv('End', _fmtDate(it.admissionTermEndDate)),
                const SizedBox(height: 8),
                Text('Classes', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(it.classIds.isEmpty ? '-' : it.classIds.join(', ')),
                const SizedBox(height: 20),
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.payment),
                    label: const Text('Payment'),
                    onPressed: () => _openPayment(context, it.id),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text(k, style: const TextStyle(fontWeight: FontWeight.w600))),
          const SizedBox(width: 8),
          Expanded(child: Text(v)),
        ],
      ),
    );
  }
}

class _PaymentWebView extends StatefulWidget {
  final String url;
  const _PaymentWebView({required this.url});

  @override
  State<_PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<_PaymentWebView> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _loading = true),
        onPageFinished: (_) => setState(() => _loading = false),
        onNavigationRequest: (request) {
          final uri = Uri.parse(request.url);
          // Detect callback URL (e.g., https://localhost:5001/Home/PaymentCallback?...vnp_*)
          final isPaymentCallback =
              uri.path.toLowerCase().contains('/home/paymentcallback') ||
              uri.queryParameters.keys.any((k) => k.toLowerCase().startsWith('vnp_'));

          if (isPaymentCallback) {
            // Collect vnp_ params only
            final qp = <String, String>{};
            uri.queryParameters.forEach((key, value) {
              if (key.toLowerCase().startsWith('vnp_')) {
                qp[key] = value;
              }
            });

            // Confirm with backend
            _confirmAndClose(qp);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _confirmAndClose(Map<String, String> qp) async {
    try {
      // using State.context; guarded with mounted checks after awaits
      final repo = context.read<AdmissionBloc>().repository;
      final res = await repo.confirmAdmissionPayment(qp);
      final message = (res['message']?.toString() ?? 'Payment result received');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      Navigator.of(context).pop(res);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Confirm payment failed: $e')));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const LinearProgressIndicator(minHeight: 2),
        ],
      ),
    );
  }
}

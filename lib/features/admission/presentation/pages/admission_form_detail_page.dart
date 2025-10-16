import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../domain/entities/admission_form_item.dart';
import '../bloc/admission_bloc.dart';

class AdmissionFormDetailPage extends StatelessWidget {
  const AdmissionFormDetailPage({super.key});

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

  Future<void> _openPayment(BuildContext context, int id) async {
    final repo = context.read<AdmissionBloc>().repository;
    try {
      final urlStr = await repo.getAdmissionPaymentUrl(id);
      final uri = Uri.parse(urlStr);
      // Try default external application; some emulators work better with nonBrowserApplication
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication)
          || await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication)
          || await launchUrl(uri);
      if (!launched) {
        // Fallback to in-app WebView
        if (context.mounted) {
          await Navigator.push(context, MaterialPageRoute(
            builder: (_) => _PaymentWebView(url: urlStr),
          ));
        }
      }
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
    final args = ModalRoute.of(context)?.settings.arguments;
    final it = (args is AdmissionFormItem) ? args : null;

    return Scaffold(
      appBar: AppBar(title: Text(it == null ? 'Admission Form' : 'Form #${it.id}')),
      body: it == null
          ? const Center(child: Text('No data'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
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
      ))
      ..loadRequest(Uri.parse(widget.url));
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

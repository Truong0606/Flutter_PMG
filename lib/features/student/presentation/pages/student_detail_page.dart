import 'package:flutter/material.dart';
import '../../domain/entities/student.dart';

class StudentDetailPage extends StatelessWidget {
  const StudentDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final Student s = (args is Student)
        ? args
        : const Student(id: 0, name: '', gender: '', dateOfBirth: '');

    return Scaffold(
      appBar: AppBar(title: const Text('Child Detail')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: _profileThumb(s.profileImage),
            title: Text(s.name.isEmpty ? '(No name)' : s.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            subtitle: Text('${s.gender} • ${s.dateOfBirth}'),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          _kv('Gender', s.gender),
          _kv('Date of Birth', s.dateOfBirth),
          _kv('Place of Birth', s.placeOfBirth ?? '-'),
          const SizedBox(height: 12),
          _imageSection(context, 'Profile Image', s.profileImage),
          const SizedBox(height: 12),
          _imageSection(context, 'Household Registration', s.householdRegistrationImg),
          const SizedBox(height: 12),
          _imageSection(context, 'Birth Certificate', s.birthCertificateImg),
          _kv('Is Student', s.isStudent?.toString() ?? '-'),
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

  Widget _imageSection(BuildContext context, String label, String? url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (url == null || url.isEmpty)
          const Text('-', style: TextStyle(color: Colors.grey))
        else
          GestureDetector(
            onTap: () => _showImageViewer(context, url),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(url, fit: BoxFit.cover),
              ),
            ),
          )
      ],
    );
  }

  Widget _profileThumb(String? url) {
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(url),
      );
    }
    return const CircleAvatar(child: Icon(Icons.child_care));
  }

  void _showImageViewer(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4,
          child: Image.network(url, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

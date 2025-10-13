import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/config/app_config.dart';
import '../bloc/student_bloc.dart';

class StudentCreatePage extends StatefulWidget {
  const StudentCreatePage({super.key});

  @override
  State<StudentCreatePage> createState() => _StudentCreatePageState();
}

class _StudentCreatePageState extends State<StudentCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController(); // yyyy-MM-dd
  String? _gender;
  final _placeCtrl = TextEditingController();

  // Uploaded image URLs
  String? _profileUrl;
  String? _householdUrl;
  String? _birthCertUrl;
  bool _uploading = false;

  late final CloudinaryService _cloudinary;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dobCtrl.dispose();
    _placeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<StudentBloc>().add(CreateStudent(
      name: _nameCtrl.text.trim(),
      gender: _gender ?? 'Male',
      dateOfBirth: _dobCtrl.text.trim(),
      placeOfBirth: _placeCtrl.text.trim().isEmpty ? null : _placeCtrl.text.trim(),
      profileImage: _profileUrl,
      householdRegistrationImg: _householdUrl,
      birthCertificateImg: _birthCertUrl,
    ));
  }

  @override
  void initState() {
    super.initState();
    _cloudinary = CloudinaryService(
      cloudName: AppConfig.cloudinaryCloudName,
      uploadPreset: AppConfig.cloudinaryUploadPreset,
    );
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final minDob = DateTime(now.year - 5, now.month, now.day);
    final maxDob = DateTime(now.year - 3, now.month, now.day);
    final initial = maxDob.isBefore(now) ? maxDob : minDob;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: minDob,
      lastDate: maxDob,
    );
    if (picked != null) {
      _dobCtrl.text = _fmt(picked);
      setState(() {});
    }
  }

  bool _isDobValid(String? dobStr) {
    if (dobStr == null || dobStr.trim().isEmpty) return false;
    try {
      final dob = DateTime.parse(dobStr);
      final now = DateTime.now();
      final minDob = DateTime(now.year - 5, now.month, now.day);
      final maxDob = DateTime(now.year - 3, now.month, now.day);
      return !dob.isBefore(minDob) && !dob.isAfter(maxDob);
    } catch (_) {
      return false;
    }
  }

  String _fmt(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  Future<void> _uploadToCloudinary({required void Function(String url) onDone}) async {
    if (AppConfig.cloudinaryCloudName.isEmpty || AppConfig.cloudinaryUploadPreset.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cloudinary is not configured')),
      );
      return;
    }
    try {
      setState(() => _uploading = true);
      final picker = ImagePicker();
      final xfile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (xfile == null) return;
      final url = await _cloudinary.uploadImage(File(xfile.path));
      onDone(url);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded')),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Child')),
      body: BlocConsumer<StudentBloc, StudentState>(
        listener: (context, state) {
          if (state is StudentCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Child created successfully')), 
            );
            Navigator.pop(context, true);
          } else if (state is StudentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final loading = state is StudentLoading;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _gender,
                    decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                    ],
                    validator: (v) => (v == null || v.isEmpty) ? 'Gender is required' : null,
                    onChanged: (v) => setState(() => _gender = v),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _dobCtrl,
                    readOnly: true,
                    onTap: _pickDob,
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth (yyyy-MM-dd)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Date of birth is required';
                      if (!_isDobValid(v)) return 'Child must be 3 to 5 years old';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _placeCtrl,
                    decoration: const InputDecoration(labelText: 'Place of Birth (optional)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  const Text('Images', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  _imageRow(
                    label: 'Profile Image',
                    url: _profileUrl,
                    onUpload: _uploading ? null : () => _uploadToCloudinary(onDone: (u) => setState(() => _profileUrl = u)),
                  ),
                  const SizedBox(height: 8),
                  _imageRow(
                    label: 'Household Registration',
                    url: _householdUrl,
                    onUpload: _uploading ? null : () => _uploadToCloudinary(onDone: (u) => setState(() => _householdUrl = u)),
                  ),
                  const SizedBox(height: 8),
                  _imageRow(
                    label: 'Birth Certificate',
                    url: _birthCertUrl,
                    onUpload: _uploading ? null : () => _uploadToCloudinary(onDone: (u) => setState(() => _birthCertUrl = u)),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: loading ? null : _submit,
                      child: loading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Create'),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _imageRow({required String label, required String? url, required VoidCallback? onUpload}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: (url != null && url.isNotEmpty) ? NetworkImage(url) : null,
            child: (url == null || url.isEmpty) ? const Icon(Icons.image_outlined, color: Colors.grey) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  (url == null || url.isEmpty) ? 'Not uploaded' : url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: onUpload,
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text('Upload'),
          )
        ],
      ),
    );
  }
}

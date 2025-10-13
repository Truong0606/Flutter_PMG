import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/student.dart';
import '../bloc/student_bloc.dart';

class StudentListPage extends StatelessWidget {
  const StudentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final bool pickMode = args is Map && (args['pickMode'] == true || args['picker'] == true || args['pick'] == true);
    return Scaffold(
      appBar: AppBar(
        title: Text(pickMode ? 'Select Child' : 'Child Profile'),
      ),
      body: BlocConsumer<StudentBloc, StudentState>(
        listener: (context, state) {
          if (state is StudentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is StudentInitial) {
            context.read<StudentBloc>().add(LoadStudents());
          }
          if (state is StudentLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is StudentLoaded) {
            final students = state.students;
            if (students.isEmpty) {
              return const Center(child: Text('No child profiles yet'));
            }
            return ListView.separated(
              itemCount: students.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) => _StudentTile(
                students[i],
                onTap: () {
                  if (pickMode) {
                    Navigator.pop(context, students[i]);
                  } else {
                    Navigator.pushNamed(
                      context,
                      '/student/detail',
                      arguments: students[i],
                    );
                  }
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: pickMode
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                final created = await Navigator.pushNamed(context, '/student/create');
                if (created == true && context.mounted) {
                  context.read<StudentBloc>().add(LoadStudents());
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('New Child'),
            ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  final Student s;
  final VoidCallback? onTap;
  const _StudentTile(this.s, {this.onTap});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: (s.profileImage != null && s.profileImage!.isNotEmpty)
          ? CircleAvatar(backgroundImage: NetworkImage(s.profileImage!))
          : const CircleAvatar(child: Icon(Icons.child_care)),
      title: Text(s.name.isEmpty ? '(No name)' : s.name),
      subtitle: Text('${s.gender} • ${s.dateOfBirth}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

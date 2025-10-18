import 'package:first_app/core/network/api_client.dart';
import 'package:first_app/core/services/storage_service.dart';
import 'package:first_app/features/teacher/data/repositories/teacher_repository_impl.dart';
import 'package:first_app/features/teacher/presentation/bloc/teacher_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeacherWeeklySchedulePage extends StatefulWidget {
  const TeacherWeeklySchedulePage({super.key});

  @override
  State<TeacherWeeklySchedulePage> createState() => _TeacherWeeklySchedulePageState();
}

class _TeacherWeeklySchedulePageState extends State<TeacherWeeklySchedulePage> {
  String selectedWeek = 'Week - 1';
  final List<String> availableWeeks = [
    'Week - 1', 'Week - 2', 'Week - 3', 'Week - 4', 'Week - 5',
    'Week - 6', 'Week - 7', 'Week - 8', 'Week - 9', 'Week - 10',
  ];
  @override
  void initState() {
    super.initState();
    // Load tuần đầu tiên khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<TeacherBloc>(context)
          .add(LoadWeeklySchedule(selectedWeek));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TeacherBloc(
        TeacherActionRepositoryImpl(ApiClient(StorageService())),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Weekly Schedule', style: TextStyle(color: Color(0xFF2C3E50))),
          backgroundColor: Colors.white,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: DropdownButton<String>(
                value: selectedWeek,
                items: availableWeeks.map((week) {
                  return DropdownMenuItem(
                    value: week,
                    child: Text(week),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedWeek = value;
                    });
                    BlocProvider.of<TeacherBloc>(context)
                        .add(LoadWeeklySchedule(selectedWeek));
                  }
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<TeacherBloc, TeacherState>(
                builder: (context, state) {
                  if (state is TeacherLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is TeacherLoadedWeeklySchedules) {
                    if (state.schedules.isEmpty) {
                      return const Center(child: Text('No schedule available'));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.schedules.length,
                      itemBuilder: (context, index) {
                        final schedule = state.schedules[index];
                        return _buildScheduleCard(schedule);
                      },
                    );
                  }
                  if (state is TeacherError) {
                    return Center(child: Text('Lỗi: ${state.message}'));
                  }
                  return const Center(child: Text('Chọn tuần để xem lịch.'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(schedule) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              schedule.weekName ?? '',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            if (schedule.classes != null)
              Text(schedule.classes!.name, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            if (schedule.activities.isNotEmpty)
              ...schedule.activities.map((activity) => ListTile(
                    title: Text(activity.name),
                    subtitle: Text('${activity.dayOfWeek} - ${activity.date}'),
                  )),
          ],
        ),
      ),
    );
  }
}

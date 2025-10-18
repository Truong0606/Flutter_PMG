import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/teacher_bloc.dart';
import '../widgets/schedule_list_view.dart';

class WeeklyScheduleContent extends StatelessWidget {
  final String selectedWeek;
  final Function(List<dynamic>) onNotificationSetup;
  final Function(List<dynamic>) onCalendarExport;

  const WeeklyScheduleContent({
    super.key,
    required this.selectedWeek,
    required this.onNotificationSetup,
    required this.onCalendarExport,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeacherBloc, TeacherState>(
      builder: (context, state) {
        if (state is TeacherLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (state is TeacherError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading schedule',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<TeacherBloc>().add(
                      LoadWeeklySchedule(selectedWeek),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }
        
        if (state is TeacherLoadedWeeklySchedules) {
          return ScheduleListView(
            schedules: state.schedules,
            onNotificationSetup: onNotificationSetup,
            onCalendarExport: onCalendarExport,
          );
        }
        
        return const Center(
          child: Text(
            'No schedule available',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        );
      },
    );
  }
}
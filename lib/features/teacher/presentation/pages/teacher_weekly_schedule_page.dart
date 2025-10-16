import 'package:first_app/core/network/api_client.dart';
import 'package:first_app/core/services/storage_service.dart';
import 'package:first_app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:first_app/features/authentication/presentation/bloc/auth_event_state.dart';
import 'package:first_app/features/teacher/data/repositories/teacher_repository_impl.dart';
import 'package:first_app/features/teacher/presentation/bloc/teacher_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeacherWeeklySchedulePage extends StatefulWidget {
  const TeacherWeeklySchedulePage({Key? key}) : super(key: key);

  @override
  State<TeacherWeeklySchedulePage> createState() => _TeacherWeeklySchedulePageState();
}

class _TeacherWeeklySchedulePageState extends State<TeacherWeeklySchedulePage> {
  String selectedWeek = 'Week - 1';
  final List<String> availableWeeks = [
    'Week - 1',
    'Week - 2', 
    'Week - 3',
    'Week - 4',
    'Week - 5',
    'Week - 6',
    'Week - 7',
    'Week - 8',
    'Week - 9',
    'Week - 10',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        title: const Text(
          'Weekly Schedule',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2C3E50)),
        actions: [
          // Week selector dropdown
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF3498DB).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedWeek,
                icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                style: const TextStyle(
                  color: Color(0xFF2C3E50),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedWeek = newValue;
                    });
                    // Trigger reload with new week
                    _loadWeeklySchedule();
                  }
                },
                items: availableWeeks.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            return BlocProvider(
              create: (context) => TeacherBloc(
                TeacherActionRepositoryImpl(ApiClient(StorageService())),
              )..add(LoadWeeklyScheduleByTeacher(int.parse(authState.user.id), selectedWeek)),
              child: BlocBuilder<TeacherBloc, TeacherState>(
                builder: (context, state) {
                  if (state is TeacherLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
                      ),
                    );
                  }
                  if (state is TeacherLoadedWeeklySchedules) {
                    if (state.schedules.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No schedule for $selectedWeek',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try selecting a different week',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return _buildWeeklyScheduleView(state.schedules);
                  }
                  if (state is TeacherError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading schedule',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              _loadWeeklySchedule();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3498DB),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  return const Center(
                    child: Text(
                      'Please wait...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return const Center(
            child: Text('Please login to view schedule'),
          );
        },
      ),
    );
  }

  void _loadWeeklySchedule() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<TeacherBloc>().add(
        LoadWeeklyScheduleByTeacher(int.parse(authState.user.id), selectedWeek),
      );
    }
  }

  Widget _buildWeeklyScheduleView(schedules) {
    // Group activities by day of week
    final Map<String, List<dynamic>> activitiesByDay = {};
    
    for (final schedule in schedules) {
      for (final activity in schedule.activities) {
        final day = activity.dayOfWeek ?? 'Unknown';
        if (!activitiesByDay.containsKey(day)) {
          activitiesByDay[day] = [];
        }
        activitiesByDay[day]!.add(activity);
      }
    }

    // Define day order
    final dayOrder = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final orderedDays = dayOrder.where((day) => activitiesByDay.containsKey(day)).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Week header
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    selectedWeek,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Weekly Teaching Schedule',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  if (schedules.isNotEmpty && schedules.first.classes != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      schedules.first.classes!.name,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Daily schedule
          if (orderedDays.isNotEmpty) ...[
            const Text(
              'Daily Schedule',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 16),
            ...orderedDays.map((day) => _buildDayCard(day, activitiesByDay[day]!)),
          ] else ...[
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No activities scheduled',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This week has no scheduled activities',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDayCard(String day, List<dynamic> activities) {
    final dayColors = {
      'Monday': const Color(0xFFE74C3C),
      'Tuesday': const Color(0xFFF39C12),
      'Wednesday': const Color(0xFF27AE60),
      'Thursday': const Color(0xFF3498DB),
      'Friday': const Color(0xFF9B59B6),
      'Saturday': const Color(0xFF34495E),
      'Sunday': const Color(0xFFE67E22),
    };

    final dayColor = dayColors[day] ?? const Color(0xFF3498DB);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: dayColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: dayColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      day.substring(0, 1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: dayColor,
                        ),
                      ),
                      Text(
                        '${activities.length} activities',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Activities list
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: activities.map((activity) => _buildActivityItem(activity, dayColor)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(activity, Color dayColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: dayColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: dayColor.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: dayColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatTime(activity.startTime!)} - ${_formatTime(activity.endTime!)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (activity.date != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(activity.date!),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: dayColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _formatTime(activity.startTime!),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: dayColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatTime(String timeString) {
    try {
      final time = timeString.split(':');
      if (time.length >= 2) {
        return '${time[0]}:${time[1]}';
      }
      return timeString;
    } catch (e) {
      return timeString;
    }
  }
}

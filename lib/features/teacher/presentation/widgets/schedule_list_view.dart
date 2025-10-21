import 'package:flutter/material.dart';
import '../../domain/entities/schedule.dart';

class ScheduleListView extends StatelessWidget {
  final List<Schedule> schedules;
  final Function(List<Schedule>) onNotificationSetup;
  final Function(List<Schedule>) onCalendarExport;
  
  final Map<String, Color> dayColors = {
    'Monday': const Color(0xFF4CAF50),
    'Tuesday': const Color(0xFF2196F3),
    'Wednesday': const Color(0xFFFFC107),
    'Thursday': const Color(0xFFFF9800),
    'Friday': const Color(0xFFE91E63),
    'Saturday': const Color(0xFF9C27B0),
    'Sunday': const Color(0xFF795548),
  };

  ScheduleListView({
    super.key,
    required this.schedules,
    required this.onNotificationSetup,
    required this.onCalendarExport,
  });

  @override
  Widget build(BuildContext context) {
    if (schedules.isEmpty) {
      return const Center(
        child: Text(
          'No schedule available',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        
        // Group activities by day
        final activitiesByDay = <String, List<dynamic>>{};
        for (final activity in schedule.activities) {
          final day = activity.dayOfWeek ?? 'Unknown';
          if (!activitiesByDay.containsKey(day)) {
            activitiesByDay[day] = [];
          }
          activitiesByDay[day]!.add(activity);
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class info header
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.classes?.name ?? 'Unknown Class',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Duration: ${schedule.classes?.startDate ?? 'N/A'} to ${schedule.classes?.endDate ?? 'N/A'}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Activities by day
            ...activitiesByDay.entries.map((entry) {
              final day = entry.key;
              final activities = entry.value;
              
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: dayColors[day]?.withValues(alpha: 0.1) ?? Colors.grey[100],
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.event,
                            color: dayColors[day] ?? Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            day,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: dayColors[day] ?? Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...activities.map((activity) => ListTile(
                      leading: Icon(
                        Icons.access_time,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      title: Text(
                        activity.name ?? 'Untitled Activity',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        '${activity.startTime} - ${activity.endTime}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_none, size: 20),
                            onPressed: () => onNotificationSetup([schedule]),
                            tooltip: 'Set Reminder',
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_today, size: 20),
                            onPressed: () => onCalendarExport([schedule]),
                            tooltip: 'Add to Calendar',
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
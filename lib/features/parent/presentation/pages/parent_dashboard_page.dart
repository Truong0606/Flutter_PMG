import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event_state.dart';

class ParentDashboardPage extends StatelessWidget {
  const ParentDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Parent Dashboard',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isParent = state is AuthAuthenticated && state.user.role.toUpperCase() == 'PARENT';

          if (!isParent) {
            return _AccessDenied();
          }

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF9F9FB), Color(0xFFFFFFFF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 8),
                _DashboardCard(
                  title: 'Child',
                  subtitle: 'Admissions • Attendance • Results',
                  icon: Icons.child_care,
                  accentColor: const Color(0xFFFF6B35),
                  onTap: () => _showChildMenu(context),
                ),
                const SizedBox(height: 16),
                _DashboardCard(
                  title: 'Teacher',
                  subtitle: 'Contact • Schedule • Messages',
                  icon: Icons.school_outlined,
                  accentColor: const Color(0xFF3498DB),
                  onTap: () => _showTeacherMenu(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static void _showChildMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _BottomSheetItem(
              icon: Icons.badge_outlined,
              label: 'Child Profile',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/student/list');
              },
            ),
            _BottomSheetItem(
              icon: Icons.assignment_add,
              label: 'Admission Form',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/admission/form');
              },
            ),
            _BottomSheetItem(
              icon: Icons.event_available_outlined,
              label: 'Attendance',
              onTap: () => _comingSoon(context, 'Attendance'),
            ),
            _BottomSheetItem(
              icon: Icons.grade_outlined,
              label: 'Results',
              onTap: () => _comingSoon(context, 'Results'),
            ),
          ],
        ),
      ),
    );
  }

  static void _showTeacherMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _BottomSheetItem(
              icon: Icons.chat_bubble_outline,
              label: 'Messages',
              onTap: () => _comingSoon(context, 'Messages'),
            ),
            _BottomSheetItem(
              icon: Icons.schedule_outlined,
              label: 'Schedule',
              onTap: () => _comingSoon(context, 'Schedule'),
            ),
            _BottomSheetItem(
              icon: Icons.contact_mail_outlined,
              label: 'Contact Teacher',
              onTap: () => _comingSoon(context, 'Contact Teacher'),
            ),
          ],
        ),
      ),
    );
  }

  static void _comingSoon(BuildContext context, String feature) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon')), 
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap; // whole card action

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left picture area (now also taps the whole card)
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF95A5A6)),
          ],
        ),
      ),
    );
  }
}

class _BottomSheetItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomSheetItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2C3E50)),
      title: Text(label, style: const TextStyle(color: Color(0xFF2C3E50))),
      onTap: onTap,
    );
  }
}

class _AccessDenied extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 48, color: Color(0xFFFF6B35)),
            const SizedBox(height: 16),
            const Text(
              'Access Denied',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
            ),
            const SizedBox(height: 8),
            Text(
              'This page is only available to Parent accounts.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
              ),
              child: const Text('Go Back'),
            )
          ],
        ),
      ),
    );
  }
}

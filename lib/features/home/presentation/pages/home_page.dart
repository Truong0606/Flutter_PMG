import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/hero_section.dart';
import '../widgets/intro_tabs_section.dart';
import '../widgets/user_account_dropdown.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        title: Row(
          children: [
            // MerryStar Logo
            SizedBox(
              width: 24,
              height: 24,
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
            // Use Flexible to allow text to overflow gracefully
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'MerryStar',
                    style: TextStyle(
                      color: Color(0xFF2C3E50),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'KINDERGARTEN',
                      style: TextStyle(
                        color: Color(0xFF3498DB),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Navigation Menu Items (for mobile, we'll show a menu)
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return PopupMenuButton<String>(
                icon: const Icon(
                  Icons.menu,
                  color: Color(0xFF2C3E50),
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'login':
                      Navigator.pushNamed(context, '/login');
                      break;
                    case 'register':
                      Navigator.pushNamed(context, '/register');
                      break;
                    case 'dashboard':
                      Navigator.pushNamed(context, '/teacher-dashboard');
                      break;
                    default:
                      // Handle other menu items
                      break;
                  }
                },
                itemBuilder: (context) {
                  List<PopupMenuEntry<String>> menuItems = [
                    const PopupMenuItem(
                      value: 'introduction',
                      child: Text('INTRODUCTION'),
                    ),
                    const PopupMenuItem(
                      value: 'team',
                      child: Text('TEAM'),
                    ),
                    const PopupMenuItem(
                      value: 'education',
                      child: Text('EDUCATION PROGRAM'),
                    ),
                    const PopupMenuItem(
                      value: 'admissions',
                      child: Text('ADMISSIONS'),
                    ),
                  ];

                  // Add teacher-specific menu items
                  if (state is AuthAuthenticated && state.user.role.toUpperCase() == 'TEACHER') {
                    menuItems.addAll([
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'dashboard',
                        child: Row(
                          children: [
                            Icon(Icons.dashboard, size: 16, color: Color(0xFF3498DB)),
                            SizedBox(width: 8),
                            Text('TEACHER DASHBOARD'),
                          ],
                        ),
                      ),
                    ]);
                  }

                  // Add auth-related menu items for non-authenticated users
                  if (state is! AuthAuthenticated) {
                    menuItems.addAll([
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'login',
                        child: Text('LOGIN'),
                      ),
                      const PopupMenuItem(
                        value: 'register',
                        child: Text('REGISTER'),
                      ),
                    ]);
                  }

                  return menuItems;
                },
              );
            },
          ),
          // Authentication-dependent UI
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                // Show user account dropdown when logged in
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: UserAccountDropdown(user: state.user),
                );
              } else {
                // Show sign in button when not logged in
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      'SIGN IN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
          child: Column(
            children: [
              // Hero Section with blue gradient background
              const HeroSection(),
              // Introduction/About Us tabs section
              const IntroTabsSection(),
            ],
          ),
        ),
    );
  }
}
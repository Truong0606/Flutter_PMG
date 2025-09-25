import 'package:flutter/material.dart';
import '../widgets/hero_section.dart';
import '../widgets/intro_tabs_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        title: Row(
          children: [
            // MerryStar Logo
            Container(
              width: 32,
              height: 32,
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'MerryStar',
              style: TextStyle(
                color: Color(0xFF2C3E50),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'KINDERGARTEN',
              style: TextStyle(
                color: Color(0xFF3498DB),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actions: [
          // Navigation Menu Items (for mobile, we'll show a menu)
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.menu,
              color: Color(0xFF2C3E50),
            ),
            onSelected: (value) {
              // Handle menu selection
            },
            itemBuilder: (context) => [
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
            ],
          ),
          // Sign In Button
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: () {
                // Handle sign in
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
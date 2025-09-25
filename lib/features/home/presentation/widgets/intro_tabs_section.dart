import 'package:flutter/material.dart';
import 'about_us_content.dart';
import 'principal_message_content.dart';
import 'student_profile_content.dart';
import 'facilities_content.dart';
import 'why_choose_content.dart';

class IntroTabsSection extends StatefulWidget {
  const IntroTabsSection({super.key});

  @override
  State<IntroTabsSection> createState() => _IntroTabsSectionState();
}

class _IntroTabsSectionState extends State<IntroTabsSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabTitles = [
    'About us',
    'Principal\'s message',
    'Student profile',
    'Facilities',
    'Why choose MerryStar Kindergarten?',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: const Color(0xFFFF6B35),
                indicatorWeight: 3,
                labelColor: const Color(0xFFFF6B35),
                unselectedLabelColor: Colors.grey[600],
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                tabs: _tabTitles.map((title) {
                  if (title == 'About us') {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }
                  return Tab(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(title),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Tab Content
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: TabBarView(
              controller: _tabController,
              children: [
                AboutUsContent(),
                PrincipalMessageContent(),
                StudentProfileContent(),
                FacilitiesContent(),
                WhyChooseContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
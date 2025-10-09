import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/authentication/presentation/pages/login_page.dart';
import 'features/authentication/presentation/pages/register_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/hr/presentation/pages/hr_webapp_notice_page.dart';
import 'features/teacher/presentation/pages/teacher_dashboard_page.dart';
import 'features/parent/presentation/pages/parent_dashboard_page.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/authentication/presentation/bloc/auth_event_state.dart';
import 'features/authentication/data/repositories/auth_repository_impl.dart';
import 'core/network/api_client.dart';
import 'core/services/storage_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create dependencies manually for now
    final storageService = StorageService();
    final apiClient = ApiClient(storageService);
    final authRepository = AuthRepositoryImpl(apiClient, storageService);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(authRepository)..add(CheckAuthStatus()),
        ),
      ],
      child: MaterialApp(
        title: 'MerryStar Kindergarten',
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.blue,
          fontFamily: 'Roboto',
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/profile': (context) => const ProfilePage(),
          '/hr-webapp-notice': (context) => const HRWebappNoticePage(),
          '/teacher-dashboard': (context) => const TeacherDashboardPage(),
          '/parent-dashboard': (context) => const ParentDashboardPage(),
          '/hr/dashboard': (context) => const HomePage(), // Placeholder
          '/education/dashboard': (context) => const HomePage(), // Placeholder
        },
      ),
    );
  }
}
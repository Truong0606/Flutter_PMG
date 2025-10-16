import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/authentication/presentation/pages/login_page.dart';
import 'features/authentication/presentation/pages/register_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/hr/presentation/pages/hr_webapp_notice_page.dart';
import 'features/teacher/presentation/pages/teacher_dashboard_page.dart';
import 'features/teacher/presentation/pages/teacher_classes_page.dart';
import 'features/teacher/presentation/pages/teacher_schedule_page.dart';
import 'features/teacher/presentation/pages/teacher_weekly_schedule_page.dart';
import 'features/parent/presentation/pages/parent_dashboard_page.dart';
import 'features/authentication/presentation/pages/forgot_password_page.dart';
import 'features/authentication/presentation/pages/reset_password_page.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/authentication/presentation/bloc/auth_event_state.dart';
import 'features/authentication/data/repositories/auth_repository_impl.dart';
import 'core/network/api_client.dart';
import 'core/services/storage_service.dart';
import 'features/student/data/repositories/student_repository_impl.dart';
import 'features/student/presentation/bloc/student_bloc.dart';
import 'features/student/presentation/pages/student_list_page.dart';
import 'features/student/presentation/pages/student_create_page.dart';
import 'features/student/presentation/pages/student_detail_page.dart';
import 'features/student/presentation/pages/student_edit_page.dart';
import 'features/admission/data/repositories/admission_repository_impl.dart';
import 'features/admission/presentation/bloc/admission_bloc.dart';
import 'features/admission/presentation/pages/admission_form_page.dart';
import 'features/student/domain/entities/student.dart' as student_domain;

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
    final studentRepository = StudentRepositoryImpl(apiClient);
  final admissionRepository = AdmissionRepositoryImpl(apiClient);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(authRepository)..add(CheckAuthStatus()),
        ),
        BlocProvider(
          create: (context) => StudentBloc(studentRepository),
        ),
        BlocProvider(
          create: (context) => AdmissionBloc(admissionRepository),
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
          '/forgot-password': (context) => const ForgotPasswordPage(),
          '/reset-password': (context) => const ResetPasswordPage(),
          '/profile': (context) => const ProfilePage(),
          '/hr-webapp-notice': (context) => const HRWebappNoticePage(),
          '/teacher-dashboard': (context) => const TeacherDashboardPage(),
          '/teacher-classes': (context) => const TeacherClassesPage(),
          '/teacher-schedules': (context) => const TeacherSchedulePage(),
          '/teacher-weekly-schedule': (context) => const TeacherWeeklySchedulePage(),
          '/parent-dashboard': (context) => const ParentDashboardPage(),
          '/student/list': (context) => const StudentListPage(),
          '/student/create': (context) => const StudentCreatePage(),
          '/student/detail': (context) => const StudentDetailPage(),
          '/student/edit': (context) => const StudentEditPage(),
          '/hr/dashboard': (context) => const HomePage(), // Placeholder
          '/education/dashboard': (context) => const HomePage(), // Placeholder
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/admission/form') {
            final args = settings.arguments;
            if (args is student_domain.Student) {
              return MaterialPageRoute(builder: (_) => AdmissionFormPage(initialStudent: args));
            }
            // Allow opening without args (choose child inside the page)
            return MaterialPageRoute(builder: (_) => const AdmissionFormPage());
          }
          return null;
        },
      ),
    );
  }
}
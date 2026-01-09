import 'package:complaints/features/auth/presentation/bloc/employee_bloc.dart';
import 'package:complaints/features/auth/presentation/register_employee_page.dart';
import 'package:complaints/features/auth/presentation/login_page.dart';
import 'package:complaints/features/complaints/presentation/bloc/complaint_event.dart';
import 'package:complaints/features/dashboard/presentation/widgets/dashboard_app_bar.dart';
import 'package:complaints/features/users/presentation/pages/users_content.dart';
import 'package:complaints/features/complaints/presentation/pages/all_complaints_page.dart';
import 'package:complaints/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:complaints/shared/pages/profile_page.dart';
import 'package:complaints/shared/widgets/permissions_sidebar_widget.dart';
import 'package:complaints/core/models/permission.dart';
import 'package:complaints/core/services/permissions_service.dart';
import 'package:complaints/features/complaints/presentation/bloc/complaint_bloc.dart';
import 'package:complaints/features/auth/data/repositories/employee_repository_impl.dart';
import 'package:complaints/features/auth/data/sources/employee_remote_data_source.dart';
import 'package:complaints/core/network/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  String _selectedKey = 'dashboard';

  late final Map<String, _SectionConfig> _sections = {
    'dashboard': _SectionConfig(
      title: 'الرئيسية',
      subtitle: 'نظرة عامة على أداء لوحة التحكم',
      builder: () => const DashboardOverviewContent(),
    ),
    'complaints': _SectionConfig(
      title: 'لوحة التحكم',
      subtitle: 'أهلاً بك، تابع آخر تحديثات الشكاوى',
      builder: () => const ComplaintsContent(),
    ),
    'profile': _SectionConfig(
      title: 'الملف الشخصي',
      subtitle: 'يمكنك تعديل بياناتك ومعلوماتك هنا',
      builder: () => const ProfileContent(),
    ),
    'registerEmployee': _SectionConfig(
      title: 'إنشاء حساب موظف',
      subtitle: 'أدخل بيانات الموظف الجديد',
      builder: () => BlocProvider(
        create: (_) => EmployeeBloc(
          EmployeeRepositoryImpl(
            EmployeeRemoteDataSource(DioClient().dio),
          ),
        ),
        child: const RegisterEmployeePage(),
      ),
    ),
    'users': _SectionConfig(
      title: 'معلومات الموظفين والمستخدمين',
      subtitle: 'عرض معلومات جميع الموظفين والمواطنين',
      builder: () => const UsersContent(),
    ),
  };

  void _handleSelection(String key) async {
    final currentUser = await PermissionsService.getCurrentUser();

    if (key != 'logout' && !_sections.containsKey(key)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('هذه الصفحة غير متاحة حالياً'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Check if user has permission to access this section
    if (!_canAccessSection(key, currentUser)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ليس لديك صلاحية للوصول إلى هذه الصفحة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (key == 'logout') {
      await PermissionsService.clearUserData();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
      return;
    }
    
    setState(() {
      _selectedKey = key;
    });
    
    // Trigger dashboard data fetch when dashboard is selected
    if (key == 'dashboard') {
      context.read<ComplaintBloc>().add(const FetchDashboardData());
    }
  }

  bool _canAccessSection(String key, User? user) {
    switch (key) {
      case 'dashboard':
        return PermissionsService.canViewDashboard(user);
      case 'complaints':
        return PermissionsService.canViewComplaints(user);
      case 'profile':
        return user != null;
      case 'registerEmployee':
        return PermissionsService.canRegisterEmployee(user);
      case 'users':
        return PermissionsService.canViewUsers(user);
      case 'logout':
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _sections[_selectedKey]!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Row(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PermissionsSidebar(
              selectedKey: _selectedKey,
              onItemSelected: _handleSelection,
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashboardAppBar(
                      title: config.title,
                      subtitle: config.subtitle,
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: KeyedSubtree(
                          key: ValueKey(_selectedKey),
                          child: config.builder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionConfig {
  final String title;
  final String subtitle;
  final Widget Function() builder;

  const _SectionConfig({
    required this.title,
    required this.subtitle,
    required this.builder,
  });
}

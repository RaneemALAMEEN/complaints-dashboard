import 'package:complaints/features/auth/presentation/register_employee_page.dart';
import 'package:complaints/presentation/pages/all_complaints_page.dart';
import 'package:complaints/presentation/pages/all_users_page.dart';
import 'package:complaints/presentation/pages/dashboard_page.dart';
import 'package:complaints/presentation/pages/notifications_page.dart';
import 'package:complaints/presentation/pages/profile_page.dart';
import 'package:complaints/presentation/pages/reports_page.dart';
import 'package:complaints/presentation/widgets/dashboard_app_bar.dart';
import 'package:complaints/shared/widgets/sidebar_widget.dart';
import 'package:complaints/features/auth/presentation/bloc/employee_bloc.dart';
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
      title: 'لوحة تحكم الموظف',
      subtitle: 'أهلاً بك رنيم، تابعي آخر تحديثات الشكاوى',
      builder: () => const ComplaintsContent(),
    ),
    'reports': _SectionConfig(
      title: 'التقارير والإحصائيات',
      subtitle: 'تتبعي أداء الشكاوى والأقسام المختلفة',
      builder: () => const ReportsContent(),
    ),
    'notifications': _SectionConfig(
      title: 'الإشعارات',
      subtitle: 'جميع التنبيهات الحديثة ستظهر هنا',
      builder: () => const NotificationsContent(),
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

  void _handleSelection(String key) {
    if (key == 'logout') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('سيتم تفعيل تسجيل الخروج لاحقاً')),
      );
      return;
    }
    if (_sections.containsKey(key)) {
      setState(() {
        _selectedKey = key;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _sections[_selectedKey]!;
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FD),
      body: SafeArea(
        child: Row(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SideBar(
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

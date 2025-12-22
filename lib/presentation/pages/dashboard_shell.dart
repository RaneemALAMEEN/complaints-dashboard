import 'package:complaints/presentation/pages/all_complaints_page.dart';
import 'package:complaints/presentation/pages/dashboard_page.dart';
import 'package:complaints/presentation/pages/notifications_page.dart';
import 'package:complaints/presentation/pages/profile_page.dart';
import 'package:complaints/presentation/pages/reports_page.dart';
import 'package:complaints/presentation/widgets/dashboard_app_bar.dart';
import 'package:complaints/shared/widgets/sidebar_widget.dart';
import 'package:flutter/material.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  String _selectedKey = 'complaints';

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

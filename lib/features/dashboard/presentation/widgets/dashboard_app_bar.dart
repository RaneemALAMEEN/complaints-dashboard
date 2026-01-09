import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:complaints/core/theme/theme_provider.dart';
import 'package:complaints/core/services/permissions_service.dart';
import 'package:complaints/core/models/permission.dart';

class DashboardAppBar extends StatelessWidget {
  final String title;
  final String subtitle;

  const DashboardAppBar({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.04),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(subtitle),
              ],
            ),
            const Spacer(),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return IconButton(
                  icon: Icon(
                    themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  ),
                  onPressed: () => themeProvider.toggleTheme(),
                  tooltip: themeProvider.isDarkMode ? 'الوضع النهاري' : 'الوضع الليلي',
                );
              },
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? const Color(0xFF334155) 
                    : const Color(0xFFF6F8FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFF3E68FF),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  FutureBuilder<User?>(
                    future: PermissionsService.getCurrentUser(),
                    builder: (context, snapshot) {
                      final user = snapshot.data;
                      final name = user == null
                          ? 'مستخدم'
                          : '${user.firstName} ${user.lastName}'.trim();

                      return Text(
                        name.isEmpty ? 'مستخدم' : name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

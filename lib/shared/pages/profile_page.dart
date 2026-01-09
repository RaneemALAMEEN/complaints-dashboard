import 'package:complaints/core/models/permission.dart' as auth_models;
import 'package:complaints/core/services/permissions_service.dart';
import 'package:flutter/material.dart';

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  Future<({auth_models.User? user, String? token})> _load() async {
    final user = await PermissionsService.getCurrentUser();
    final token = await PermissionsService.getToken();
    return (user: user, token: token);
  }

  String _role(auth_models.User user) {
    if (user.isAdmin && user.isEmployee) return 'أدمن + موظف';
    if (user.isAdmin) return 'أدمن';
    if (user.isEmployee) return 'موظف';
    return 'مستخدم';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardTheme.color ?? (isDark ? const Color(0xFF0B1220) : Colors.white);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final primaryText = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryText = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    Widget infoRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(label, style: TextStyle(color: secondaryText, fontWeight: FontWeight.w600)),
            ),
            Expanded(
              child: Text(value, style: TextStyle(color: primaryText, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: FutureBuilder<({auth_models.User? user, String? token})>(
        future: _load(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data?.user;
          final token = snapshot.data?.token;
          if (user == null) {
            return Center(
              child: Text(
                'لم يتم العثور على بيانات المستخدم. أعد تسجيل الدخول.',
                style: TextStyle(color: primaryText, fontWeight: FontWeight.w600),
              ),
            );
          }

          final tokenPreview = (token == null || token.isEmpty)
              ? 'غير متوفر'
              : (token.length <= 18
                  ? token
                  : '${token.substring(0, 10)}...${token.substring(token.length - 6)}');

          return SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الملف الشخصي', style: TextStyle(color: primaryText, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  infoRow('الاسم', '${user.firstName} ${user.lastName}'),
                  infoRow('البريد', user.email),
                  infoRow('الدور', _role(user)),
                 // infoRow('Token', tokenPreview),
                  const SizedBox(height: 8),
                  Text('الصلاحيات', style: TextStyle(color: primaryText, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: user.permissions
                        .map(
                          (p) => Chip(
                            label: Text(p.name, style: TextStyle(color: primaryText, fontSize: 12)),
                            backgroundColor: isDark ? const Color(0xFF1F2A44) : const Color(0xFFF1F5FF),
                            side: BorderSide(color: borderColor),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// شريط جانبي ثابت لواجهة الداشبورد مطابق للتصميم المطلوب.
class SideBar extends StatelessWidget {
  final ValueChanged<String>? onItemSelected;
  final String selectedKey;

  const SideBar({
    super.key,
    this.onItemSelected,
    this.selectedKey = 'dashboard',
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: 290,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF6F8FF),
              Color(0xFFFFFFFF),
            ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(44),
            bottomLeft: Radius.circular(44),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 45,
              offset: const Offset(-8, 0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SidebarBrand(),
            const SizedBox(height: 18),
            const _SidebarUserCard(),
            const SizedBox(height: 26),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _SidebarItem(
                    icon: Icons.home_outlined,
                    label: 'الرئيسية',
                    keyValue: 'dashboard',
                    isSelected: selectedKey == 'dashboard',
                    onTap: onItemSelected,
                  ),
                  _SidebarItem(
                    icon: Icons.list_alt_outlined,
                    label: 'قائمة الشكاوى',
                    keyValue: 'complaints',
                    isSelected: selectedKey == 'complaints',
                    onTap: onItemSelected,
                  ),
                  _SidebarItem(
                    icon: Icons.bar_chart_outlined,
                    label: 'التقارير والإحصائيات',
                    keyValue: 'reports',
                    isSelected: selectedKey == 'reports',
                    onTap: onItemSelected,
                  ),
                  _SidebarItem(
                    icon: Icons.notifications_none,
                    label: 'الإشعارات',
                    keyValue: 'notifications',
                    isSelected: selectedKey == 'notifications',
                    onTap: onItemSelected,
                  ),
                  _SidebarItem(
                    icon: Icons.person_outline,
                    label: 'الملف الشخصي',
                    keyValue: 'profile',
                    isSelected: selectedKey == 'profile',
                    onTap: onItemSelected,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SidebarItem(
              icon: Icons.logout,
              label: 'تسجيل الخروج',
              keyValue: 'logout',
              isSelected: false,
              onTap: onItemSelected,
              iconColor: Colors.redAccent,
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarBrand extends StatelessWidget {
  const _SidebarBrand();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF1FF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.change_history, color: Color(0xFF3D56F0)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'صوت الشعب',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 2),
            Text(
              "People's Voice",
              style: TextStyle(color: Colors.black45, fontSize: 12),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.menu_open, color: Color(0xFF3D56F0)),
          onPressed: () {},
        ),
      ],
    );
  }
}

class _SidebarUserCard extends StatelessWidget {
  const _SidebarUserCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFF3E68FF),
                child: Icon(Icons.person, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'رنيم الأمين',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'ranima@gmail.com',
                      style: TextStyle(color: Colors.black45, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    const Icon(Icons.notifications, color: Color(0xFF9DA8D2)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Icon(Icons.verified, size: 18, color: Color(0xFF4E5BA6)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'موظف خدمة المواطنين',
                    style: TextStyle(
                      color: Color(0xFF4E5BA6),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String keyValue;
  final bool isSelected;
  final ValueChanged<String>? onTap;
  final Color? iconColor;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.keyValue,
    required this.isSelected,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = const Color(0xFF3E68FF);
    final baseColor = const Color(0xFF4F5878);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () => onTap?.call(keyValue),
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isSelected
                          ? selectedColor.withOpacity(0.12)
                          : const Color(0xFFE9ECF7))
                      .withOpacity(iconColor != null ? 0.18 : 1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? (isSelected ? selectedColor : baseColor),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color:
                        iconColor ?? (isSelected ? selectedColor : baseColor),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.chevron_left, color: Color(0xFF3E68FF)),
            ],
          ),
        ),
      ),
    );
  }
}

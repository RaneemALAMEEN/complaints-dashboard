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
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [const Color(0xFF1E293B), const Color(0xFF1E293B)]
                : [const Color(0xFFFFFFFF), const Color(0xFFFFFFFF)],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(44),
            bottomLeft: Radius.circular(44),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.06),
              blurRadius: 45,
              offset: const Offset(-8, 0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SidebarBrand(),
          //  const SizedBox(height: 10),
           // const _SidebarUserCard(),
            const SizedBox(height: 16),
            Expanded(
              child: Column(
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
                    icon: Icons.person_outline,
                    label: 'الملف الشخصي',
                    keyValue: 'profile',
                    isSelected: selectedKey == 'profile',
                    onTap: onItemSelected,
                  ),
                  _SidebarItem(
                    icon: Icons.person_add,
                    label: 'إنشاء حساب موظف',
                    keyValue: 'registerEmployee',
                    isSelected: selectedKey == 'registerEmployee',
                    onTap: onItemSelected,
                  ),
                  _SidebarItem(
                    icon: Icons.people_outline,
                    label: 'معلومات الموظفين والمستخدمين',
                    keyValue: 'users',
                    isSelected: selectedKey == 'users',
                    onTap: onItemSelected,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SidebarItem(
              icon: Icons.logout,
              label: 'تسجيل الخروج',
              keyValue: 'logout',
              isSelected: false,
              onTap: onItemSelected,
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
    return Column(
      children: [
        SizedBox(
          width: 130,
          height: 60,
          child: Image.asset(
            'assets/images/logo (1).png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'لوحة التحكم',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white 
                : const Color(0xFF4F5878),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// class _SidebarUserCard extends StatelessWidget {
//   const _SidebarUserCard();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(28),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 24,
//             offset: const Offset(0, 12),
//           ),
//         ],
//       ),
//       // child: Column(
//       //   children: [
//       //     Row(
//       //       children: [
//       //         const CircleAvatar(
//       //           radius: 28,
//       //           backgroundColor: Color(0xFF3E68FF),
//       //           child: Icon(Icons.person, color: Colors.white, size: 28),
//       //         ),
//       //         const SizedBox(width: 12),
//       //         Expanded(
//       //           child: Column(
//       //             crossAxisAlignment: CrossAxisAlignment.start,
//       //             children: const [
//       //               Text(
//       //                 'رنيم الأمين',
//       //                 style: TextStyle(fontWeight: FontWeight.bold),
//       //               ),
//       //               SizedBox(height: 4),
//       //               Text(
//       //                 'ranima@gmail.com',
//       //                 style: TextStyle(color: Colors.black45, fontSize: 12),
//       //               ),
//       //             ],
//       //           ),
//       //         ),
//       //         Container(
//       //           width: 36,
//       //           height: 36,
//       //           decoration: BoxDecoration(
//       //             color: const Color(0xFFF2F4FF),
//       //             borderRadius: BorderRadius.circular(12),
//       //           ),
//       //           child:
//       //               const Icon(Icons.notifications, color: Color(0xFF9DA8D2)),
//       //         ),
//       //       ],
//       //     ),
//       //     const SizedBox(height: 16),
//       //     Container(
//       //       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//       //       decoration: BoxDecoration(
//       //         color: const Color(0xFFEEF2FF),
//       //         borderRadius: BorderRadius.circular(20),
//       //       ),
//       //       child: Row(
//       //         children: const [
//       //           Icon(Icons.verified, size: 18, color: Color(0xFF4E5BA6)),
//       //           SizedBox(width: 8),
//       //           Expanded(
//       //             child: Text(
//       //               'موظف خدمة المواطنين',
//       //               style: TextStyle(
//       //                 color: Color(0xFF4E5BA6),
//       //                 fontSize: 12,
//       //                 fontWeight: FontWeight.w600,
//       //               ),
//       //             ),
//       //           ),
//       //         ],
//       //       ),
//       //     ),
//       //   ],
//       // ),
//     );
//   }
// }

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
    final selectedColor = const Color(0xFF4DA6FF);
    final baseColor = Theme.of(context).brightness == Brightness.dark 
        ? Colors.white 
        : const Color(0xFF4F5878);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => onTap?.call(keyValue),
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected 
                ? (Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white.withOpacity(0.1) 
                    : const Color(0xFFE9ECF7))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white.withOpacity(0.1)
                      : const Color(0xFFE9ECF7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? (isSelected ? selectedColor : baseColor),
                  size: 18,
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
            ],
          ),
        ),
      ),
    );
  }
}

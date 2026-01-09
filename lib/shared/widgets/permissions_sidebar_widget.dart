import 'package:flutter/material.dart';
import 'package:complaints/core/models/permission.dart';
import 'package:complaints/core/services/permissions_service.dart';

class PermissionsSidebar extends StatefulWidget {
  final ValueChanged<String>? onItemSelected;
  final String selectedKey;

  const PermissionsSidebar({
    super.key,
    this.onItemSelected,
    this.selectedKey = 'dashboard',
  });

  @override
  State<PermissionsSidebar> createState() => _PermissionsSidebarState();
}

class _PermissionsSidebarState extends State<PermissionsSidebar> {
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await PermissionsService.getCurrentUser();
    setState(() {
      currentUser = user;
    });
  }

  List<Widget> _buildMenuItems() {
    final items = <Widget>[];

    // Dashboard - always visible for logged in users
    if (PermissionsService.canViewDashboard(currentUser)) {
      items.add(_SidebarItem(
        icon: Icons.home_outlined,
        label: 'الرئيسية',
        keyValue: 'dashboard',
        isSelected: widget.selectedKey == 'dashboard',
        onTap: widget.onItemSelected,
      ));
    }

    // Complaints - for admin or employee
    if (PermissionsService.canViewComplaints(currentUser)) {
      items.add(_SidebarItem(
        icon: Icons.list_alt_outlined,
        label: 'قائمة الشكاوى',
        keyValue: 'complaints',
        isSelected: widget.selectedKey == 'complaints',
        onTap: widget.onItemSelected,
      ));
    }

    // Profile - always visible for logged in users
    if (currentUser != null) {
      items.add(_SidebarItem(
        icon: Icons.person_outline,
        label: 'الملف الشخصي',
        keyValue: 'profile',
        isSelected: widget.selectedKey == 'profile',
        onTap: widget.onItemSelected,
      ));
    }

    // Register Employee - admin only
    if (PermissionsService.canRegisterEmployee(currentUser)) {
      items.add(_SidebarItem(
        icon: Icons.person_add,
        label: 'إنشاء حساب موظف',
        keyValue: 'registerEmployee',
        isSelected: widget.selectedKey == 'registerEmployee',
        onTap: widget.onItemSelected,
      ));
    }

    // Users - admin only
    if (PermissionsService.canViewUsers(currentUser)) {
      items.add(_SidebarItem(
        icon: Icons.people_outline,
        label: 'معلومات الموظفين والمستخدمين',
        keyValue: 'users',
        isSelected: widget.selectedKey == 'users',
        onTap: widget.onItemSelected,
      ));
    }

    return items;
  }

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
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<User?>(
                future: PermissionsService.getCurrentUser(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  currentUser = snapshot.data;
                  final menuItems = _buildMenuItems();
                  
                  return Column(
                    children: menuItems,
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            _SidebarItem(
              icon: Icons.logout,
              label: 'تسجيل الخروج',
              keyValue: 'logout',
              isSelected: false,
              onTap: widget.onItemSelected,
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

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String keyValue;
  final bool isSelected;
  final ValueChanged<String>? onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.keyValue,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF4F5878);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap?.call(keyValue),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                ? (Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.1) : const Color(0xFFE9ECF7))
                : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected 
                    ? const Color(0xFF3E68FF)
                    : baseColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected 
                        ? const Color(0xFF3E68FF)
                        : baseColor,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

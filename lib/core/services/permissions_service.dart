import 'dart:convert';
import 'package:complaints/core/models/permission.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionsService {
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';

  static Future<void> saveUser(User user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save user data as JSON string
    final userJson = {
      'id': user.id,
      'first_name': user.firstName,
      'last_name': user.lastName,
      'email': user.email,
      'permissions': user.permissions.map((p) => {
        'id': p.id,
        'name': p.name,
      }).toList(),
    };
    
    await prefs.setString(_userKey, jsonEncode(userJson));
    await prefs.setString(_tokenKey, token);
  }

  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    
    if (userString != null) {
      try {
        final userMap = jsonDecode(userString) as Map<String, dynamic>;
        return User.fromJson(userMap);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
  }

  static bool canAccessPage(String requiredPermission, User? currentUser) {
    if (currentUser == null) return false;
    return currentUser.hasPermission(requiredPermission);
  }

  // Page access methods
  static bool canViewDashboard(User? user) {
    return user != null;
  }

  static bool canViewComplaints(User? user) {
    return user != null && (
      user.hasPermission(Permission.adminViewAllComplaints) ||
      user.hasPermission(Permission.employeeViewAssignedComplaints)
    );
  }

  static bool canViewUsers(User? user) {
    return user != null && user.hasPermission(Permission.adminRegisterEmployee);
  }

  static bool canRegisterEmployee(User? user) {
    return user != null && user.hasPermission(Permission.adminRegisterEmployee);
  }

  static bool canManagePermissions(User? user) {
    return user != null && user.hasPermission(Permission.adminManagePermissions);
  }

  static bool canManageRoles(User? user) {
    return user != null && user.hasPermission(Permission.adminManageRoles);
  }

  static bool canViewComplaintHistory(User? user) {
    return user != null && user.hasPermission(Permission.viewComplaintHistory);
  }

  static bool isEmployee(User? user) {
    return user != null && (
      user.hasPermission(Permission.employeeViewAssignedComplaints) ||
      user.hasPermission(Permission.employeeUpdateComplaint)
    );
  }

  static bool canUpdateComplaint(User? user) {
    return user != null && user.hasPermission(Permission.employeeUpdateComplaint);
  }
}

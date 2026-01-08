class Permission {
  final int id;
  final String name;

  Permission({
    required this.id,
    required this.name,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['id'],
      name: json['name'],
    );
  }

  // Permission constants
  static const String adminRegisterEmployee = 'admin_register_employee'; // permission_id: 1
  static const String adminViewAllComplaints = 'admin_view_all_complaints'; // permission_id: 10
  static const String adminManagePermissions = 'admin_manage_permissions'; // permission_id: 11
  static const String viewComplaintHistory = 'view_complaint_history'; // permission_id: 12
  static const String adminManageRoles = 'admin_manage_roles'; // permission_id: 13
  
  static const String employeeViewAssignedComplaints = 'employee_view_assigned_complaints'; // permission_id: 8
  static const String employeeUpdateComplaint = 'employee_update_complaint'; // permission_id: 9
}

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final List<Permission> permissions;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.permissions,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    var permissionsList = json['permissions'] as List;
    List<Permission> permissions = permissionsList
        .map((permissionJson) => Permission.fromJson(permissionJson))
        .toList();

    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      permissions: permissions,
    );
  }

  bool hasPermission(String permissionName) {
    return permissions.any((permission) => permission.name == permissionName);
  }

  bool get isAdmin {
    return hasPermission(Permission.adminRegisterEmployee) ||
           hasPermission(Permission.adminViewAllComplaints) ||
           hasPermission(Permission.adminManagePermissions) ||
           hasPermission(Permission.adminManageRoles);
  }

  bool get isEmployee {
    return hasPermission(Permission.employeeViewAssignedComplaints) ||
           hasPermission(Permission.employeeUpdateComplaint);
  }
}

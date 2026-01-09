enum UserType { employee, citizen }

extension UserTypeExtension on UserType {
  String get label {
    switch (this) {
      case UserType.employee: return 'موظف';
      case UserType.citizen: return 'مواطن';
    }
  }
}

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final int phone;
  final UserType type;
  final String? governmentEntity;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.type,
    this.governmentEntity,
  });
  String get fullName => '$firstName $lastName';
}

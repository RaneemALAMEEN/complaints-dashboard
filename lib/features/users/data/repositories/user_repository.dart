import '../../domain/entities/user.dart';

class UserRepository {
  static final List<User> _users = [
    User(
      id: '1',
      name: 'أحمد محمد',
      email: 'ahmed@example.com',
      phone: '0912345678',
      type: UserType.employee,
      region: 'دمشق',
    ),
    User(
      id: '2',
      name: 'فاطمة علي',
      email: 'fatima@example.com',
      phone: '0923456789',
      type: UserType.citizen,
      region: 'حلب',
    ),
    User(
      id: '3',
      name: 'محمد حسن',
      email: 'mohamed@example.com',
      phone: '0934567890',
      type: UserType.employee,
      region: 'حمص',
    ),
    User(
      id: '4',
      name: 'سارة خالد',
      email: 'sara@example.com',
      phone: '0945678901',
      type: UserType.citizen,
      region: 'دمشق',
    ),
    User(
      id: '5',
      name: 'علي أحمد',
      email: 'ali@example.com',
      phone: '0956789012',
      type: UserType.employee,
      region: 'حلب',
    ),
    User(
      id: '6',
      name: 'لينا محمود',
      email: 'lina@example.com',
      phone: '0967890123',
      type: UserType.citizen,
      region: 'حمص',
    ),
    User(
      id: '7',
      name: 'لينا محمود',
      email: 'lina@example.com',
      phone: '0967890123',
      type: UserType.citizen,
      region: 'حمص',
    ),
  ];

  List<User> getUsers() {
    return _users;
  }
}

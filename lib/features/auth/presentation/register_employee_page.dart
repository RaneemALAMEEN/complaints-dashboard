import 'package:complaints/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:complaints/features/auth/presentation/bloc/employee_bloc.dart';
import 'package:complaints/features/auth/presentation/bloc/employee_event.dart';
import 'package:complaints/features/auth/presentation/bloc/employee_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterEmployeePage extends StatefulWidget {
  const RegisterEmployeePage({super.key});

  @override
  State<RegisterEmployeePage> createState() => _RegisterEmployeePageState();
}

class _RegisterEmployeePageState extends State<RegisterEmployeePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _permissionsController = TextEditingController();
  List<int> permissionList = [];
  String? _selectedGovernmentEntity;
  final List<String> _governmentEntities = [
    'كهرباء',
    'ماء',
    'صحة',
    'تعليم',
    'داخلية',
    'مالية',
  ];
  final List<Map<String, dynamic>> _availablePermissions = [
    // Employee Permissions
    {'id': 8 , 'label': 'عرض الشكاوى المسندة للموظف حسب الجهة الخاصة به', 'group': 'موظف'},
    {'id': 9, 'label': 'تعديل حالة الشكوى من قبل الموظف', 'group': 'موظف'},
    // Admin Permissions
    {'id': 1, 'label': 'إنشاء حسابات موظفين', 'group': 'أدمن'},
    {'id': 10, 'label': 'عرض جميع الشكاوى', 'group': 'أدمن'},
    {'id': 11, 'label': 'إدارة الصلاحيات', 'group': 'أدمن'},
    {'id': 12, 'label': 'عرض سجل الشكاوى', 'group': 'أدمن'},
    {'id': 13, 'label': 'عرض جميع الصلاحيات', 'group': 'أدمن'},
  ];

  String _getPermissionLabels(List<int> ids) {
    return ids.map((id) => _availablePermissions.firstWhere((p) => p['id'] == id)['label'] as String).join(', ');
  }

  late String token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    token = (await getToken()) ?? '';
    if (token.isEmpty) {
      // Handle no token
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token not found, please login first')),
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _permissionsController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token not loaded, please wait or login again')),
      );
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      final permissions = permissionList.isNotEmpty
          ? permissionList
          : _permissionsController.text
              .split(',')
              .map((e) => int.tryParse(e.trim()) ?? 0)
              .where((e) => e > 0)
              .toList();
      context.read<EmployeeBloc>().add(
            RegisterEmployeeRequested(
              firstName: _firstNameController.text,
              lastName: _lastNameController.text,
              email: _emailController.text,
              password: _passwordController.text,
              governmentEntity: _selectedGovernmentEntity ?? '',
              phone: _phoneController.text,
              permissionId: permissions,
              token: token,
            ),
          );
    }
  }

  Future<void> _showPermissionPicker() async {
    final selected = Set<int>.from(permissionList);
    final employeePermissions = _availablePermissions.where((p) => p['group'] == 'موظف').toList();
    final adminPermissions = _availablePermissions.where((p) => p['group'] == 'أدمن').toList();
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('اختر الصلاحيات'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('صلاحيات موظف', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                ...employeePermissions.map((p) {
                  final id = p['id'] as int;
                  final label = p['label'] as String;
                  return StatefulBuilder(
                    builder: (context, setStateDialog) {
                      return CheckboxListTile(
                        value: selected.contains(id),
                        title: Text(label),
                        onChanged: (v) {
                          setStateDialog(() {
                            if (v == true) {
                              selected.add(id);
                            } else {
                              selected.remove(id);
                            }
                          });
                        },
                      );
                    },
                  );
                }),
                const SizedBox(height: 16),
                const Text('صلاحيات أدمن', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                ...adminPermissions.map((p) {
                  final id = p['id'] as int;
                  final label = p['label'] as String;
                  return StatefulBuilder(
                    builder: (context, setStateDialog) {
                      return CheckboxListTile(
                        value: selected.contains(id),
                        title: Text(label),
                        onChanged: (v) {
                          setStateDialog(() {
                            if (v == true) {
                              selected.add(id);
                            } else {
                              selected.remove(id);
                            }
                          });
                        },
                      );
                    },
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  permissionList = selected.toList()..sort();
                  _permissionsController.text = _getPermissionLabels(permissionList);
                });
                Navigator.of(context).pop();
              },
              child: const Text('تأكيد'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: BlocConsumer<EmployeeBloc, EmployeeState>(
          listener: (context, state) {
            if (state is EmployeeSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إنشاء الحساب بنجاح')),
              );
            } else if (state is EmployeeFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is EmployeeLoading) {
              return Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/login image.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            return Container(
              decoration: BoxDecoration(
                image: Theme.of(context).brightness == Brightness.dark
                    ? null
                    : const DecorationImage(
                        image: AssetImage('assets/images/login image.png'),
                        fit: BoxFit.cover,
                      ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Card(
                    color: Theme.of(context).cardTheme.color,
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28.0, vertical: 32.0),
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(
                                child: Column(
                                  children: [
                                    // SizedBox(
                                    //   height: 80,
                                    //   child: Image.asset(
                                    //     'assets/images/logo (1).png',
                                    //     fit: BoxFit.contain,
                                    //   ),
                                    // ),
                                    // const SizedBox(height: 8),
                                    // Text(
                                    //   'إنشاء حساب موظف',
                                    //   textAlign: TextAlign.center,
                                    //   style: Theme.of(context)
                                    //       .textTheme
                                    //       .headlineSmall
                                    // ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _firstNameController,
                                      style: TextStyle(
                                        color: Theme.of(context).brightness == Brightness.dark 
                                            ? Colors.white
                                            : const Color(0xFF111D42),
                                      ),
                                      cursorColor: Theme.of(context).brightness == Brightness.dark 
                                          ? Theme.of(context).colorScheme.primary
                                          : const Color(0xFF111D42),
                                      decoration: InputDecoration(
                                        labelText: 'الاسم الأول',
                                        labelStyle: TextStyle(
                                          color: Theme.of(context).brightness == Brightness.dark 
                                              ? const Color(0xFFCBD5E1)
                                              : const Color(0xFFADB9D8),
                                        ),
                                        filled: true,
                                        fillColor: Theme.of(context).brightness == Brightness.dark 
                                            ? const Color(0xFF334155)
                                            : const Color(0xFFF4F7FF),
                                        prefixIcon: Icon(
                                          Icons.person,
                                          color: Theme.of(context).brightness == Brightness.dark 
                                              ? const Color(0xFF94A3B8)
                                              : const Color(0xFFADB9D8),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: Theme.of(context).brightness == Brightness.dark 
                                                ? const Color(0xFF475569)
                                                : const Color(0xFFADB9D8),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: Theme.of(context).brightness == Brightness.dark 
                                                ? Colors.deepPurple
                                                : const Color(0xFFADB9D8),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      validator: (v) => v!.isEmpty ? 'الرجاء إدخال الاسم الأول' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _lastNameController,
                                      style: TextStyle(
                                        color: Theme.of(context).brightness == Brightness.dark 
                                            ? Colors.white
                                            : const Color(0xFF111D42),
                                      ),
                                      cursorColor: Theme.of(context).brightness == Brightness.dark 
                                          ? Theme.of(context).colorScheme.primary
                                          : const Color(0xFF111D42),
                                      decoration: InputDecoration(
                                        labelText: 'اسم العائلة',
                                        labelStyle: TextStyle(
                                          color: Theme.of(context).brightness == Brightness.dark 
                                              ? const Color(0xFFCBD5E1)
                                              : const Color(0xFFADB9D8),
                                        ),
                                        filled: true,
                                        fillColor: Theme.of(context).brightness == Brightness.dark 
                                            ? const Color(0xFF334155)
                                            : const Color(0xFFF4F7FF),
                                        prefixIcon: Icon(
                                          Icons.person,
                                          color: Theme.of(context).brightness == Brightness.dark 
                                              ? const Color(0xFF94A3B8)
                                              : const Color(0xFFADB9D8),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: Theme.of(context).brightness == Brightness.dark 
                                                ? const Color(0xFF475569)
                                                : const Color(0xFFADB9D8),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: Theme.of(context).brightness == Brightness.dark 
                                                ? Colors.deepPurple
                                                : const Color(0xFFADB9D8),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      validator: (v) => v!.isEmpty ? 'الرجاء إدخال اسم العائلة' : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _emailController,
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark 
                                      ? Colors.white
                                      : const Color(0xFF111D42),
                                ),
                                cursorColor: Theme.of(context).brightness == Brightness.dark 
                                    ? Theme.of(context).colorScheme.primary
                                    : const Color(0xFF111D42),
                                decoration: InputDecoration(
                                  labelText: 'البريد الإلكتروني',
                                  labelStyle: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark 
                                        ? const Color(0xFFCBD5E1)
                                        : const Color(0xFFADB9D8),
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(context).brightness == Brightness.dark 
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFF4F7FF),
                                  prefixIcon: Icon(
                                    Icons.email,
                                    color: Theme.of(context).brightness == Brightness.dark 
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFFADB9D8),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).brightness == Brightness.dark 
                                          ? const Color(0xFF475569)
                                          : const Color(0xFFADB9D8),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).brightness == Brightness.dark 
                                          ? Colors.deepPurple
                                          : const Color(0xFFADB9D8),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                validator: (v) => v!.isEmpty ? 'الرجاء إدخال البريد الإلكتروني' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark 
                                      ? Colors.white
                                      : const Color(0xFF111D42),
                                ),
                                cursorColor: Theme.of(context).brightness == Brightness.dark 
                                    ? Theme.of(context).colorScheme.primary
                                    : const Color(0xFF111D42),
                                decoration: InputDecoration(
                                  labelText: 'كلمة المرور',
                                  labelStyle: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark 
                                        ? const Color(0xFFCBD5E1)
                                        : const Color(0xFFADB9D8),
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(context).brightness == Brightness.dark 
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFF4F7FF),
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: Theme.of(context).brightness == Brightness.dark 
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFFADB9D8),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).brightness == Brightness.dark 
                                          ? const Color(0xFF475569)
                                          : const Color(0xFFADB9D8),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).brightness == Brightness.dark 
                                          ? Colors.deepPurple
                                          : const Color(0xFFADB9D8),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                obscureText: true,
                                validator: (v) => v!.isEmpty ? 'الرجاء إدخال كلمة المرور' : null,
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _selectedGovernmentEntity,
                                decoration: InputDecoration(
                                  labelText: 'الجهة الحكومية',
                                  labelStyle: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark 
                                        ? const Color(0xFFCBD5E1)
                                        : const Color(0xFFADB9D8),
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(context).brightness == Brightness.dark 
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFF4F7FF),
                                  prefixIcon: Icon(
                                    Icons.business,
                                    color: Theme.of(context).brightness == Brightness.dark 
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFFADB9D8),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).brightness == Brightness.dark 
                                          ? const Color(0xFF475569)
                                          : const Color(0xFFADB9D8),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).brightness == Brightness.dark 
                                          ? Colors.deepPurple
                                          : const Color(0xFFADB9D8),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                items: _governmentEntities.map((entity) {
                                  return DropdownMenuItem<String>(
                                    value: entity,
                                    child: Text(entity),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedGovernmentEntity = value;
                                  });
                                },
                                validator: (value) => value == null || value.isEmpty
                                    ? 'الرجاء اختيار الجهة الحكومية'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _phoneController,
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark 
                                      ? Colors.white
                                      : const Color(0xFF111D42),
                                ),
                                cursorColor: Theme.of(context).brightness == Brightness.dark 
                                    ? Theme.of(context).colorScheme.primary
                                    : const Color(0xFF111D42),
                                decoration: InputDecoration(
                                  labelText: 'رقم الهاتف',
                                  labelStyle: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark 
                                        ? const Color(0xFFCBD5E1)
                                        : const Color(0xFFADB9D8),
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(context).brightness == Brightness.dark 
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFF4F7FF),
                                  prefixIcon: Icon(
                                    Icons.phone,
                                    color: Theme.of(context).brightness == Brightness.dark 
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFFADB9D8),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).brightness == Brightness.dark 
                                          ? const Color(0xFF475569)
                                          : const Color(0xFFADB9D8),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).brightness == Brightness.dark 
                                          ? Colors.deepPurple
                                          : const Color(0xFFADB9D8),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                validator: (v) => v!.isEmpty ? 'الرجاء إدخال رقم الهاتف' : null,
                              ),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: _showPermissionPicker,
                                child: AbsorbPointer(
                                  child: TextFormField(
                                    controller: _permissionsController,
                                    readOnly: true,
                                    style: TextStyle(
                                      color: Theme.of(context).brightness == Brightness.dark 
                                          ? Colors.white
                                          : const Color(0xFF111D42),
                                    ),
                                    cursorColor: Theme.of(context).brightness == Brightness.dark 
                                        ? Theme.of(context).colorScheme.primary
                                        : const Color(0xFF111D42),
                                    decoration: InputDecoration(
                                      labelText: 'الصلاحيات المختارة',
                                      hintText: 'اضغط لاختيار الصلاحيات',
                                      labelStyle: TextStyle(
                                        color: Theme.of(context).brightness == Brightness.dark 
                                            ? const Color(0xFFCBD5E1)
                                            : const Color(0xFFADB9D8),
                                      ),
                                      hintStyle: TextStyle(
                                        color: Theme.of(context).brightness == Brightness.dark 
                                            ? const Color(0xFF94A3B8)
                                            : const Color(0xFFADB9D8),
                                      ),
                                      filled: true,
                                      fillColor: Theme.of(context).brightness == Brightness.dark 
                                          ? const Color(0xFF334155)
                                          : const Color(0xFFF4F7FF),
                                      prefixIcon: Icon(
                                        Icons.security,
                                        color: Theme.of(context).brightness == Brightness.dark 
                                            ? const Color(0xFF94A3B8)
                                            : const Color(0xFFADB9D8),
                                      ),
                                      suffixIcon: const Icon(Icons.arrow_drop_down),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Theme.of(context).brightness == Brightness.dark 
                                              ? const Color(0xFF475569)
                                              : const Color(0xFFADB9D8),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Theme.of(context).brightness == Brightness.dark 
                                              ? Colors.deepPurple
                                              : const Color(0xFFADB9D8),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    validator: (v) => permissionList.isEmpty ? 'الرجاء اختيار الصلاحيات' : null,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E3A8A),
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    shadowColor: Colors.black.withOpacity(0.15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onPressed: _onRegister,
                                  child: const Text(
                                    'إنشاء الحساب',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

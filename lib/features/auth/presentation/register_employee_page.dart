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
  final _governmentController = TextEditingController();
  final _phoneController = TextEditingController();
  final _permissionsController = TextEditingController();
  List<int> permissionList = [];

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
    _governmentController.dispose();
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
      final permissions = _permissionsController.text
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
              governmentEntity: _governmentController.text,
              phone: _phoneController.text,
              permissionId: permissions,
              token: token,
            ),
          );
    }
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
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/login image.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Card(
                    color: Colors.white,
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.08),
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
                                      style:
                                          const TextStyle(color: Color(0xFF111D42)),
                                      cursorColor: const Color(0xFF111D42),
                                      decoration: InputDecoration(
                                        labelText: 'الاسم الأول',
                                        labelStyle:
                                            const TextStyle(color: Color(0xFFADB9D8)),
                                        filled: true,
                                        fillColor: const Color(0xFFF4F7FF),
                                        prefixIcon: const Icon(
                                          Icons.person,
                                          color: Color(0xFFADB9D8),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFADB9D8),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFADB9D8),
                                            width: 1.5,
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
                                      style:
                                          const TextStyle(color: Color(0xFF111D42)),
                                      cursorColor: const Color(0xFF111D42),
                                      decoration: InputDecoration(
                                        labelText: 'اسم العائلة',
                                        labelStyle:
                                            const TextStyle(color: Color(0xFFADB9D8)),
                                        filled: true,
                                        fillColor: const Color(0xFFF4F7FF),
                                        prefixIcon: const Icon(
                                          Icons.person,
                                          color: Color(0xFFADB9D8),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFADB9D8),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFADB9D8),
                                            width: 1.5,
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
                                style:
                                    const TextStyle(color: Color(0xFF111D42)),
                                cursorColor: const Color(0xFF111D42),
                                decoration: InputDecoration(
                                  labelText: 'البريد الإلكتروني',
                                  labelStyle:
                                      const TextStyle(color: Color(0xFFADB9D8)),
                                  filled: true,
                                  fillColor: const Color(0xFFF4F7FF),
                                  prefixIcon: const Icon(
                                    Icons.email,
                                    color: Color(0xFFADB9D8),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFADB9D8),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFADB9D8),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                validator: (v) => v!.isEmpty ? 'الرجاء إدخال البريد الإلكتروني' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                style:
                                    const TextStyle(color: Color(0xFF111D42)),
                                cursorColor: const Color(0xFF111D42),
                                decoration: InputDecoration(
                                  labelText: 'كلمة المرور',
                                  labelStyle:
                                      const TextStyle(color: Color(0xFFADB9D8)),
                                  filled: true,
                                  fillColor: const Color(0xFFF4F7FF),
                                  prefixIcon: const Icon(
                                    Icons.lock,
                                    color: Color(0xFFADB9D8),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFADB9D8),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFADB9D8),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                obscureText: true,
                                validator: (v) => v!.isEmpty ? 'الرجاء إدخال كلمة المرور' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _governmentController,
                                style:
                                    const TextStyle(color: Color(0xFF111D42)),
                                cursorColor: const Color(0xFF111D42),
                                decoration: InputDecoration(
                                  labelText: 'الجهة الحكومية',
                                  labelStyle:
                                      const TextStyle(color: Color(0xFFADB9D8)),
                                  filled: true,
                                  fillColor: const Color(0xFFF4F7FF),
                                  prefixIcon: const Icon(
                                    Icons.business,
                                    color: Color(0xFFADB9D8),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFADB9D8),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFADB9D8),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                validator: (v) => v!.isEmpty ? 'الرجاء إدخال الجهة الحكومية' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _phoneController,
                                style:
                                    const TextStyle(color: Color(0xFF111D42)),
                                cursorColor: const Color(0xFF111D42),
                                decoration: InputDecoration(
                                  labelText: 'رقم الهاتف',
                                  labelStyle:
                                      const TextStyle(color: Color(0xFFADB9D8)),
                                  filled: true,
                                  fillColor: const Color(0xFFF4F7FF),
                                  prefixIcon: const Icon(
                                    Icons.phone,
                                    color: Color(0xFFADB9D8),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFADB9D8),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFADB9D8),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                validator: (v) => v!.isEmpty ? 'الرجاء إدخال رقم الهاتف' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _permissionsController,
                                style:
                                    const TextStyle(color: Color(0xFF111D42)),
                                cursorColor: const Color(0xFF111D42),
                                decoration: InputDecoration(
                                  labelText: 'معرفات الصلاحيات (مفصولة بفواصل)',
                                  labelStyle:
                                      const TextStyle(color: Color(0xFFADB9D8)),
                                  filled: true,
                                  fillColor: const Color(0xFFF4F7FF),
                                  prefixIcon: const Icon(
                                    Icons.security,
                                    color: Color(0xFFADB9D8),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFADB9D8),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFADB9D8),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                validator: (v) => v!.isEmpty ? 'الرجاء إدخال معرفات الصلاحيات' : null,
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

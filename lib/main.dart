import 'package:complaints/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:complaints/features/auth/presentation/bloc/auth_event.dart';
import 'package:complaints/features/auth/presentation/bloc/auth_state.dart';
import 'package:complaints/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:complaints/features/auth/data/sources/auth_remote_data_source.dart';
import 'package:complaints/presentation/pages/dashboard_shell.dart';
import 'package:complaints/features/auth/presentation/login_page.dart';
import 'package:complaints/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? _isLoggedIn;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final token = await getToken();
    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // إنشاء RemoteDataSource
    final remoteDataSource = AuthRemoteDataSource();
    // إنشاء Repository وتمرير DataSource
    final authRepository = AuthRepositoryImpl(remoteDataSource);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(authRepository),
        ),
      ],
      child: MaterialApp(
        title: 'Complaints',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          fontFamily: 'Cairo',
          useMaterial3: true,
        ),
         //home: _isLoggedIn! ? const DashboardShell() : const LoginPage(),
        home:  const LoginPage(),
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
      ),
    );
  }
}

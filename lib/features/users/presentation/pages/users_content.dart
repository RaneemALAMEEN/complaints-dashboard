import 'dart:io';
import 'package:complaints/features/users/presentation/bloc/user_bloc.dart';
import 'package:complaints/features/users/presentation/bloc/user_bloc.dart' as user_bloc;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import '../../domain/entities/user.dart';
import '../../data/repositories/user_repository.dart';
import '../widgets/users_card_widget.dart';
import '../widgets/search_filter_widget.dart';

class UsersContent extends StatelessWidget {
  const UsersContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserBloc(UserRepository()),
      child: const UsersView(),
    );
  }
}

class UsersView extends StatefulWidget {
  const UsersView({super.key});

  @override
  State<UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends State<UsersView> {
  @override
  void initState() {
    super.initState();
    // Fetch users when the widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<user_bloc.UserBloc>().add(user_bloc.FetchUsers());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<user_bloc.UserBloc, user_bloc.UserState>(
      builder: (context, state) {
        if (state is user_bloc.UserLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is user_bloc.UserError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('خطأ: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<user_bloc.UserBloc>().add(user_bloc.FetchUsers());
                  },
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        } else if (state is user_bloc.UserLoaded) {
          return UsersListContent(users: state.users);
        } else {
          return const Center(child: Text('لا توجد بيانات'));
        }
      },
    );
  }
}

class UsersListContent extends StatefulWidget {
  final List<User> users;

  const UsersListContent({super.key, required this.users});

  @override
  State<UsersListContent> createState() => _UsersListContentState();
}

class _UsersListContentState extends State<UsersListContent> {
  late List<User> _filteredUsers;
  String _searchQuery = '';
  bool _filterEmployee = true;
  bool _filterCitizen = true;
  static const int _pageSize = 4;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _filteredUsers = widget.users;
  }

  int get _totalPages {
    if (_filteredUsers.isEmpty) return 1;
    return (_filteredUsers.length / _pageSize).ceil();
  }

  List<User> get _pagedUsers {
    final totalPages = _totalPages;
    final safePage = _currentPage.clamp(1, totalPages);
    final start = (safePage - 1) * _pageSize;
    if (start >= _filteredUsers.length) return const [];
    final end = (start + _pageSize).clamp(0, _filteredUsers.length);
    return _filteredUsers.sublist(start, end);
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _updateFilters() {
    setState(() {
      _filteredUsers = widget.users.where((user) {
        bool matchesSearch = user.fullName.contains(_searchQuery) ||
            user.email.contains(_searchQuery) ||
            (user.governmentEntity?.contains(_searchQuery) ?? false);
        bool matchesType = (_filterEmployee && user.type == UserType.employee) ||
            (_filterCitizen && user.type == UserType.citizen);
        return matchesSearch && matchesType;
      }).toList();

      _currentPage = 1;
    });
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _updateFilters();
  }

  void _onFilterTap() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Theme.of(context).cardTheme.color,
          surfaceTintColor: Theme.of(context).cardTheme.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? const Color(0xFF475569)
                  : const Color(0xFFE8ECFF), 
              width: 1
            ),
          ),
          title: Text(
            'تصفية المستخدمين',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white
                  : const Color(0xFF1E293B),
              fontWeight: FontWeight.w600,
            ),
          ),
          content: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _filterEmployee = true;
                        _filterCitizen = true;
                      });
                      _updateFilters();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF3E68FF),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    child: const Text('إعادة تعيين'),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? const Color(0xFF334155)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? const Color(0xFF475569)
                          : const Color(0xFFE2E8F0)
                    ),
                  ),
                  child: CheckboxListTile(
                    title: Text(
                      'موظفين',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white
                            : const Color(0xFF1E293B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    value: _filterEmployee,
                    activeColor: const Color(0xFF3E68FF),
                    checkColor: Colors.white,
                    onChanged: (v) => setState(() => _filterEmployee = v ?? true),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? const Color(0xFF334155)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? const Color(0xFF475569)
                          : const Color(0xFFE2E8F0)
                    ),
                  ),
                  child: CheckboxListTile(
                    title: Text(
                      'مواطنين',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white
                            : const Color(0xFF1E293B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    value: _filterCitizen,
                    activeColor: const Color(0xFF3E68FF),
                    checkColor: Colors.white,
                    onChanged: (v) => setState(() => _filterCitizen = v ?? true),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _updateFilters();
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3E68FF),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('تطبيق'),
            ),
          ],
        ),
      ),
    );
  }

  void _onExportTap() {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE8ECFF), width: 1),
          ),
          title: const Text(
            'خيارات التصدير',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: SimpleDialogOption(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    await _exportToExcel(_filteredUsers);
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.table_chart, color: Color(0xFF3E68FF)),
                      SizedBox(width: 12),
                      Text(
                        'تصدير إلى Excel',
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: SimpleDialogOption(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    await _exportToPdf(_filteredUsers);
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.picture_as_pdf, color: Color(0xFF3E68FF)),
                      SizedBox(width: 12),
                      Text(
                        'تصدير إلى PDF',
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportToExcel(List<User> users) async {
    var excel = Excel.createExcel();
    var sheet = excel['Users'];
    sheet.appendRow([
      TextCellValue('الاسم'),
      TextCellValue('البريد الإلكتروني'),
      TextCellValue('رقم الهاتف'),
      TextCellValue('النوع'),
      TextCellValue('الجهة الحكومية'),
    ]);

    for (var user in users) {
      sheet.appendRow([
        TextCellValue(user.fullName),
        TextCellValue(user.email),
        TextCellValue(user.phone.toString()),
        TextCellValue(user.type.label),
        TextCellValue(user.governmentEntity ?? 'غير محدد'),
      ]);
    }

    var fileBytes = excel.save();
    if (fileBytes != null) {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/users.xlsx');
      await file.writeAsBytes(fileBytes);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تصدير الملف بنجاح')),
      );
    }
  }

  Future<void> _exportToPdf(List<User> users) async {
    pw.Font arabicFont;
    try {
      final fontData =
          await rootBundle.load('assets/font/NotoSansArabic-Regular.ttf');
      arabicFont = pw.Font.ttf(fontData);
    } catch (e) {
      arabicFont = pw.Font.helvetica();
    }

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  children: [
                    for (var h in ['الاسم', 'البريد الإلكتروني', 'رقم الهاتف', 'النوع', 'المنطقة'])
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(h,
                            style: pw.TextStyle(
                                font: arabicFont,
                                fontWeight: pw.FontWeight.bold)),
                      )
                  ],
                ),
                ...users.map((user) {
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child:
                              pw.Text(user.fullName, style: pw.TextStyle(font: arabicFont))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child:
                              pw.Text(user.email, style: pw.TextStyle(font: arabicFont))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child:
                              pw.Text(user.phone.toString(), style: pw.TextStyle(font: arabicFont))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child:
                              pw.Text(user.type.label, style: pw.TextStyle(font: arabicFont))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child:
                              pw.Text(user.governmentEntity ?? 'غير محدد', style: pw.TextStyle(font: arabicFont))),
                    ],
                  );
                }),
              ],
            ),
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/users.pdf');
    await file.writeAsBytes(await pdf.save());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تصدير الملف بنجاح')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchFilterWidget(
          onSearchChanged: _onSearchChanged,
          onFilterTap: _onFilterTap,
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Column(
            children: [
             
              Expanded(
                child: UsersCardWidget(
                  users: _pagedUsers,
                  onExportTap: _onExportTap,
                  totalItems: _filteredUsers.length,
                  pageSize: _pageSize,
                  currentPage: _currentPage,
                  onPageChanged: _onPageChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

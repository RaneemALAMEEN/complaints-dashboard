import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import '../../domain/entities/user.dart';
import '../../data/repositories/user_repository.dart';
import '../widgets/users_card_widget.dart';
import '../widgets/search_filter_widget.dart';

class UsersContent extends StatefulWidget {
  const UsersContent({super.key});

  @override
  State<UsersContent> createState() => _UsersContentState();
}

class _UsersContentState extends State<UsersContent> {
  final UserRepository _repository = UserRepository();
  late List<User> _filteredUsers;
  String _searchQuery = '';
  bool _filterEmployee = true;
  bool _filterCitizen = true;

  @override
  void initState() {
    super.initState();
    _filteredUsers = _repository.getUsers();
  }

  void _updateFilters() {
    setState(() {
      _filteredUsers = _repository.getUsers().where((user) {
        bool matchesSearch = user.name.contains(_searchQuery) ||
            user.email.contains(_searchQuery) ||
            user.region.contains(_searchQuery);
        bool matchesType = (_filterEmployee && user.type == UserType.employee) ||
            (_filterCitizen && user.type == UserType.citizen);
        return matchesSearch && matchesType;
      }).toList();
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
      TextCellValue('المنطقة'),
    ]);

    for (var user in users) {
      sheet.appendRow([
        TextCellValue(user.name),
        TextCellValue(user.email),
        TextCellValue(user.phone),
        TextCellValue(user.type.label),
        TextCellValue(user.region),
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
                              pw.Text(user.name, style: pw.TextStyle(font: arabicFont))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child:
                              pw.Text(user.email, style: pw.TextStyle(font: arabicFont))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child:
                              pw.Text(user.phone, style: pw.TextStyle(font: arabicFont))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child:
                              pw.Text(user.type.label, style: pw.TextStyle(font: arabicFont))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child:
                              pw.Text(user.region, style: pw.TextStyle(font: arabicFont))),
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
             
              Expanded(child: UsersCardWidget(users: _filteredUsers,onExportTap: _onExportTap,)),
            ],
          ),
        ),
      ],
    );
  }
}

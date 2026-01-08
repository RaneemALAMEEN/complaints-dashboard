// import 'dart:io';
// import 'package:complaints/presentation/models/user_model.dart';
// import 'package:complaints/presentation/widgets/search_filter_widget.dart';
// import 'package:excel/excel.dart' hide Border;
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:flutter/services.dart' show rootBundle;

// class UsersContent extends StatefulWidget {
//   const UsersContent({super.key});

//   static final List<User> _users = [
//     User(
//       id: '1',
//       name: 'أحمد محمد',
//       email: 'ahmed@example.com',
//       phone: '0912345678',
//       type: UserType.employee,
//       region: 'دمشق',
//     ),
//     User(
//       id: '2',
//       name: 'فاطمة علي',
//       email: 'fatima@example.com',
//       phone: '0923456789',
//       type: UserType.citizen,
//       region: 'حلب',
//     ),
//     // ... باقي المستخدمين
//   ];

//   @override
//   State<UsersContent> createState() => _UsersContentState();
// }

// class _UsersContentState extends State<UsersContent> {
//   List<User> _filteredUsers = UsersContent._users;
//   String _searchQuery = '';
//   bool _filterEmployee = true;
//   bool _filterCitizen = true;

//   void _updateFilters() {
//     setState(() {
//       _filteredUsers = UsersContent._users.where((user) {
//         bool matchesSearch = user.name.contains(_searchQuery) ||
//             user.email.contains(_searchQuery) ||
//             user.region.contains(_searchQuery);
//         bool matchesType = (_filterEmployee && user.type == UserType.employee) ||
//             (_filterCitizen && user.type == UserType.citizen);
//         return matchesSearch && matchesType;
//       }).toList();
//     });
//   }

//   void _onSearchChanged(String query) {
//     _searchQuery = query;
//     _updateFilters();
//   }

//   void _onFilterTap() {
//     showDialog(
//       context: context,
//       builder: (context) => Directionality(
//         textDirection: TextDirection.rtl,
//         child: AlertDialog(
//           title: const Text('تصفية المستخدمين'),
//           content: StatefulBuilder(
//             builder: (context, setState) => Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 CheckboxListTile(
//                   title: const Text('موظفين'),
//                   value: _filterEmployee,
//                   onChanged: (v) => setState(() => _filterEmployee = v ?? true),
//                 ),
//                 CheckboxListTile(
//                   title: const Text('مواطنين'),
//                   value: _filterCitizen,
//                   onChanged: (v) => setState(() => _filterCitizen = v ?? true),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _updateFilters();
//               },
//               child: const Text('تطبيق'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _onExportTap() {
//     showDialog(
//       context: context,
//       builder: (dialogContext) => Directionality(
//         textDirection: TextDirection.rtl,
//         child: SimpleDialog(
//           title: const Text('خيارات التصدير'),
//           children: [
//             SimpleDialogOption(
//               onPressed: () async {
//                 Navigator.pop(dialogContext);
//                 await _exportToExcel(_filteredUsers);
//               },
//               child: const Text('تصدير إلى Excel'),
//             ),
//             SimpleDialogOption(
//               onPressed: () async {
//                 Navigator.pop(dialogContext);
//                 await _exportToPdf(_filteredUsers);
//               },
//               child: const Text('تصدير إلى PDF'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _exportToExcel(List<User> users) async {
//   var excel = Excel.createExcel();
//   var sheet = excel['Users'];

//   // رأس الجدول
//   sheet.appendRow([
//     TextCellValue('الاسم'),
//     TextCellValue('البريد الإلكتروني'),
//     TextCellValue('رقم الهاتف'),
//     TextCellValue('النوع'),
//     TextCellValue('المنطقة'),
//   ]);

//   // بيانات المستخدمين
//   for (var user in users) {
//     sheet.appendRow([
//       TextCellValue(user.name),
//       TextCellValue(user.email),
//       TextCellValue(user.phone),
//       TextCellValue(user.type.label),
//       TextCellValue(user.region),
//     ]);
//   }

//   var fileBytes = excel.save();
//   if (fileBytes != null) {
//     final directory = await getApplicationDocumentsDirectory();
//     final file = File('${directory.path}/users.xlsx');
//     await file.writeAsBytes(fileBytes);
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('تم تصدير الملف بنجاح')),
//     );
//   }
// }


//   Future<void> _exportToPdf(List<User> users) async {
//     pw.Font arabicFont;
//     try {
//       final fontData = await rootBundle.load('assets/font/NotoSansArabic-Regular.ttf');
//       arabicFont = pw.Font.ttf(fontData);
//     } catch (e) {
//       arabicFont = pw.Font.helvetica();
//     }
//     final pdf = pw.Document();
//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         build: (pw.Context context) {
//           return pw.Directionality(
//             textDirection: pw.TextDirection.rtl,
//             child: pw.Table(
//               border: pw.TableBorder.all(),
//               children: [
//                 pw.TableRow(
//                   children: [
//                     for (var h in ['الاسم', 'البريد الإلكتروني', 'رقم الهاتف', 'النوع', 'المنطقة'])
//                       pw.Padding(
//                         padding: const pw.EdgeInsets.all(8),
//                         child: pw.Text(h, style: pw.TextStyle(font: arabicFont, fontWeight: pw.FontWeight.bold)),
//                       )
//                   ],
//                 ),
//                 ...users.map((user) {
//                   return pw.TableRow(
//                     children: [
//                       pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(user.name, style: pw.TextStyle(font: arabicFont))),
//                       pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(user.email, style: pw.TextStyle(font: arabicFont))),
//                       pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(user.phone, style: pw.TextStyle(font: arabicFont))),
//                       pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(user.type.label, style: pw.TextStyle(font: arabicFont))),
//                       pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(user.region, style: pw.TextStyle(font: arabicFont))),
//                     ],
//                   );
//                 }),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//     final directory = await getApplicationDocumentsDirectory();
//     final file = File('${directory.path}/users.pdf');
//     await file.writeAsBytes(await pdf.save());
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('تم تصدير الملف بنجاح')),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SearchFilterWidget(
//           onSearchChanged: _onSearchChanged,
//           onFilterTap: _onFilterTap,
//         ),
//         const SizedBox(height: 24),
//         Expanded(
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.download),
//                     onPressed: _onExportTap,
//                   )
//                 ],
//               ),
//               Expanded(child: _UsersCard(users: _filteredUsers)),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ... باقي كلاس _UsersCard, UserRowWidget, _BodyCell, _HeaderCell مثل ما عندك


// class _UsersCard extends StatelessWidget {
//   final List<User> users;

//   const _UsersCard({required this.users});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(32),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 20,
//             offset: const Offset(0, 12),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'معلومات الموظفين والمستخدمين',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               Text(
//                 '${users.length} مستخدم',
//                 style: const TextStyle(color: Colors.grey),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Container(
//             padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//             decoration: BoxDecoration(
//               color: const Color(0xFFF6F8FF),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Directionality(
//               textDirection: TextDirection.rtl,
//               child: Row(
//                 children: const [
//                   _HeaderCell(label: 'الاسم', flex: 2),
//                   _HeaderCell(label: 'البريد الإلكتروني', flex: 3),
//                   _HeaderCell(label: 'رقم الهاتف', flex: 2),
//                   _HeaderCell(label: 'النوع', flex: 1),
//                   _HeaderCell(label: 'المنطقة', flex: 2),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Expanded(
//             child: ListView.separated(
//               itemCount: users.length,
//               separatorBuilder: (_, __) => const SizedBox(height: 12),
//               itemBuilder: (context, index) {
//                 final user = users[index];
//                 return UserRowWidget(user: user);
//               },
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text('عرض 6 من 50'),
//               Row(
//                 children: List.generate(5, (index) {
//                   final isActive = index == 0;
//                   return Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 4),
//                     width: 32,
//                     height: 32,
//                     decoration: BoxDecoration(
//                       color: isActive ? const Color(0xFF3E68FF) : Colors.white,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: const Color(0xFFE0E5FF)),
//                     ),
//                     alignment: Alignment.center,
//                     child: Text(
//                       '${index + 1}',
//                       style: TextStyle(
//                           color: isActive ? Colors.white : Colors.black54),
//                     ),
//                   );
//                 }),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class UserRowWidget extends StatelessWidget {
//   final User user;

//   const UserRowWidget({super.key, required this.user});

//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//         decoration: BoxDecoration(
//           color: const Color(0xFFFDFEFF),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: const Color(0xFFE8ECFF)),
//         ),
//         child: Row(
//           children: [
//             _BodyCell(text: user.name, flex: 2),
//             _BodyCell(text: user.email, flex: 3),
//             _BodyCell(text: user.phone, flex: 2),
//             Expanded(
//               flex: 1,
//               child: Align(
//                 alignment: Alignment.centerRight,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: user.type == UserType.employee ? Colors.blue.shade100 : Colors.green.shade100,
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(color: user.type == UserType.employee ? Colors.blue.shade200 : Colors.green.shade200),
//                   ),
//                   child: Text(
//                     user.type.label,
//                     style: TextStyle(
//                       color: user.type == UserType.employee ? Colors.blue.shade800 : Colors.green.shade800,
//                       fontWeight: FontWeight.w600,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             _BodyCell(text: user.region, flex: 2),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _BodyCellFixed extends StatelessWidget {
//   final String text;

//   const _BodyCellFixed({required this.text});

//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.centerRight,
//       child: Text(text),
//     );
//   }
// }

// class _BodyCell extends StatelessWidget {
//   final String text;
//   final int flex;

//   const _BodyCell({required this.text, required this.flex});

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       flex: flex,
//       child: Align(
//         alignment: Alignment.centerRight,
//         child: Text(text),
//       ),
//     );
//   }
// }

// class _HeaderCell extends StatelessWidget {
//   final String label;
//   final int flex;

//   const _HeaderCell({required this.label, required this.flex});

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       flex: flex,
//       child: Align(
//         alignment: Alignment.centerRight,
//         child: Text(
//           label,
//           style: const TextStyle(fontWeight: FontWeight.w600),
//         ),
//       ),
//     );
//   }
// }
import 'package:complaints/presentation/models/complaint_model.dart';
import 'package:complaints/presentation/widgets/complaint_row_widget.dart';
import 'package:complaints/presentation/widgets/search_filter_widget.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

class ComplaintsContent extends StatefulWidget {
  const ComplaintsContent({super.key});

  static final List<Complaint> _complaints = [
    Complaint(
      number: '225',
      region: 'دمشق/المرجة',
      description: 'انقطاع متكرر في التيار الكهربائي لمدة ثلاثة أيام متواصلة.',
      status: ComplaintStatus.newOne,
    ),
    Complaint(
      number: '226',
      region: 'دمشق/المرجة',
      description: 'تأخير في تزويد المياه للحي لمدة أسبوع كامل.',
      status: ComplaintStatus.waitingInfo,
    ),
    Complaint(
      number: '227',
      region: 'دمشق/المرجة',
      description: 'طريق مهترئ يسبب أضراراً للسيارات.',
      status: ComplaintStatus.inProgress,
    ),
    Complaint(
      number: '228',
      region: 'دمشق/المرجة',
      description: 'انقطاع في خدمة الإنترنت في المبنى الحكومي.',
      status: ComplaintStatus.newOne,
    ),
    Complaint(
      number: '229',
      region: 'دمشق/المرجة',
      description: 'تجمع للنفايات في شارع رئيسي.',
      status: ComplaintStatus.resolved,
    ),
    Complaint(
      number: '230',
      region: 'دمشق/المرجة',
      description: 'رفض طلب صرف مساعدة طارئة.',
      status: ComplaintStatus.rejected,
    ),
    Complaint(
      number: '230',
      region: 'دمشق/المرجة',
      description: 'رفض طلب صرف مساعدة طارئة.',
      status: ComplaintStatus.rejected,
    ),
  ];

  @override
  State<ComplaintsContent> createState() => _ComplaintsContentState();
}

class _ComplaintsContentState extends State<ComplaintsContent> {
  late List<Complaint> _filteredComplaints = ComplaintsContent._complaints;
  late final List<ComplaintStatus> _statuses =
      ComplaintsContent._complaints.map((c) => c.status).toList();

  String _searchQuery = '';

  Map<ComplaintStatus, bool> _statusFilters = {
    for (var s in ComplaintStatus.values) s: true
  };

  void _handleStatusChanged(int index, ComplaintStatus status) {
    setState(() {
      _statuses[index] = status;
    });
  }

  void _onSearchChanged(String query) {
    _searchQuery = query.toLowerCase();
    _updateFilters();
  }

  void _updateFilters() {
    setState(() {
      _filteredComplaints = ComplaintsContent._complaints.where((c) {
        final matchesText = c.number.toLowerCase().contains(_searchQuery) ||
            c.region.toLowerCase().contains(_searchQuery) ||
            c.description.toLowerCase().contains(_searchQuery) ||
            c.status.style.label.contains(_searchQuery);

        final matchesStatus = _statusFilters[c.status] ?? true;

        return matchesText && matchesStatus;
      }).toList();
    });
  }

  void _onFilterTap() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تصفية الشكاوى حسب الحالة'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: _statusFilters.keys.map((status) {
                  return CheckboxListTile(
                    title: Text(status.style.label),
                    value: _statusFilters[status],
                    onChanged: (v) {
                      setState(() {
                        _statusFilters[status] = v ?? true;
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _updateFilters();
              },
              child: const Text('تطبيق'),
            ),
          ],
        ),
      ),
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
          child: _ComplaintsCard(
            complaints: _filteredComplaints,
            statuses: _statuses,
            onStatusChanged: _handleStatusChanged,
          ),
        ),
      ],
    );
  }
}

class _ComplaintsCard extends StatelessWidget {
  final List<Complaint> complaints;
  final List<ComplaintStatus> statuses;
  final void Function(int index, ComplaintStatus status) onStatusChanged;

  const _ComplaintsCard({
    required this.complaints,
    required this.statuses,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'جميع الشكاوى',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Text('${complaints.length} شكوى',
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () =>
                        _showExportDialog(context, complaints, statuses),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F8FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                children: const [
                  _HeaderCell(label: 'رقم الشكوى', flex: 1),
                  _HeaderCell(label: 'المنطقة/الموقع', flex: 2),
                  _HeaderCell(label: 'وصف المشكلة', flex: 4),
                  _HeaderCell(label: 'حالة الشكوى', flex: 2),
                  _HeaderCell(label: 'الإجراءات', flex: 1, alignEnd: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: complaints.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final complaint = complaints[index];
                return ComplaintRowWidget(
                  complaint: complaint,
                  status: statuses[index],
                  onStatusChanged: (newStatus) =>
                      onStatusChanged(index, newStatus),
                  onView: () => debugPrint('View ${complaint.number}'),
                  onDelete: () => debugPrint('Delete ${complaint.number}'),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('عرض 6 من 50'),
              Row(
                children: List.generate(5, (index) {
                  final isActive = index == 0;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFF3E68FF) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE0E5FF)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                          color: isActive ? Colors.white : Colors.black54),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void _showExportDialog(
    BuildContext parentContext, List<Complaint> complaints, List<ComplaintStatus> statuses) {
  showDialog(
    context: parentContext,
    builder: (dialogContext) => Directionality(
      textDirection: TextDirection.rtl,
      child: SimpleDialog(
        title: const Text('خيارات التصدير'),
        children: [
          SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _exportToExcel(complaints, statuses);
            },
            child: const Text('تصدير إلى Excel'),
          ),
          SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _exportToPdf(complaints, statuses);
            },
            child: const Text('تصدير إلى PDF'),
          ),
        ],
      ),
    ),
  );
}

Future<void> _exportToExcel(List<Complaint> complaints, List<ComplaintStatus> statuses) async {
  var excel = Excel.createExcel();
  var sheet = excel['Complaints'];
  sheet.appendRow([
    TextCellValue('رقم الشكوى'),
    TextCellValue('المنطقة/الموقع'),
    TextCellValue('وصف المشكلة'),
    TextCellValue('حالة الشكوى')
  ]);
  for (int i = 0; i < complaints.length; i++) {
    var complaint = complaints[i];
    var status = statuses[i];
    sheet.appendRow([
      TextCellValue(complaint.number),
      TextCellValue(complaint.region),
      TextCellValue(complaint.description),
      TextCellValue(status.style.label)
    ]);
  }
  var fileBytes = excel.save();
  if (fileBytes != null) {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/complaints.xlsx');
    await file.writeAsBytes(fileBytes);
  }
}

Future<void> _exportToPdf(List<Complaint> complaints, List<ComplaintStatus> statuses) async {
  pw.Font arabicFont;
  try {
    final fontData = await rootBundle.load('assets/font/NotoSansArabic-Regular.ttf');
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
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('رقم الشكوى', style: pw.TextStyle(font: arabicFont, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('المنطقة/الموقع', style: pw.TextStyle(font: arabicFont, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('وصف المشكلة', style: pw.TextStyle(font: arabicFont, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('حالة الشكوى', style: pw.TextStyle(font: arabicFont, fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
              ...complaints.asMap().entries.map((entry) {
                var complaint = entry.value;
                var status = statuses[entry.key];
                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(complaint.number, style: pw.TextStyle(font: arabicFont)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(complaint.region, style: pw.TextStyle(font: arabicFont)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(complaint.description, style: pw.TextStyle(font: arabicFont)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(status.style.label, style: pw.TextStyle(font: arabicFont)),
                    ),
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
  final file = File('${directory.path}/complaints.pdf');
  await file.writeAsBytes(await pdf.save());
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  final bool alignEnd;

  const _HeaderCell(
      {required this.label, required this.flex, this.alignEnd = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: alignEnd ? Alignment.centerLeft : Alignment.centerRight,
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

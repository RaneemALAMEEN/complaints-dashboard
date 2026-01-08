import 'package:complaints/features/complaints/domain/entities/complaint.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class ExportServices {
  static void showExportDialog(BuildContext parentContext, List<Complaint> complaints) {
    showDialog(
      context: parentContext,
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
                    await exportToExcel(parentContext, complaints);
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
                    await exportToPdf(parentContext, complaints);
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

  static Future<void> exportToExcel(BuildContext context, List<Complaint> complaints) async {
    try {
      var excel = Excel.createExcel();
      var sheet = excel['Complaints'];
      sheet.appendRow([
        TextCellValue('رقم الشكوى'),
        TextCellValue('المحافظة'),
        TextCellValue('الموقع'),
        TextCellValue('وصف المشكلة'),
        TextCellValue('حالة الشكوى')
      ]);
      for (var complaint in complaints) {
        sheet.appendRow([
          TextCellValue(complaint.referenceNumber),
          TextCellValue(complaint.governorate),
          TextCellValue(complaint.location),
          TextCellValue(complaint.description),
          TextCellValue(complaint.status.label)
        ]);
      }
      var fileBytes = excel.save();
      if (fileBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/complaints.xlsx');
        await file.writeAsBytes(fileBytes);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تصدير الشكاوى إلى Excel بنجاح'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء التصدير: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  static Future<void> exportToPdf(BuildContext context, List<Complaint> complaints) async {
    try {
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
                        child: pw.Text('المحافظة', style: pw.TextStyle(font: arabicFont, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('الموقع', style: pw.TextStyle(font: arabicFont, fontWeight: pw.FontWeight.bold)),
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
                  ...complaints.map((complaint) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(complaint.referenceNumber, style: pw.TextStyle(font: arabicFont)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(complaint.governorate, style: pw.TextStyle(font: arabicFont)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(complaint.location, style: pw.TextStyle(font: arabicFont)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(complaint.description, style: pw.TextStyle(font: arabicFont)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(complaint.status.label, style: pw.TextStyle(font: arabicFont)),
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

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تصدير الشكاوى إلى PDF بنجاح'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء التصدير: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
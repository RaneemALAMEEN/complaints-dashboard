import 'package:complaints/features/complaints/domain/entities/complaint.dart';
import 'package:complaints/features/complaints/presentation/bloc/complaint_details_bloc.dart';
import 'package:complaints/features/complaints/presentation/bloc/complaint_details_event.dart';
import 'package:complaints/features/complaints/presentation/bloc/complaint_details_state.dart';
import 'package:complaints/core/services/permissions_service.dart';
import 'package:complaints/core/models/permission.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ComplaintDetailsPage extends StatelessWidget {
  final int complaintId;

  const ComplaintDetailsPage({
    super.key,
    required this.complaintId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ComplaintDetailsBloc()..add(FetchComplaintDetails(complaintId)),
      child: const ComplaintDetailsView(),
    );
  }
}

class ComplaintDetailsView extends StatelessWidget {
  const ComplaintDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? Colors.white : const Color(0xFF1E293B);
    final bodyText = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF64748B);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('تفاصيل الشكوى'),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: Theme.of(context).appBarTheme.elevation ?? 0,
          iconTheme: Theme.of(context).appBarTheme.iconTheme,
          titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: BlocBuilder<ComplaintDetailsBloc, ComplaintDetailsState>(
          builder: (context, state) {
            if (state is ComplaintDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ComplaintDetailsFailure) {
              print('Complaint Details Exception: ${state.message}');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'خطأ: ${state.message}',
                      style: TextStyle(color: primaryText),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'يرجى المحاولة مرة أخرى',
                      style: TextStyle(color: bodyText),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ComplaintDetailsBloc>().add(FetchComplaintDetails(state.complaintId));
                      },
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            } else if (state is ComplaintDetailsLoaded) {
              return _ComplaintDetailsContent(complaint: state.complaint);
            } else {
              return const Center(child: Text('لا توجد بيانات'));
            }
          },
        ),
      ),
    );
  }
}

class _ComplaintDetailsContent extends StatelessWidget {
  final Complaint complaint;

  const _ComplaintDetailsContent({required this.complaint});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor;
    final primaryText = isDark ? Colors.white : const Color(0xFF1E293B);
    final bodyText = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0);
    final surfaceAlt = isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'رقم الشكوى: ${complaint.referenceNumber}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                      ),
                    ),
                    _StatusBadgeSelector(
                      complaintId: complaint.id,
                      status: complaint.status,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _DetailRow(
                  label: 'الجهة الحكومية',
                  value: complaint.governmentEntity ?? 'غير محدد',
                ),
                const SizedBox(height: 8),
                _DetailRow(
                  label: 'تاريخ الإنشاء',
                  value: _formatDate(complaint.createdAt),
                ),
                if (complaint.updatedAt != null) ...[
                  const SizedBox(height: 8),
                  _DetailRow(
                    label: 'تاريخ آخر تحديث',
                    value: _formatDate(complaint.updatedAt!),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Location Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الموقع والعنوان',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryText,
                  ),
                ),
                const SizedBox(height: 16),
                _DetailRow(
                  label: 'المحافظة',
                  value: complaint.governorate,
                ),
                const SizedBox(height: 8),
                _DetailRow(
                  label: 'العنوان التفصيلي',
                  value: complaint.location,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Description Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'وصف المشكلة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryText,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  complaint.description,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: bodyText,
                  ),
                ),
              ],
            ),
          ),

          // Images Section
          if (complaint.images != null && complaint.images!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الصور المرفقة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: complaint.images!.length,
                    itemBuilder: (context, index) {
                      final imageUrl = complaint.images![index];
                      // Use the image URL directly as it comes from the backend
                      return GestureDetector(
                        onTap: () => _showImageDialog(context, imageUrl, index),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: 'http://localhost/$imageUrl',
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: surfaceAlt,
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF94A3B8),
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],

          // Attachments Section
          if (complaint.attachments != null && complaint.attachments!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المرفقات',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...complaint.attachments!.map((attachment) {
                    // Use attachment URL directly as it comes from the backend
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: surfaceAlt,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.attach_file,
                            color: bodyText,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              attachment.split('/').last,
                              style: TextStyle(
                                color: primaryText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _openAttachment('http://localhost/$attachment'),
                            icon: const Icon(
                              Icons.download,
                              color: Color(0xFF3B82F6),
                            ),
                            tooltip: 'تحميل المرفق',
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceAlt = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final iconColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF94A3B8);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: 'http://localhost/$imageUrl',
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: surfaceAlt,
                    child: Icon(
                      Icons.image_not_supported,
                      color: iconColor,
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'صورة ${index + 1} من ${complaint.images!.length}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAttachment(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);
    final valueColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: valueColor),
          ),
        ),
      ],
    );
  }
}

class _StatusBadgeSelector extends StatelessWidget {
  final int complaintId;
  final ComplaintStatus status;

  const _StatusBadgeSelector({
    required this.complaintId,
    required this.status,
  });

  Future<String?> _askForNotes(BuildContext context) async {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showDialog<String>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Theme.of(context).cardTheme.color,
          surfaceTintColor: Theme.of(context).cardTheme.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? const Color(0xFF475569) : const Color(0xFFE8ECFF),
              width: 1,
            ),
          ),
          title: Text(
            'معلومات إضافية مطلوبة',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontWeight: FontWeight.w600,
            ),
          ),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'اكتب المعلومات الإضافية المطلوبة من مقدم الشكوى...',
              filled: true,
              fillColor: isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF3E68FF)),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E68FF),
                foregroundColor: Colors.white,
              ),
              child: const Text('إرسال'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSelected(BuildContext context, ComplaintStatus selected) async {
    if (selected == ComplaintStatus.waitingInfo) {
      final notes = (await _askForNotes(context))?.trim() ?? '';
      if (!context.mounted) return;

      if (notes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('الرجاء إدخال المعلومات الإضافية أولاً'),
            backgroundColor: Colors.red.shade600,
          ),
        );
        return;
      }

      context.read<ComplaintDetailsBloc>().add(
            UpdateComplaintDetailsStatus(
              complaintId,
              selected.label,
              notes: notes,
            ),
          );
      return;
    }

    context.read<ComplaintDetailsBloc>().add(
          UpdateComplaintDetailsStatus(
            complaintId,
            selected.label,
            notes: '',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: PermissionsService.getCurrentUser(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final canUpdate = user != null && (PermissionsService.canUpdateComplaint(user) || user.isAdmin);

        if (!canUpdate) {
          return _StatusBadge(status: status);
        }

        final style = status.style;
        return PopupMenuButton<ComplaintStatus>(
          tooltip: 'تغيير حالة الشكوى',
          position: PopupMenuPosition.over,
          onSelected: (s) => _onSelected(context, s),
          itemBuilder: (context) => ComplaintStatus.values
              .map(
                (s) => PopupMenuItem(
                  value: s,
                  child: Row(
                    children: [
                      Icon(s.style.icon, color: s.style.color, size: 18),
                      const SizedBox(width: 8),
                      Text(s.style.label),
                    ],
                  ),
                ),
              )
              .toList(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: style.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: style.color.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(style.icon, size: 16, color: style.color),
                const SizedBox(width: 6),
                Text(
                  style.label,
                  style: TextStyle(
                    color: style.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFCBD5E1) : Colors.black45,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ComplaintStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: status.style.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status.style.color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.style.icon, size: 16, color: status.style.color),
          const SizedBox(width: 6),
          Text(
            status.style.label,
            style: TextStyle(
              color: status.style.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:complaints/features/complaints/domain/entities/complaint.dart';
import 'package:complaints/features/complaints/presentation/bloc/complaint_details_bloc.dart';
import 'package:complaints/features/complaints/presentation/bloc/complaint_details_event.dart';
import 'package:complaints/features/complaints/presentation/bloc/complaint_details_state.dart';
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F6FD),
        appBar: AppBar(
          title: const Text('تفاصيل الشكوى'),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          titleTextStyle: const TextStyle(
            color: Colors.black,
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
                    Text('خطأ: ${state.message}'),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    _StatusBadge(status: complaint.status),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'الموقع والعنوان',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'وصف المشكلة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  complaint.description,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: Color(0xFF64748B),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الصور المرفقة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
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
                      // Remove 'public/' from the beginning if it exists
                      final cleanImageUrl = imageUrl.startsWith('public/') 
                          ? imageUrl.substring(7) // Remove 'public/' (7 characters)
                          : imageUrl;
                      
                      return GestureDetector(
                        onTap: () => _showImageDialog(context, cleanImageUrl, index),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: 'http://localhost/$cleanImageUrl',
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: const Color(0xFFF1F5F9),
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Color(0xFF94A3B8),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'المرفقات',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...complaint.attachments!.map((attachment) {
                    // Remove 'public/' from the beginning if it exists
                    final cleanAttachment = attachment.startsWith('public/') 
                        ? attachment.substring(7) // Remove 'public/' (7 characters)
                        : attachment;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.attach_file,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              cleanAttachment.split('/').last,
                              style: const TextStyle(
                                color: Color(0xFF1E293B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _openAttachment('http://localhost/$cleanAttachment'),
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
                    color: const Color(0xFFF1F5F9),
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Color(0xFF94A3B8),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1E293B),
            ),
          ),
        ),
      ],
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
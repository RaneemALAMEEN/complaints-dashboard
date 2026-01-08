import 'package:complaints/features/complaints/domain/entities/complaint.dart';
import 'package:complaints/features/complaints/presentation/bloc/complaint_state.dart';
import 'package:complaints/features/complaints/presentation/widgets/complaint_row_widget.dart';
import 'package:complaints/features/complaints/presentation/services/export_services.dart';
import 'package:flutter/material.dart';

class ComplaintsCardWidget extends StatelessWidget {
  final List<Complaint> complaints;
  final Pagination? pagination;
  final void Function(Complaint) onView;
  final void Function(Complaint) onDelete;
  final void Function(Complaint, ComplaintStatus) onStatusChanged;
  final void Function(int) onPageChanged;

  const ComplaintsCardWidget({
    required this.complaints,
    this.pagination,
    required this.onView,
    required this.onDelete,
    required this.onStatusChanged,
    required this.onPageChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05),
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
              Text(
                'جميع الشكاوى',
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white
                      : const Color(0xFF111827),
                ),
              ),
              Row(
                children: [
                  Text('${complaints.length} شكوى',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? const Color(0xFF94A3B8)
                            : Colors.grey,
                      )),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () => ExportServices.showExportDialog(context, complaints),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? const Color(0xFF334155)
                  : const Color(0xFFF6F8FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'رقم الشكوى',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'الجهة',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'المنطقة والموقع',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'وصف المشكلة',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'حالة الشكوى',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'الإجراءات',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: complaints.length,
              separatorBuilder: (_, __) => const SizedBox(height: 0),
              itemBuilder: (context, index) {
                final complaint = complaints[index];
                return ComplaintRowWidget(
                  complaint: complaint,
                  onStatusChanged: (status) => onStatusChanged(complaint, status),
                  onView: () => onView(complaint),
                  onDelete: () => onDelete(complaint),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          if (pagination != null) _buildPaginationControls(context),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(BuildContext context) {
    if (pagination == null) return const SizedBox.shrink();
    
    final currentPage = pagination!.page;
    final totalPages = pagination!.totalPages;
    final total = pagination!.total;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'عرض ${complaints.length} من $total شكوى',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white70
                : Colors.black54,
            fontSize: 14,
          ),
        ),
        Row(
          children: [
            // Previous button
            IconButton(
              onPressed: currentPage > 1 
                  ? () => onPageChanged(currentPage - 1)
                  : null,
              icon: const Icon(Icons.chevron_right),
              iconSize: 20,
            ),
            
            // Page numbers
            ...List.generate(totalPages > 5 ? 5 : totalPages, (index) {
              int pageNumber;
              if (totalPages <= 5) {
                pageNumber = index + 1;
              } else if (currentPage <= 3) {
                pageNumber = index + 1;
              } else if (currentPage >= totalPages - 2) {
                pageNumber = totalPages - 4 + index;
              } else {
                pageNumber = currentPage - 2 + index;
              }
              
              final isActive = pageNumber == currentPage;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF3E68FF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive ? const Color(0xFF3E68FF) : const Color(0xFFE0E5FF),
                  ),
                ),
                alignment: Alignment.center,
                child: InkWell(
                  onTap: () => onPageChanged(pageNumber),
                  child: Text(
                    '$pageNumber',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.black54,
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }),
            
            // Next button
            IconButton(
              onPressed: currentPage < totalPages 
                  ? () => onPageChanged(currentPage + 1)
                  : null,
              icon: const Icon(Icons.chevron_left),
              iconSize: 20,
            ),
          ],
        ),
      ],
    );
  }
}

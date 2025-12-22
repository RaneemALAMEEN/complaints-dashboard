import 'package:complaints/presentation/models/complaint_model.dart';
import 'package:complaints/presentation/widgets/complaint_row_widget.dart';
import 'package:complaints/presentation/widgets/search_filter_widget.dart';
import 'package:flutter/material.dart';

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
  ];

  @override
  State<ComplaintsContent> createState() => _ComplaintsContentState();
}

class _ComplaintsContentState extends State<ComplaintsContent> {
  late final List<ComplaintStatus> _statuses =
      ComplaintsContent._complaints.map((c) => c.status).toList();

  void _handleStatusChanged(int index, ComplaintStatus status) {
    setState(() {
      _statuses[index] = status;
    });
    debugPrint(
        'Complaint ${ComplaintsContent._complaints[index].number} -> $status');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SearchFilterWidget(),
        const SizedBox(height: 24),
        Expanded(
          child: _ComplaintsCard(
            complaints: ComplaintsContent._complaints,
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
            children: const [
              Text(
                'جميع الشكاوى',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                '225 شكوى',
                style: TextStyle(color: Colors.grey),
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
                  _HeaderCell(label: 'الإجراءات', flex: 2, alignEnd: true),
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

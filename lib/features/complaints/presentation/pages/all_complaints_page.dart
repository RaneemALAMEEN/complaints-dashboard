import 'package:complaints/features/complaints/domain/entities/complaint.dart';
import 'package:complaints/features/complaints/presentation/bloc/complaint_bloc.dart';
import 'package:complaints/features/complaints/presentation/bloc/complaint_event.dart';
import 'package:complaints/features/complaints/presentation/bloc/complaint_state.dart';
import 'package:complaints/features/complaints/presentation/widgets/complaints_card_widget.dart';
import 'package:complaints/features/complaints/presentation/pages/complaint_details_page.dart';
import 'package:complaints/features/users/presentation/widgets/search_filter_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ComplaintsContent extends StatefulWidget {
  const ComplaintsContent({super.key});

  @override
  State<ComplaintsContent> createState() => _ComplaintsContentState();
}

class _ComplaintsContentState extends State<ComplaintsContent> {
  late List<Complaint> _filteredComplaints = [];
  String _searchQuery = '';
  Map<ComplaintStatus, bool> _statusFilters = {
    for (var s in ComplaintStatus.values) s: true
  };
  static const List<String> _governmentEntities = [
    'كهرباء',
    'ماء',
    'صحة',
    'تعليم',
    'داخلية',
    'مالية',
  ];
  late Map<String, bool> _entityFilters = {
    for (final e in _governmentEntities) e: true,
  };
  int _currentPage = 1;

  Future<void> _confirmAndDelete(Complaint complaint) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Theme.of(context).cardTheme.color,
          surfaceTintColor: Theme.of(context).cardTheme.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد أنك تريد حذف الشكوى رقم ${complaint.referenceNumber}؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && mounted) {
      context.read<ComplaintBloc>().add(DeleteComplaint(complaint.id, page: _currentPage));
    }
  }

  Future<void> _onStatusChanged(Complaint complaint, ComplaintStatus status) async {
    if (status == ComplaintStatus.waitingInfo) {
      final controller = TextEditingController();
      final isDark = Theme.of(context).brightness == Brightness.dark;

      final result = await showDialog<String>(
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

      final notes = result?.trim() ?? '';
      if (!mounted) return;
      if (notes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('الرجاء إدخال المعلومات الإضافية أولاً'),
            backgroundColor: Colors.red.shade600,
          ),
        );
        return;
      }

      context.read<ComplaintBloc>().add(
            UpdateComplaintStatus(
              complaint.id,
              status.label,
              notes: notes,
            ),
          );
      return;
    }

    context.read<ComplaintBloc>().add(UpdateComplaintStatus(complaint.id, status.label, notes: ''));
  }

  @override
  void initState() {
    super.initState();
    context.read<ComplaintBloc>().add(FetchAllComplaints(_currentPage));
  }

  void _updateFilters(List<Complaint> complaints) {
    setState(() {
      _filteredComplaints = complaints.where((c) {
        final matchesText = c.referenceNumber.contains(_searchQuery) ||
            c.governorate.contains(_searchQuery) ||
            c.description.contains(_searchQuery) ||
            c.governmentEntity.contains(_searchQuery) ||
            c.status.label.contains(_searchQuery);
        final matchesStatus = _statusFilters[c.status] ?? true;
        final matchesEntity = _entityFilters[c.governmentEntity] ?? true;
        return matchesText && matchesStatus && matchesEntity;
      }).toList();
    });
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    context.read<ComplaintBloc>().add(FetchAllComplaints(page));
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    final state = context.read<ComplaintBloc>().state;
    if (state is ComplaintsLoaded) {
      _updateFilters(state.complaints);
    }
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
            'تصفية الشكاوى',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white
                  : const Color(0xFF1E293B),
              fontWeight: FontWeight.w600,
            ),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              final tileColor = Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF334155)
                  : const Color(0xFFF8FAFC);
              final borderColor = Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF475569)
                  : const Color(0xFFE2E8F0);
              final textColor = Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : const Color(0xFF1E293B);

              return SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              for (final s in ComplaintStatus.values) {
                                _statusFilters[s] = true;
                              }
                              for (final e in _governmentEntities) {
                                _entityFilters[e] = true;
                              }
                            });

                            final blocState = context.read<ComplaintBloc>().state;
                            if (blocState is ComplaintsLoaded) {
                              _updateFilters(blocState.complaints);
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF3E68FF),
                            textStyle: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          child: const Text('إعادة تعيين'),
                        ),
                      ),
                      Text(
                        'حسب الحالة',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._statusFilters.keys.map((status) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: tileColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor),
                          ),
                          child: CheckboxListTile(
                            title: Text(
                              status.label,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            value: _statusFilters[status],
                            activeColor: const Color(0xFF3E68FF),
                            checkColor: Colors.white,
                            onChanged: (v) {
                              setState(() {
                                _statusFilters[status] = v ?? true;
                              });
                            },
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      Text(
                        'حسب الجهة',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._governmentEntities.map((entity) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: tileColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor),
                          ),
                          child: CheckboxListTile(
                            title: Text(
                              entity,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            value: _entityFilters[entity] ?? true,
                            activeColor: const Color(0xFF3E68FF),
                            checkColor: Colors.white,
                            onChanged: (v) {
                              setState(() {
                                _entityFilters[entity] = v ?? true;
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                final state = context.read<ComplaintBloc>().state;
                if (state is ComplaintsLoaded) {
                  _updateFilters(state.complaints);
                }
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComplaintBloc, ComplaintState>(
      listener: (context, state) {
        if (state is ComplaintsLoaded) {
          _updateFilters(state.complaints);

          final msg = state.toastMessage;
          if (msg != null && msg.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: state.isError ? Colors.red.shade600 : Colors.green.shade600,
              ),
            );
          }
        }
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchFilterWidget(
              onSearchChanged: _onSearchChanged,
              onFilterTap: _onFilterTap,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _buildContent(state),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent(ComplaintState state) {
    if (state is ComplaintLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is ComplaintFailure) {
      return Center(child: Text('خطأ: ${state.message}'));
    } else if (state is ComplaintsLoaded) {
      return ComplaintsCardWidget(
        complaints: _filteredComplaints,
        pagination: state.pagination,
        onView: (complaint) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ComplaintDetailsPage(complaintId: complaint.id),
            ),
          );
        },
        onDelete: (complaint) => _confirmAndDelete(complaint),
        onStatusChanged: _onStatusChanged,
        onPageChanged: _onPageChanged,
      );
    } else {
      return const Center(child: Text('لا توجد شكاوى'));
    }
  }
}
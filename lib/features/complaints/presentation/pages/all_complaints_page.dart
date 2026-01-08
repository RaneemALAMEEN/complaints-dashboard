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
  int _currentPage = 1;

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
            c.status.label.contains(_searchQuery);
        final matchesStatus = _statusFilters[c.status] ?? true;
        return matchesText && matchesStatus;
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
            'تصفية الشكاوى حسب الحالة',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white
                  : const Color(0xFF1E293B),
              fontWeight: FontWeight.w600,
            ),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: _statusFilters.keys.map((status) {
                  return Container(
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
                        status.label,
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white
                              : const Color(0xFF1E293B),
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
                }).toList(),
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
        onDelete: (complaint) => debugPrint('Delete ${complaint.referenceNumber}'),
        onStatusChanged: (complaint, status) {
          context.read<ComplaintBloc>().add(UpdateComplaintStatus(complaint.id, status.label, notes: ''));
        },
        onPageChanged: _onPageChanged,
      );
    } else {
      return const Center(child: Text('لا توجد شكاوى'));
    }
  }
}
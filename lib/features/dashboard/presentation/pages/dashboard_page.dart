import 'package:complaints/features/complaints/domain/entities/complaint.dart';
import 'package:complaints/features/complaints/presentation/bloc/complaint_bloc.dart';
import 'package:complaints/features/complaints/presentation/bloc/complaint_event.dart';
import 'package:complaints/features/complaints/presentation/bloc/complaint_state.dart';
import 'package:complaints/features/complaints/presentation/pages/complaint_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardOverviewContent extends StatefulWidget {
  const DashboardOverviewContent({super.key});

  @override
  State<DashboardOverviewContent> createState() => _DashboardOverviewContentState();
}

class _DashboardOverviewContentState extends State<DashboardOverviewContent> {
  @override
  void initState() {
    super.initState();
    // Fetch dashboard data immediately when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ComplaintBloc>().add(const FetchDashboardData());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ComplaintBloc, ComplaintState>(
      builder: (context, state) {
        // Show loading indicator while fetching data
        if (state is ComplaintLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('جاري تحميل بيانات Dashboard...'),
              ],
            ),
          );
        }

        // Show error state
        if (state is ComplaintFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('خطأ في تحميل البيانات: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ComplaintBloc>().add(const FetchDashboardData());
                  },
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;

            final complaintsTable = _ComplaintsTable();
            final statsGrid = _StatsGrid();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _HeaderImage(),
                  const SizedBox(height: 5),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: complaintsTable,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: statsGrid,
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        complaintsTable,
                        const SizedBox(height: 16),
                        statsGrid,
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _HeaderImage extends StatelessWidget {
  const _HeaderImage();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 16 / 4,
        child: Image.asset(
          'assets/images/image 2.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _ComplaintsTable extends StatelessWidget {
  _ComplaintsTable({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ComplaintBloc, ComplaintState>(
      builder: (context, state) {
        final items = state is DashboardDataLoaded && state.complaints.isNotEmpty
            ? state.complaints.take(4).toList()
            : [];

        return Card(
          color: Theme.of(context).cardTheme.color,
          elevation: 1,
          shadowColor: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.04),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      'الشكاوي الجديدة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white
                            : const Color(0xFF111827),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'عرض الكل',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.deepPurple.shade300
                              : const Color(0xFF1E3A8A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (state is ComplaintLoading)
                  const Center(child: CircularProgressIndicator())
                else if (state is ComplaintFailure)
                  Center(child: Text('خطأ: ${state.message}'))
                else if (items.isEmpty)
                  const Center(child: Text('لا توجد شكاوى'))
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 24,
                      thickness: 1,
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? const Color(0xFF475569)
                          : const Color(0xFFE5E7EB),
                    ),
                    itemBuilder: (context, index) {
                      final complaint = items[index];
                      return Row(
                        children: [
                          Text(
                            complaint.referenceNumber,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.white
                                  : const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  complaint.description,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).brightness == Brightness.dark 
                                        ? Colors.white
                                        : const Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${complaint.governorate}, ${complaint.location}',
                                  style: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark 
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF6B7280),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ComplaintDetailsPage(complaintId: complaint.id),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? Colors.white.withOpacity(0.1)
                                    : const Color(0xFFEFF4FF),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Icon(
                                Icons.remove_red_eye_outlined,
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? Colors.white
                                    : const Color(0xFF1E3A8A),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatsGrid extends StatelessWidget {
  _StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ComplaintBloc, ComplaintState>(
      builder: (context, state) {
        final items = _getStatItems(state);

        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth >= 100 ? 2 : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  elevation: 1,
                  shadowColor: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.04),
                  color: Theme.of(context).cardTheme.color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Image.asset(
                            item.assetPath,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF6B7280),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.countLabel,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.white
                                : const Color(0xFF0F172A),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  List<_StatItem> _getStatItems(ComplaintState state) {
    if (state is DashboardDataLoaded) {
      final stats = state.stats;
      return [
        _StatItem(
          title: 'عدد الشكاوي الجديدة',
          countLabel: '${stats.newComplaints} شكاوي',
          assetPath: 'assets/images/Group (1).png',
          color: const Color(0xFF2563EB),
        ),
        _StatItem(
          title: 'مجمل عدد الشكاوي',
          countLabel: '${stats.totalComplaints} شكوى',
          assetPath: 'assets/images/noto_file-folder.png',
          color: const Color(0xFFFFB546),
        ),
        _StatItem(
          title: 'الشكاوي قيد المعالجة',
          countLabel: '${stats.inProgressComplaints} شكوى',
          assetPath: 'assets/images/fxemoji_hourglassflowingsand.png',
          color: const Color(0xFFF97316),
        ),
        _StatItem(
          title: 'الشكاوي المنجزة',
          countLabel: '${stats.resolvedComplaints} شكاوي',
          assetPath: 'assets/images/lets-icons_done-duotone (1).png',
          color: const Color(0xFF16A34A),
        ),
      ];
    } else if (state is ComplaintLoading) {
      // Return items with loading indicators
      return [
        _StatItem(
          title: 'عدد الشكاوي الجديدة',
          countLabel: '...',
          assetPath: 'assets/images/Group (1).png',
          color: const Color(0xFF2563EB),
        ),
        _StatItem(
          title: 'مجمل عدد الشكاوي',
          countLabel: '...',
          assetPath: 'assets/images/noto_file-folder.png',
          color: const Color(0xFFFFB546),
        ),
        _StatItem(
          title: 'الشكاوي قيد المعالجة',
          countLabel: '...',
          assetPath: 'assets/images/fxemoji_hourglassflowingsand.png',
          color: const Color(0xFFF97316),
        ),
        _StatItem(
          title: 'الشكاوي المنجزة',
          countLabel: '...',
          assetPath: 'assets/images/lets-icons_done-duotone (1).png',
          color: const Color(0xFF16A34A),
        ),
      ];
    } else if (state is ComplaintFailure) {
      // Return items with error indicators
      return [
        _StatItem(
          title: 'عدد الشكاوي الجديدة',
          countLabel: 'خطأ',
          assetPath: 'assets/images/Group (1).png',
          color: const Color(0xFF2563EB),
        ),
        _StatItem(
          title: 'مجمل عدد الشكاوي',
          countLabel: 'خطأ',
          assetPath: 'assets/images/noto_file-folder.png',
          color: const Color(0xFFFFB546),
        ),
        _StatItem(
          title: 'الشكاوي قيد المعالجة',
          countLabel: 'خطأ',
          assetPath: 'assets/images/fxemoji_hourglassflowingsand.png',
          color: const Color(0xFFF97316),
        ),
        _StatItem(
          title: 'الشكاوي المنجزة',
          countLabel: 'خطأ',
          assetPath: 'assets/images/lets-icons_done-duotone (1).png',
          color: const Color(0xFF16A34A),
        ),
      ];
    } else {
      // Default static values when no data is loaded yet
      return const [
        _StatItem(
          title: 'عدد الشكاوي الجديدة',
          countLabel: '0 شكاوي',
          assetPath: 'assets/images/Group (1).png',
          color: Color(0xFF2563EB),
        ),
        _StatItem(
          title: 'مجمل عدد الشكاوي',
          countLabel: '0 شكوى',
          assetPath: 'assets/images/noto_file-folder.png',
          color: Color(0xFFFFB546),
        ),
        _StatItem(
          title: 'الشكاوي قيد المعالجة',
          countLabel: '0 شكوى',
          assetPath: 'assets/images/fxemoji_hourglassflowingsand.png',
          color: Color(0xFFF97316),
        ),
        _StatItem(
          title: 'الشكاوي المنجزة',
          countLabel: '0 شكاوي',
          assetPath: 'assets/images/lets-icons_done-duotone (1).png',
          color: Color(0xFF16A34A),
        ),
      ];
    }
  }
}

class _StatItem {
  final String title;
  final String countLabel;
  final String assetPath;
  final Color color;

  const _StatItem({
    required this.title,
    required this.countLabel,
    required this.assetPath,
    required this.color,
  });
}



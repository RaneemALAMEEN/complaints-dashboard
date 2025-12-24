import 'package:flutter/material.dart';

class DashboardOverviewContent extends StatelessWidget {
  const DashboardOverviewContent({super.key});

  @override
  Widget build(BuildContext context) {
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
  final List<Map<String, String>> _items = const [
    {
      'id': '#224',
      'location': 'دمشق/المزة',
      'description': 'انخفاض متكرر للتيار في المنطقة بالكامل',
    },
    {
      'id': '#225',
      'location': 'دمشق/البرامكة',
      'description': 'انقطاع الكهرباء لمدة ثلاث ايام متواصلة',
    },
    {
      'id': '#226',
      'location': 'ريف دمشق/المزة',
      'description': 'الكهرباء',
    },
    {
      'id': '#227',
      'location': 'دمشق/المزة',
      'description': 'انقطاع الماء مستمر',
    },
  ];

  _ComplaintsTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.04),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Text(
                  'الشكاوي الجديدة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'عرض الكل',
                    style: TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const Divider(
                height: 24,
                thickness: 1,
                color: Color(0xFFE5E7EB),
              ),
              itemBuilder: (context, index) {
                final complaint = _items[index];
                return Row(
                  children: [
                    Text(
                      complaint['id']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            complaint['description']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            complaint['location']!,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF4FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: const Icon(
                        Icons.remove_red_eye_outlined,
                        color: Color(0xFF1E3A8A),
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
  }
}

class _StatsGrid extends StatelessWidget {
  final List<_StatItem> _items = const [
    _StatItem(
      title: 'عدد الشكاوي الجديدة',
      countLabel: '4 شكاوي',
      assetPath: 'assets/images/Group (1).png',
      color: Color(0xFF2563EB),
    ),
    _StatItem(
      title: 'مجمل عدد الشكاوي',
      countLabel: '24 شكوى',
      assetPath: 'assets/images/noto_file-folder.png',
      color: Color(0xFFFFB546),
    ),
    _StatItem(
      title: 'الشكاوي قيد المعالجة',
      countLabel: '15 شكوى',
      assetPath: 'assets/images/fxemoji_hourglassflowingsand.png',
      color: Color(0xFFF97316),
    ),
    _StatItem(
      title: 'الشكاوي المنجزة',
      countLabel: '5 شكاوي',
      assetPath: 'assets/images/lets-icons_done-duotone (1).png',
      color: Color(0xFF16A34A),
    ),
  ];

  _StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
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
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final item = _items[index];
            return Card(
              elevation: 1,
              shadowColor: Colors.black.withOpacity(0.04),
              color: Colors.white,
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
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.countLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
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



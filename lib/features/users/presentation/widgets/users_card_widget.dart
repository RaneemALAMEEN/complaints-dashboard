import 'package:complaints/features/users/domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'user_row_widget.dart';

class UsersCardWidget extends StatelessWidget {
  final List<User> users;
  final VoidCallback onExportTap;
  final int totalItems;
  final int pageSize;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  const UsersCardWidget({
    required this.users,
    required this.onExportTap,
    required this.totalItems,
    required this.pageSize,
    required this.currentPage,
    required this.onPageChanged,
    super.key,
  });

  int get _totalPages {
    if (totalItems <= 0) return 1;
    return (totalItems / pageSize).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = _totalPages;
    final safeCurrentPage = currentPage.clamp(1, totalPages);

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
          // عنوان الجدول + زر التصدير
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'معلومات الموظفين والمستخدمين',
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
                  Text('${users.length} مستخدم',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? const Color(0xFF94A3B8)
                            : Colors.grey,
                      )),
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: onExportTap,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // ترويسة الجدول
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? const Color(0xFF334155)
                  : const Color(0xFFF6F8FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                children: const [
                  _HeaderCell(label: 'الاسم', flex: 2),
                  _HeaderCell(label: 'البريد الإلكتروني', flex: 3),
                  _HeaderCell(label: 'رقم الهاتف', flex: 2),
                  _HeaderCell(label: 'النوع', flex: 1),
                  _HeaderCell(label: 'الجهة الحكومية', flex: 2),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // محتوى الجدول
          Expanded(
            child: ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return UserRowWidget(user: users[index]);
              },
            ),
          ),
          const SizedBox(height: 16),
          // Pagination
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'عرض ${users.length} من $totalItems',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black54,
                  fontSize: 14,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: safeCurrentPage > 1
                        ? () => onPageChanged(safeCurrentPage - 1)
                        : null,
                    icon: const Icon(Icons.chevron_right),
                    iconSize: 20,
                  ),
                  ...List.generate(totalPages > 5 ? 5 : totalPages, (index) {
                    int pageNumber;
                    if (totalPages <= 5) {
                      pageNumber = index + 1;
                    } else if (safeCurrentPage <= 3) {
                      pageNumber = index + 1;
                    } else if (safeCurrentPage >= totalPages - 2) {
                      pageNumber = totalPages - 4 + index;
                    } else {
                      pageNumber = safeCurrentPage - 2 + index;
                    }

                    final isActive = pageNumber == safeCurrentPage;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF3E68FF)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE0E5FF)),
                      ),
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: () => onPageChanged(pageNumber),
                        child: Text(
                          '$pageNumber',
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.black54,
                          ),
                        ),
                      ),
                    );
                  }),
                  IconButton(
                    onPressed: safeCurrentPage < totalPages
                        ? () => onPageChanged(safeCurrentPage + 1)
                        : null,
                    icon: const Icon(Icons.chevron_left),
                    iconSize: 20,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// HeaderCell
class _HeaderCell extends StatelessWidget {
  final String label;
  final int flex;

  const _HeaderCell({required this.label, required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          label, 
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white
                : const Color(0xFF111827),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../domain/entities/complaint.dart';
import 'package:complaints/core/services/permissions_service.dart';
import 'package:complaints/core/models/permission.dart';
import 'action_buttons_widget.dart';

class ComplaintRowWidget extends StatelessWidget {
  final Complaint complaint;
  final void Function(ComplaintStatus) onStatusChanged;
  final VoidCallback onView;
  final VoidCallback onDelete;

  const ComplaintRowWidget({
    required this.complaint,
    required this.onStatusChanged,
    required this.onView,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
              ? const Color(0xFF334155)
              : const Color(0xFFFDFEFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFF475569)
                : const Color(0xFFE8ECFF)
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 800;
            return isSmallScreen
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        SizedBox(width: 80, child: _BodyCellFixed(text: complaint.referenceNumber)),
                        SizedBox(width: 100, child: _BodyCellFixed(text: complaint.governmentEntity)),
                        SizedBox(width: 150, child: _BodyCellFixed(text: complaint.governorate)),
                        SizedBox(width: 300, child: _BodyCellFixed(text: complaint.description)),
                        SizedBox(
                          width: 150,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: _StatusSelector(
                              status: complaint.status,
                              onChanged: onStatusChanged,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: ActionButtonsWidget(
                            onView: onView,
                            onDelete: onDelete,
                          ),
                        ),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      _BodyCell(text: complaint.referenceNumber, flex: 2),
                      _BodyCell(text: complaint.governmentEntity, flex: 2),
                      _BodyCell(text: complaint.governorate, flex: 3),
                      _BodyCell(text: complaint.description, flex: 3),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _StatusSelector(
                            status: complaint.status,
                            onChanged: onStatusChanged,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: ActionButtonsWidget(
                          onView: onView,
                          onDelete: onDelete,
                        ),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }
}

class _BodyCellFixed extends StatelessWidget {
  final String text;

  const _BodyCellFixed({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.white
              : const Color(0xFF111827),
        ),
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  final String text;
  final int flex;

  const _BodyCell({required this.text, required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          text,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white
                : const Color(0xFF111827),
          ),
        ),
      ),
    );
  }
}

class _StatusSelector extends StatelessWidget {
  final ComplaintStatus status;
  final ValueChanged<ComplaintStatus>? onChanged;

  const _StatusSelector({required this.status, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final style = status.style;
    
    return FutureBuilder<User?>(
      future: PermissionsService.getCurrentUser(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final canUpdate = user != null && PermissionsService.canUpdateComplaint(user);
        
        if (!canUpdate) {
          // Show status as read-only if no permission
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: style.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: style.color.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(style.icon, size: 16, color: style.color),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    style.label,
                    style: TextStyle(
                      color: style.color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          );
        }
        
        return PopupMenuButton<ComplaintStatus>(
          tooltip: 'تغيير حالة الشكوى',
          position: PopupMenuPosition.over,
          onSelected: onChanged,
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: style.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: style.color.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(style.icon, size: 16, color: style.color),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    style.label,
                    style: TextStyle(
                      color: style.color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down,
                    color: Colors.black45, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:complaints/presentation/models/complaint_model.dart';
import 'package:complaints/presentation/widgets/action_buttons_widget.dart';
import 'package:flutter/material.dart';

class ComplaintRowWidget extends StatelessWidget {
  final Complaint complaint;
  final ComplaintStatus status;
  final ValueChanged<ComplaintStatus>? onStatusChanged;
  final VoidCallback? onView;
  final VoidCallback? onDelete;

  const ComplaintRowWidget({
    super.key,
    required this.complaint,
    required this.status,
    this.onStatusChanged,
    this.onView,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFDFEFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8ECFF)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 800;
            return isSmallScreen
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        SizedBox(width: 80, child: _BodyCellFixed(text: complaint.number)),
                        SizedBox(width: 150, child: _BodyCellFixed(text: complaint.region)),
                        SizedBox(width: 300, child: _BodyCellFixed(text: complaint.description)),
                        SizedBox(
                          width: 150,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: _StatusSelector(
                              status: status,
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
                      _BodyCell(text: complaint.number, flex: 1),
                      _BodyCell(text: complaint.region, flex: 2),
                      _BodyCell(text: complaint.description, flex: 4),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _StatusSelector(
                            status: status,
                            onChanged: onStatusChanged,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
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
        child: Text(text),
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
            const SizedBox(width: 6),
            Text(
              style.label,
              style: TextStyle(
                color: style.color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down,
                color: Colors.black45, size: 18),
          ],
        ),
      ),
    );
  }
}

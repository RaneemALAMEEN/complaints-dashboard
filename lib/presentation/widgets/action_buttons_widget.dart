import 'package:flutter/material.dart';

class ActionButtonsWidget extends StatelessWidget {
  final VoidCallback? onView;
  final VoidCallback? onDelete;

  const ActionButtonsWidget({
    super.key,
    this.onView,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _ActionButton(
            icon: Icons.visibility,
            background: Colors.indigo.shade900,
            onTap: onView,
          ),
          const SizedBox(width: 8),
          _ActionButton(
            icon: Icons.delete,
            background: Colors.red.shade400,
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color background;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.background,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

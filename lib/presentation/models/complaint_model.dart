import 'package:flutter/material.dart';

class Complaint {
  final String number;
  final String region;
  final String description;
  final ComplaintStatus status;

  const Complaint({
    required this.number,
    required this.region,
    required this.description,
    required this.status,
  });
}

enum ComplaintStatus { newOne, waitingInfo, inProgress, resolved, rejected }

extension ComplaintStatusX on ComplaintStatus {
  ComplaintStatusStyle get style {
    switch (this) {
      case ComplaintStatus.newOne:
        return const ComplaintStatusStyle(
          label: 'جديدة',
          color: Color(0xFF3E68FF),
          background: Color(0xFFE4ECFF),
          icon: Icons.fiber_new,
        );
      case ComplaintStatus.waitingInfo:
        return ComplaintStatusStyle(
          label: 'بانتظار المعلومات',
          color: Colors.cyan.shade700,
          background: const Color(0xFFDFF7FF),
          icon: Icons.hourglass_bottom,
        );
      case ComplaintStatus.inProgress:
        return ComplaintStatusStyle(
          label: 'قيد المعالجة',
          color: Colors.amber.shade800,
          background: const Color(0xFFFFF4DC),
          icon: Icons.timelapse,
        );
      case ComplaintStatus.resolved:
        return ComplaintStatusStyle(
          label: 'منجزة',
          color: Colors.green.shade700,
          background: const Color(0xFFE7F7EB),
          icon: Icons.check_circle,
        );
      case ComplaintStatus.rejected:
        return ComplaintStatusStyle(
          label: 'مرفوضة',
          color: Colors.red.shade600,
          background: const Color(0xFFFDE3E7),
          icon: Icons.cancel,
        );
    }
  }
}

class ComplaintStatusStyle {
  final String label;
  final Color color;
  final Color background;
  final IconData icon;

  const ComplaintStatusStyle({
    required this.label,
    required this.color,
    required this.background,
    required this.icon,
  });
}

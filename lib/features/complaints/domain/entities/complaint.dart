import 'package:flutter/material.dart';

enum ComplaintStatus {
  newOne,
  waitingInfo,
  inProgress,
  resolved,
  rejected,
}

class StatusStyle {
  final Color background;
  final Color color;
  final IconData icon;
  final String label;

  const StatusStyle({
    required this.background,
    required this.color,
    required this.icon,
    required this.label,
  });
}

extension ComplaintStatusExtension on ComplaintStatus {
  static ComplaintStatus fromString(String status) {
    switch (status) {
      case 'جديدة':
        return ComplaintStatus.newOne;
      case 'بانتظار المعلومات':
      case 'بانتظار معلومات اضافية':
        return ComplaintStatus.waitingInfo;
      case 'قيد التنفيذ':
      case 'قيد المعالجة':
        return ComplaintStatus.inProgress;
      case 'تم حلها':
      case 'منجزة':
        return ComplaintStatus.resolved;
      case 'مرفوضة':
        return ComplaintStatus.rejected;
      default:
        return ComplaintStatus.newOne;
    }
  }
  
  String get label {
    switch (this) {
      case ComplaintStatus.newOne:
        return 'جديدة';
      case ComplaintStatus.waitingInfo:
        return 'بانتظار معلومات اضافية';
      case ComplaintStatus.inProgress:
        return 'قيد المعالجة';
      case ComplaintStatus.resolved:
        return 'منجزة';
      case ComplaintStatus.rejected:
        return 'مرفوضة';
    }
  }

  StatusStyle get style {
    switch (this) {
      case ComplaintStatus.newOne:
        return const StatusStyle(
          background: Color(0xFFE3F2FD),
          color: Color(0xFF1976D2),
          icon: Icons.fiber_new,
          label: 'جديدة',
        );
      case ComplaintStatus.waitingInfo:
        return const StatusStyle(
          background: Color(0xFFFFF3E0),
          color: Color(0xFFF57C00),
          icon: Icons.hourglass_empty,
          label: 'بانتظار المعلومات',
        );
      case ComplaintStatus.inProgress:
        return const StatusStyle(
          background: Color(0xFFE8F5E8),
          color: Color(0xFF388E3C),
          icon: Icons.work,
          label: 'قيد التنفيذ',
        );
      case ComplaintStatus.resolved:
        return const StatusStyle(
          background: Color(0xFFE8F5E8),
          color: Color(0xFF388E3C),
          icon: Icons.check_circle,
          label: 'تم الحل',
        );
      case ComplaintStatus.rejected:
        return const StatusStyle(
          background: Color(0xFFFFEBEE),
          color: Color(0xFFD32F2F),
          icon: Icons.cancel,
          label: 'مرفوضة',
        );
    }
  }
}

class Complaint {
  final int id;
  final String referenceNumber;
  final String description;
  final String governorate;
  final String location;
  final String governmentEntity;
  final int citizenId;
  final List<String> images;
  final List<String> attachments;
  final ComplaintStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;
  final int? responsibleId;

  Complaint({
    required this.id,
    required this.referenceNumber,
    required this.description,
    required this.governorate,
    required this.location,
    required this.governmentEntity,
    required this.citizenId,
    required this.images,
    required this.attachments,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.responsibleId,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'],
      referenceNumber: json['reference_number'],
      description: json['description'],
      governorate: json['governorate'],
      location: json['location'],
      governmentEntity: json['government_entity'],
      citizenId: json['citizen_id'],
      images: List<String>.from(json['images']),
      attachments: List<String>.from(json['attachments']),
      status: ComplaintStatusExtension.fromString(json['status']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      notes: json['notes'],
      responsibleId: json['responsible_id'],
    );
  }
}

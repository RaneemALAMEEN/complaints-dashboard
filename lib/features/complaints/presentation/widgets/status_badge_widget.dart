// import 'package:complaints/features/complaints/domain/entities/complaint.dart';
// import 'package:flutter/material.dart';

// class StatusBadgeWidget extends StatelessWidget {
//   final ComplaintStatus status;

//   const StatusBadgeWidget({super.key, required this.status});

//   @override
//   Widget build(BuildContext context) {
//     final style = status.style;
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         decoration: BoxDecoration(
//           color: style.background,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(style.icon, size: 16, color: style.color),
//             const SizedBox(width: 6),
//             Text(
//               style.label,
//               style: TextStyle(color: style.color, fontWeight: FontWeight.w600),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

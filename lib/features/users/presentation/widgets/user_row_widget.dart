import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';

class UserRowWidget extends StatelessWidget {
  final User user;
  const UserRowWidget({required this.user, super.key});

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
        child: Row(
          children: [
            _BodyCell(text: user.name, flex: 2),
            _BodyCell(text: user.email, flex: 3),
            _BodyCell(text: user.phone, flex: 2),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.type == UserType.employee
                        ? Colors.blue.shade100
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: user.type == UserType.employee
                            ? Colors.blue.shade200
                            : Colors.green.shade200),
                  ),
                  child: Text(
                    user.type.label,
                    style: TextStyle(
                      color: user.type == UserType.employee
                          ? Colors.blue.shade800
                          : Colors.green.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
            _BodyCell(text: user.region, flex: 2),
          ],
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

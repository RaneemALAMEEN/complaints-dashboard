import 'package:flutter/material.dart';

class BodyCell extends StatelessWidget {
  final String text;
  final int flex;

  const BodyCell({required this.text, required this.flex, super.key});

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

class HeaderCell extends StatelessWidget {
  final String label;
  final int flex;

  const HeaderCell({required this.label, required this.flex, super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

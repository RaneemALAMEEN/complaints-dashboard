import 'package:flutter/material.dart';

class SearchFilterWidget extends StatelessWidget {
  final VoidCallback? onFilterTap;
  final ValueChanged<String>? onSearchChanged;

  const SearchFilterWidget({
    super.key,
    this.onFilterTap,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        children: [
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: const [
                  Icon(Icons.tune, color: Color(0xFF3E68FF)),
                  SizedBox(width: 8),
                  Text('تصفية'),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: onSearchChanged,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  hintText: '...بحث',
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

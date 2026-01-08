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
          Expanded(
            child: Container(
              height: 48,
             // width: 48,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? const Color(0xFF334155)
                    : Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              child: TextField(
                onChanged: onSearchChanged,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white
                      : Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: '...بحث',
                  hintStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? const Color(0xFF94A3B8)
                        : Colors.grey,
                  ),
                  border: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 151, 199, 247),
                      width: 2,
                    ),
                  ),
                  enabledBorder: InputBorder.none,
                  hoverColor: Theme.of(context).brightness == Brightness.dark 
                      ? const Color(0xFF475569)
                      : const Color.fromARGB(255, 249, 251, 255),
                  prefixIcon: Icon(
                    Icons.search, 
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? const Color(0xFF94A3B8)
                        : Colors.grey,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              height: 48,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 83, 162, 241),
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
                  Icon(Icons.tune, color: Colors.white),
                  SizedBox(width: 8),
                  Text('تصفية', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

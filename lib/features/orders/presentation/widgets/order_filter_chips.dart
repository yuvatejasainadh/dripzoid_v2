import 'package:flutter/material.dart';

class OrderFilterChips extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const OrderFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'Active', 'Delivered', 'Cancelled'];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;

          return ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (_) => onFilterChanged(filter),
            showCheckmark: false,
            labelStyle: TextStyle(
              color: isSelected ? Colors.black : null,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            selectedColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? Colors.white : Colors.grey.withValues(alpha: 0.3),
              ),
            ),
          );
        },
      ),
    );
  }
}

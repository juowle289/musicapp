import 'package:flutter/material.dart';

class ChipFilter extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;
  final bool
  useContainerStyle; // true = LibraryPage style, false = HomePage style
  final bool isDarkMode;

  const ChipFilter({
    super.key,
    required this.labels,
    required this.selectedIndex,
    this.onSelected,
    this.useContainerStyle = false,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: labels.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          final label = labels[index];
          return Padding(
            padding: EdgeInsets.only(right: index < labels.length - 1 ? 12 : 0),
            child: useContainerStyle
                ? _buildContainerChip(label, isSelected, index)
                : _buildChoiceChip(context, label, isSelected, index),
          );
        },
      ),
    );
  }

  // Style giống LibraryPage
  Widget _buildContainerChip(String label, bool isSelected, int index) {
    final darkAccent = const Color(0xFFFEEC93);
    final darkBackground = const Color(0xFF121212);

    return GestureDetector(
      onTap: () => onSelected?.call(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? darkAccent : Colors.black)
              : (isDarkMode ? darkBackground : Colors.white),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey,
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: isSelected
                ? (isDarkMode ? Colors.black : Colors.white)
                : (isDarkMode ? Colors.grey[400] : Colors.grey),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Style giống HomePage (ChoiceChip)
  Widget _buildChoiceChip(
    BuildContext context,
    String label,
    bool isSelected,
    int index,
  ) {
    final darkAccent = const Color(0xFFFEEC93);

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected?.call(index),
      selectedColor: isDarkMode ? darkAccent : Colors.black,
      backgroundColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
      side: BorderSide(
        color: isDarkMode ? Colors.grey[700]! : Colors.grey,
        width: 0.8,
      ),
      labelStyle: TextStyle(
        fontSize: 16,
        color: isSelected
            ? (isDarkMode ? Colors.black : Colors.white)
            : (isDarkMode ? Colors.grey[400]! : Colors.grey),
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      showCheckmark: false,
    );
  }
}

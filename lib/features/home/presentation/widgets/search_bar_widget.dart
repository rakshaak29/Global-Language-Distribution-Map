import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A styled search bar for the home screen.
class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool isSearching;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.isSearching = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Search languages, families, regions...',
          prefixIcon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isSearching
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    ),
                  )
                : Icon(
                    Icons.search_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  onPressed: () {
                    controller.clear();
                    onClear();
                  },
                )
              : null,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:global_language_distribution_map/app/theme.dart';
import 'package:global_language_distribution_map/core/constants/app_constants.dart';
import 'package:google_fonts/google_fonts.dart';

/// Horizontally scrollable filter chips for endangerment status.
class FilterChipsWidget extends StatelessWidget {
  final String selectedStatus;
  final List<String> statuses;
  final Map<String, int> counts;
  final ValueChanged<String> onSelected;

  const FilterChipsWidget({
    super.key,
    required this.selectedStatus,
    required this.statuses,
    required this.counts,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: statuses.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = statuses[index];
          final isSelected = status == selectedStatus;
          final label = status == 'all'
              ? 'All'
              : AppConstants.endangermentLabels[status] ?? status;
          final count = status == 'all'
              ? counts.values.fold(0, (a, b) => a + b)
              : counts[status] ?? 0;
          final statusColor = status == 'all'
              ? colorScheme.primary
              : AppTheme.getEndangermentColor(status);

          return FilterChip(
            selected: isSelected,
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (status != 'all') ...[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
                Text(
                  '($count)',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: isSelected
                        ? statusColor
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            selectedColor: statusColor.withValues(alpha: 0.15),
            checkmarkColor: statusColor,
            side: BorderSide(
              color: isSelected
                  ? statusColor.withValues(alpha: 0.5)
                  : colorScheme.outline.withValues(alpha: 0.3),
            ),
            onSelected: (_) => onSelected(status),
          );
        },
      ),
    );
  }
}

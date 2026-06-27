import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:global_language_distribution_map/app/router.dart';
import 'package:global_language_distribution_map/app/theme.dart';
import 'package:global_language_distribution_map/data/models/language.dart';
import 'package:global_language_distribution_map/features/endangered/presentation/view_models/endangered_view_model.dart';
import 'package:global_language_distribution_map/features/map/presentation/view_models/map_view_model.dart';

/// Endangered Languages screen.
///
/// Shows a filterable, searchable list of endangered languages
/// with status badges and speaker count info.
class EndangeredScreen extends StatefulWidget {
  const EndangeredScreen({super.key});

  @override
  State<EndangeredScreen> createState() => _EndangeredScreenState();
}

class _EndangeredScreenState extends State<EndangeredScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  // Map internal status keys to display category filter labels
  static const _filterCategories = [
    ('all', 'All'),
    ('threatened', 'Vulnerable'),
    ('shifting', 'Definitely'),
    ('moribund', 'Severely'),
    ('nearly extinct', 'Critically'),
    ('extinct', 'Extinct'),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EndangeredViewModel>();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appBarColor = theme.appBarTheme.backgroundColor ?? AppTheme.primaryGreenDark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Endangered Languages'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // ─── Search ─────────────────────────────────────────────
          Container(
            color: appBarColor,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: vm.search,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: 'Search endangered languages...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          // ─── Filter Chips ────────────────────────────────────────
          Container(
            color: appBarColor,
            padding: const EdgeInsets.only(bottom: 16),
            child: SizedBox(
              height: 36,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: _filterCategories.map((cat) {
                  final key = cat.$1;
                  final label = cat.$2;
                  final isSelected = vm.selectedCategory == key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => vm.setCategory(key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          label,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppTheme.primaryGreenDark
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ─── Rounded top of white area ───────────────────────────
          Container(
            height: 16,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),

          // ─── Count & Results Header ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                Text(
                  '${vm.filteredLanguages.length} languages',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // ─── Language List ───────────────────────────────────────
          Expanded(
            child: vm.filteredLanguages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 48, color: colorScheme.onSurfaceVariant),
                        const SizedBox(height: 12),
                        Text(
                          'No languages found',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: vm.filteredLanguages.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final lang = vm.filteredLanguages[index];
                      return _EndangeredTile(
                        language: lang,
                        onViewOnMap: () {
                          context.read<MapViewModel>().flyToLanguage(lang);
                          context.pop();
                          context.go(RoutePaths.map);
                        },
                        onDetail: () {
                          context.push(RoutePaths.languageDetail, extra: lang);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EndangeredTile extends StatelessWidget {
  final Language language;
  final VoidCallback onViewOnMap;
  final VoidCallback onDetail;

  const _EndangeredTile({
    required this.language,
    required this.onViewOnMap,
    required this.onDetail,
  });
  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.getEndangermentColor(language.endangeredStatus);
    final label = EndangeredViewModel.labelFor(language.endangeredStatus);
    final speakers = EndangeredViewModel.speakerCountFor(language);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onDetail,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            // Warning icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: statusColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // Name, country, speakers
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.name,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        language.countryRegion,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (speakers != 'Unknown') ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$speakers speakers',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Status badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

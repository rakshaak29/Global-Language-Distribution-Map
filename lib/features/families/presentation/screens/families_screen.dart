import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:global_language_distribution_map/app/router.dart';
import 'package:global_language_distribution_map/app/theme.dart';
import 'package:global_language_distribution_map/features/families/presentation/view_models/families_view_model.dart';
import 'package:global_language_distribution_map/features/map/presentation/view_models/map_view_model.dart';

/// Language Families Screen.
///
/// Displays all language families as colorful gradient cards with
/// language count and speaker count. Includes search functionality.
class FamiliesScreen extends StatefulWidget {
  const FamiliesScreen({super.key});

  @override
  State<FamiliesScreen> createState() => _FamiliesScreenState();
}

class _FamiliesScreenState extends State<FamiliesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FamiliesViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // ─── Header ─────────────────────────────────────────────
          _FamiliesHeader(familyCount: vm.totalFamilies),

          // ─── Search ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Transform.translate(
              offset: const Offset(0, -24),
              child: _SearchBar(
                controller: _searchController,
                onChanged: vm.search,
              ),
            ),
          ),

          // ─── Family List ─────────────────────────────────────────
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -24),
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.filteredFamilies.isEmpty
                      ? Center(
                          child: Text(
                            'No families found',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: const Color(0xFF52634F),
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: vm.filteredFamilies.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final family = vm.filteredFamilies[index];
                            final color = _colorForIndex(index);
                            return _FamilyCard(
                              family: family,
                              accentColor: color,
                              onTap: () => _showFamilyActions(context, family, vm),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorForIndex(int index) {
    final gradients = AppTheme.familyCardGradients;
    return gradients[index % gradients.length][0];
  }

  void _showFamilyActions(BuildContext context, FamilyStat family, FamiliesViewModel vm) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  family.name,
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                Text(
                  '${family.languageCount} languages · ${family.speakerCount} speakers',
                  style: GoogleFonts.inter(fontSize: 13, color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.map_rounded, color: AppTheme.primaryGreen),
                  title: Text('View on Map', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  subtitle: Text('Filter map to show only ${family.name} languages'),
                  onTap: () {
                    Navigator.pop(ctx);
                    final mapVm = context.read<MapViewModel>();
                    mapVm.setFamilyFilter(family.name);
                    // Fly to the first language with coordinates
                    final langs = vm.getLanguagesForFamily(family.name);
                    final withCoords = langs.where((l) => l.hasCoordinates).toList();
                    if (withCoords.isNotEmpty) {
                      mapVm.selectLanguage(withCoords.first);
                    }
                    context.go(RoutePaths.map);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.list_rounded, color: colorScheme.primary),
                  title: Text('View Languages', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  subtitle: Text('Browse all ${family.languageCount} languages'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showFamilyLanguages(context, family, vm);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFamilyLanguages(BuildContext context, FamilyStat family, FamiliesViewModel vm) {
    final langs = vm.getLanguagesForFamily(family.name);
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surfaceContainer,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        '${family.name} (${langs.length})',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: langs.length,
                    itemBuilder: (_, i) {
                      final lang = langs[i];
                      return ListTile(
                        leading: Icon(
                          Icons.language_rounded,
                          color: AppTheme.getEndangermentColor(lang.endangeredStatus),
                        ),
                        title: Text(lang.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: Text(lang.countryRegion, style: GoogleFonts.inter(fontSize: 12)),
                        trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                        onTap: () {
                          Navigator.pop(ctx);
                          context.read<MapViewModel>().flyToLanguage(lang);
                          context.go(RoutePaths.map);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _FamiliesHeader extends StatelessWidget {
  final int familyCount;

  const _FamiliesHeader({required this.familyCount});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _CurvedClipper(),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primaryGreenDark, AppTheme.primaryGreen],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Language Families',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$familyCount major families',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Search families...',
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          prefixIcon: Icon(Icons.search_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant, size: 22),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

class _FamilyCard extends StatelessWidget {
  final FamilyStat family;
  final Color accentColor;
  final VoidCallback? onTap;

  const _FamilyCard({required this.family, required this.accentColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant, width: 1),
      ),
      color: Theme.of(context).cardTheme.color,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Colored left border strip
            Container(width: 6, color: accentColor),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                child: Row(
                  children: [
                    // Emoji icon in a subtle accent circle
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        family.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Name + count
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            family.name,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${family.languageCount} languages',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Speaker count
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          family.speakerCount == 'Unknown' ? '—' : family.speakerCount,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'speakers',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

class _CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 24);
    path.quadraticBezierTo(
        size.width / 2, size.height + 8, size.width, size.height - 24);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_CurvedClipper old) => false;
}

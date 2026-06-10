import 'package:flutter/material.dart';
import 'package:global_language_distribution_map/features/home/presentation/view_models/home_view_model.dart';
import 'package:global_language_distribution_map/features/home/presentation/widgets/filter_chips_widget.dart';
import 'package:global_language_distribution_map/features/home/presentation/widgets/language_list_tile.dart';
import 'package:global_language_distribution_map/features/home/presentation/widgets/search_bar_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// The Home Screen displaying a list of languages, search bar, and filters.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TextEditingController _searchController;
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _viewModel = context.read<HomeViewModel>();
    _searchController.text = _viewModel.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Linguistic Diversity',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Consumer<HomeViewModel>(
              builder: (context, vm, child) {
                return Text(
                  'Showing ${vm.filteredCount} of ${vm.totalCount} languages',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          Consumer<HomeViewModel>(
            builder: (context, vm, child) {
              if (vm.searchQuery.isNotEmpty || vm.selectedEndangerment != 'all') {
                return IconButton(
                  icon: const Icon(Icons.filter_alt_off_rounded),
                  tooltip: 'Clear Filters',
                  onPressed: () {
                    _searchController.clear();
                    vm.clearFilters();
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          // Search Bar
          Consumer<HomeViewModel>(
            builder: (context, vm, child) {
              return SearchBarWidget(
                controller: _searchController,
                onChanged: vm.onSearchChanged,
                onClear: vm.clearFilters,
                isSearching: vm.isSearching,
              );
            },
          ),
          const SizedBox(height: 12),
          // Filter Chips
          Consumer<HomeViewModel>(
            builder: (context, vm, child) {
              return FilterChipsWidget(
                selectedStatus: vm.selectedEndangerment,
                statuses: vm.endangermentStatuses,
                counts: vm.endangermentCounts,
                onSelected: vm.setEndangermentFilter,
              );
            },
          ),
          const SizedBox(height: 8),
          // Language List
          Expanded(
            child: Consumer<HomeViewModel>(
              builder: (context, vm, child) {
                final languages = vm.filteredLanguages;

                if (languages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No languages found',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try modifying your search or filter criteria',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final language = languages[index];
                    final isExpanded = vm.selectedLanguage == language;

                    return LanguageListTile(
                      language: language,
                      isExpanded: isExpanded,
                      onTap: () {
                        vm.selectLanguage(isExpanded ? null : language);
                      },
                    );
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

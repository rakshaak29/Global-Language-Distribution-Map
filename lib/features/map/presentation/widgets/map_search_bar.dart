import 'package:flutter/material.dart';
import 'package:global_language_distribution_map/data/models/language.dart';
import 'package:google_fonts/google_fonts.dart';

/// An animated search overlay for finding languages on the map.
///
/// Displays a search text field and a scrollable list of matching results.
/// Tapping a result invokes [onLanguageSelected] so the map can animate
/// to that language's coordinates.
class MapSearchBar extends StatefulWidget {
  final List<Language> searchResults;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<Language> onLanguageSelected;
  final VoidCallback onClose;

  const MapSearchBar({
    super.key,
    required this.searchResults,
    required this.onSearchChanged,
    required this.onLanguageSelected,
    required this.onClose,
  });

  @override
  State<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus when the search bar appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 4, 12, 0),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search input
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: widget.onSearchChanged,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Search languages, families, regions...',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      _controller.clear();
                      widget.onClose();
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
              ),
            ),

            // Results list
            if (widget.searchResults.isNotEmpty) ...[
              Divider(
                height: 1,
                color: colorScheme.outlineVariant,
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: widget.searchResults.length,
                  itemBuilder: (context, index) {
                    final language = widget.searchResults[index];
                    return _buildResultTile(context, language);
                  },
                ),
              ),
            ],

            // No results message
            if (_controller.text.isNotEmpty && widget.searchResults.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No languages found',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultTile(BuildContext context, Language language) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => widget.onLanguageSelected(language),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(
              Icons.location_on_rounded,
              size: 18,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${language.languageFamily} · ${language.countryRegion}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

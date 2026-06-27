import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_language_distribution_map/app/theme.dart';

class DocumentationScreen extends StatelessWidget {
  const DocumentationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Documentation'),
        backgroundColor: AppTheme.primaryGreenDark,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How to Use This App',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _DocSection(
              title: 'Connecting to Liquid Galaxy',
              content: 'Navigate to the Settings tab and enter the IP Address and Port of your Liquid Galaxy master machine. Tap "Test Connection" to connect.',
            ),
            _DocSection(
              title: 'Exploring the Map',
              content: 'The Map tab displays all global languages as markers. Tap on a marker to view language details in a bottom sheet. You can use the "Fly to Location" button to send a KML query to Liquid Galaxy.',
            ),
            _DocSection(
              title: 'Filtering Languages',
              content: 'Use the Families and Tours tabs to browse languages grouped by their linguistic family or predefined regional tours.',
            ),
            _DocSection(
              title: 'Endangered Languages',
              content: 'The Endangered tab lists languages categorized by their UNESCO endangerment status. You can search by name or filter by status.',
            ),
            _DocSection(
              title: 'Settings & Theming',
              content: 'In the Settings tab, you can toggle dark mode, adjust the map marker size, and configure map behaviors like auto-flying on selection.',
            ),
          ],
        ),
      ),
    );
  }
}

class _DocSection extends StatelessWidget {
  final String title;
  final String content;

  const _DocSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

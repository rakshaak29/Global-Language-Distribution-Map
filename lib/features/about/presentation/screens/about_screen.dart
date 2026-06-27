import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_language_distribution_map/app/theme.dart';
import 'package:global_language_distribution_map/app/router.dart';
import 'package:global_language_distribution_map/core/constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

/// About Screen showing app info, developer, data sources, and tech stack.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Future<void> launchGithub() async {
      final url = Uri.parse('https://github.com/rakshaak29/Global-Language-Distribution-Map');
      if (!await launchUrl(url)) {
        debugPrint('Could not launch $url');
      }
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: AppTheme.primaryGreenDark,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ─── Hero Section ────────────────────────────────────
            Container(
              color: AppTheme.primaryGreenDark,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                children: [
                  // App icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.language_rounded,
                      size: 44,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Global Language',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Distribution Map',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w300,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'v${AppConstants.appVersion}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'An interactive visualization tool for exploring\nthe world\'s linguistic diversity',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.75),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ─── Developer Section ───────────────────────────────
            _SectionCard(
              title: 'Developer',
              child: Column(
                children: [
                  _InfoRow(
                    label: 'Name',
                    value: AppConstants.developerName,
                    icon: Icons.person_rounded,
                  ),
                  const Divider(height: 1),
                  _InfoRow(
                    label: 'Organization',
                    value: AppConstants.organization,
                    icon: Icons.business_rounded,
                  ),
                  const Divider(height: 1),
                  _InfoRow(
                    label: 'Program',
                    value: AppConstants.program,
                    icon: Icons.code_rounded,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ─── Data Sources ────────────────────────────────────
            _SectionCard(
              title: 'Data Sources',
              child: Column(
                children: [
                  _InfoRow(
                    label: 'Languages',
                    value: 'Glottolog 5.0',
                    icon: Icons.menu_book_rounded,
                  ),
                  const Divider(height: 1),
                  _InfoRow(
                    label: 'Endangerment',
                    value: 'UNESCO Atlas',
                    icon: Icons.warning_amber_rounded,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ─── Built With ──────────────────────────────────────
            _SectionCard(
              title: 'Built With',
              child: Column(
                children: [
                  _InfoRow(
                    label: 'Framework',
                    value: 'Flutter / Dart',
                    icon: Icons.flutter_dash_rounded,
                  ),
                  const Divider(height: 1),
                  _InfoRow(
                    label: 'Visualization',
                    value: 'Liquid Galaxy',
                    icon: Icons.public_rounded,
                  ),
                  const Divider(height: 1),
                  _InfoRow(
                    label: 'Data Format',
                    value: 'KML / GeoJSON',
                    icon: Icons.map_outlined,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ─── Action Buttons ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: launchGithub,
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: Text(
                        'View on GitHub',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.push(RoutePaths.documentation);
                      },
                      icon: const Icon(Icons.article_outlined, size: 18),
                      label: Text(
                        'Documentation',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryGreenDark,
                        side: const BorderSide(color: Color(0xFFCED9CD)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ─── Footer ──────────────────────────────────────────
            Text(
              'Powered by Liquid Galaxy',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF9EAA9B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryGreen,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryGreen),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

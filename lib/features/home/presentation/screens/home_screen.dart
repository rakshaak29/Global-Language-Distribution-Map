import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:global_language_distribution_map/app/router.dart';
import 'package:global_language_distribution_map/app/theme.dart';
import 'package:global_language_distribution_map/core/widgets/curved_header.dart';
import 'package:global_language_distribution_map/features/home/presentation/view_models/home_view_model.dart';

/// The Home Dashboard screen.
///
/// Displays stats, a featured card, and explore section with 4 grid cards.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F4),
      body: CustomScrollView(
        slivers: [
          // ─── Curved Green Header ───────────────────────────────────
          SliverToBoxAdapter(
            child: _HomeHeader(vm: vm),
          ),

          // ─── Featured: Explore the Map ─────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _FeaturedCard(
                onTap: () => context.go(RoutePaths.map),
              ),
            ),
          ),

          // ─── Explore Section ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                'EXPLORE',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF52634F),
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),

          // ─── 2x2 Explore Grid ──────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              delegate: SliverChildListDelegate([
                _ExploreCard(
                  title: 'Language Map',
                  subtitle: 'Explore 7,000+ languages on\nan interactive world map',
                  icon: Icons.map_rounded,
                  countLabel: '${_formatCount(vm.mappableCount)}',
                  countSublabel: 'Languages',
                  gradientColors: const [Color(0xFF2E7D32), Color(0xFF43A047)],
                  onTap: () => context.go(RoutePaths.map),
                ),
                _ExploreCard(
                  title: 'Language Families',
                  subtitle: 'Discover major language\nfamilies globally',
                  icon: Icons.language_rounded,
                  countLabel: '${vm.totalFamilies}',
                  countSublabel: 'Families',
                  gradientColors: const [Color(0xFF00695C), Color(0xFF26A69A)],
                  onTap: () => context.go(RoutePaths.families),
                ),
                _ExploreCard(
                  title: 'Diversity Heatmap',
                  subtitle: 'Visualize linguistic hotspots\nacross continents',
                  icon: Icons.whatshot_rounded,
                  countLabel: 'Top 5',
                  countSublabel: 'Hotspots',
                  gradientColors: const [Color(0xFFE65100), Color(0xFFFF8F00)],
                  onTap: () => context.push(RoutePaths.heatmap),
                ),
                _ExploreCard(
                  title: 'Endangered\nLangua...',
                  subtitle: 'Track languages at risk of\nextinction',
                  icon: Icons.warning_rounded,
                  countLabel: '${_formatCount(vm.endangeredCount)}+',
                  countSublabel: 'At Risk',
                  gradientColors: const [Color(0xFFC62828), Color(0xFFEF5350)],
                  onTap: () => context.push(RoutePaths.endangered),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

class _HomeHeader extends StatelessWidget {
  final HomeViewModel vm;

  const _HomeHeader({required this.vm});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _CurvedBottomClipper(),
      child: Container(
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Language Map',
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    HeaderIconButton(
                      icon: Icons.notifications_outlined,
                      onPressed: () {},
                      tooltip: 'Notifications',
                    ),
                    const SizedBox(width: 8),
                    HeaderIconButton(
                      icon: Icons.language_rounded,
                      onPressed: () => context.go(RoutePaths.map),
                      tooltip: 'Open Map',
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Stats card
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        emoji: '🌍',
                        value: '${_formatCount(vm.totalCount)}',
                        label: 'Languages',
                      ),
                      _Divider(),
                      _StatItem(
                        emoji: '🌳',
                        value: '${vm.totalFamilies}',
                        label: 'Families',
                      ),
                      _Divider(),
                      _StatItem(
                        emoji: '⚠️',
                        value: '${_formatCount(vm.endangeredCount)}',
                        label: 'Endangered',
                        valueColor: const Color(0xFFFFCC02),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withValues(alpha: 0.3),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color? valueColor;

  const _StatItem({
    required this.emoji,
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: valueColor ?? Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final VoidCallback onTap;

  const _FeaturedCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1B3A1F),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Featured',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Explore the Map',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '14 markers near you',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.trending_up_rounded,
              color: Colors.white,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExploreCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String countLabel;
  final String countSublabel;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _ExploreCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.countLabel,
    required this.countSublabel,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: icon + count
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      countLabel,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      countSublabel,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const Spacer(),

            // Bottom: title + subtitle
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 24);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 8,
      size.width,
      size.height - 24,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_CurvedBottomClipper oldClipper) => false;
}

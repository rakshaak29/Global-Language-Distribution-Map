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
    final width = MediaQuery.of(context).size.width;
    final int crossAxisCount = width > 900 ? 4 : (width > 600 ? 2 : 2);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),

          // ─── Explore Grid ──────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 160,
              ),
              delegate: SliverChildListDelegate([
                _ExploreCard(
                  title: 'Language Map',
                  subtitle: 'Explore 7,000+ languages on\nan interactive world map',
                  icon: Icons.map_rounded,
                  countLabel: '${_formatCount(vm.mappableCount)}',
                  countSublabel: 'Languages',
                  accentColor: const Color(0xFF2E7D32),
                  onTap: () => context.go(RoutePaths.map),
                ),
                _ExploreCard(
                  title: 'Language Families',
                  subtitle: 'Discover major language\nfamilies globally',
                  icon: Icons.language_rounded,
                  countLabel: '${vm.totalFamilies}',
                  countSublabel: 'Families',
                  accentColor: const Color(0xFF00695C),
                  onTap: () => context.go(RoutePaths.families),
                ),
                _ExploreCard(
                  title: 'Diversity Heatmap',
                  subtitle: 'Visualize linguistic hotspots\nacross continents',
                  icon: Icons.whatshot_rounded,
                  countLabel: 'Top 5',
                  countSublabel: 'Hotspots',
                  accentColor: const Color(0xFFE65100),
                  onTap: () => context.push(RoutePaths.heatmap),
                ),
                _ExploreCard(
                  title: 'Endangered\nLangua...',
                  subtitle: 'Track languages at risk of\nextinction',
                  icon: Icons.warning_rounded,
                  countLabel: '${_formatCount(vm.endangeredCount)}+',
                  countSublabel: 'At Risk',
                  accentColor: const Color(0xFFC62828),
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

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        
        final notifications = [
          (
            'New Data Update',
            'Database successfully synchronized. Added 14 new endangered languages from the Amazon region.',
            '10m ago',
            Icons.dns_rounded,
            AppTheme.primaryGreen
          ),
          (
            'Liquid Galaxy Status',
            'Liquid Galaxy connected successfully on 192.168.1.100:2222. Active viewports configured.',
            '1h ago',
            Icons.connected_tv_rounded,
            const Color(0xFF00838F)
          ),
          (
            'Endangerment Critical Alert',
            'Urgent: The language "Ainu" (Japonic family) is reported to have only 2 remaining native speakers.',
            '3h ago',
            Icons.warning_amber_rounded,
            const Color(0xFFB71C1C)
          ),
          (
            'KML Export Completed',
            'Successfully compiled KML file for "Dravidian Languages" family with 82 placemarks.',
            '5h ago',
            Icons.folder_zip_rounded,
            const Color(0xFFE65100)
          ),
        ];

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    'Notifications',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Project Alerts',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = notifications[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: item.$5.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(item.$4, color: item.$5, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.$1,
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      item.$3,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.$2,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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
                      onPressed: () => _showNotifications(context),
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
  final Color accentColor;
  final VoidCallback onTap;

  const _ExploreCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.countLabel,
    required this.countSublabel,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant, width: 1),
      ),
      color: Theme.of(context).cardTheme.color,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
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
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: accentColor, size: 20),
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
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        countSublabel,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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

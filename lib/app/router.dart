import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:global_language_distribution_map/app/theme.dart';
import 'package:global_language_distribution_map/data/models/language.dart';
import 'package:global_language_distribution_map/features/home/presentation/screens/home_screen.dart';
import 'package:global_language_distribution_map/features/map/presentation/screens/map_screen.dart';
import 'package:global_language_distribution_map/features/settings/presentation/screens/settings_screen.dart';
import 'package:global_language_distribution_map/features/splash/presentation/screens/splash_screen.dart';
import 'package:global_language_distribution_map/features/families/presentation/screens/families_screen.dart';
import 'package:global_language_distribution_map/features/tours/presentation/screens/tours_screen.dart';
import 'package:global_language_distribution_map/features/endangered/presentation/screens/endangered_screen.dart';
import 'package:global_language_distribution_map/features/heatmap/presentation/screens/heatmap_screen.dart';
import 'package:global_language_distribution_map/features/language_detail/presentation/screens/language_detail_screen.dart';
import 'package:global_language_distribution_map/features/about/presentation/screens/about_screen.dart';
import 'package:global_language_distribution_map/features/about/presentation/screens/documentation_screen.dart';
import 'package:global_language_distribution_map/features/kml_export/presentation/screens/kml_export_screen.dart';
import 'package:google_fonts/google_fonts.dart';

/// Application route names.
class RouteNames {
  RouteNames._();

  static const String splash = 'splash';
  static const String home = 'home';
  static const String map = 'map';
  static const String settings = 'settings';
  static const String families = 'families';
  static const String tours = 'tours';
  static const String endangered = 'endangered';
  static const String heatmap = 'heatmap';
  static const String languageDetail = 'language-detail';
  static const String about = 'about';
  static const String documentation = 'documentation';
  static const String kmlExport = 'kml-export';
}

/// Application route paths.
class RoutePaths {
  RoutePaths._();

  static const String splash = '/splash';
  static const String home = '/home';
  static const String map = '/map';
  static const String settings = '/settings';
  static const String families = '/families';
  static const String tours = '/tours';
  static const String endangered = '/endangered';
  static const String heatmap = '/heatmap';
  static const String languageDetail = '/language-detail';
  static const String about = '/about';
  static const String documentation = '/documentation';
  static const String kmlExport = '/kml-export';
}

/// The main scaffold with bottom navigation bar (5 tabs).
class _ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _ScaffoldWithNavBar({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C201B) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? const Color(0xFF2A3029)
                  : const Color(0xFFE0E8DF),
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          destinations: [
            _buildDestination(
              context,
              index: 0,
              currentIndex: navigationShell.currentIndex,
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              label: 'Home',
            ),
            _buildDestination(
              context,
              index: 1,
              currentIndex: navigationShell.currentIndex,
              icon: Icons.map_outlined,
              selectedIcon: Icons.map_rounded,
              label: 'Map',
            ),
            _buildDestination(
              context,
              index: 2,
              currentIndex: navigationShell.currentIndex,
              icon: Icons.group_outlined,
              selectedIcon: Icons.group_rounded,
              label: 'Families',
            ),
            _buildDestination(
              context,
              index: 3,
              currentIndex: navigationShell.currentIndex,
              icon: Icons.explore_outlined,
              selectedIcon: Icons.explore_rounded,
              label: 'Tours',
            ),
            _buildDestination(
              context,
              index: 4,
              currentIndex: navigationShell.currentIndex,
              icon: Icons.settings_outlined,
              selectedIcon: Icons.settings_rounded,
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  NavigationDestination _buildDestination(
    BuildContext context, {
    required int index,
    required int currentIndex,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final isSelected = index == currentIndex;
    final color = isSelected
        ? AppTheme.primaryGreen
        : const Color(0xFF9EAA9B);

    return NavigationDestination(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: color,
            ),
          ),
          if (isSelected) ...[
            const SizedBox(height: 3),
            Container(
              width: 20,
              height: 3,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ],
      ),
      selectedIcon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(selectedIcon, color: AppTheme.primaryGreen),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 3),
          Container(
            width: 20,
            height: 3,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
      label: '',
    );
  }
}

/// Creates the application router.
GoRouter createRouter() {
  return GoRouter(
    initialLocation: RoutePaths.splash,
    redirect: (context, state) {
      final path = state.uri.path;
      if (path == '/') {
        return RoutePaths.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.kmlExport,
        name: RouteNames.kmlExport,
        builder: (context, state) => const KmlExportScreen(),
      ),
      GoRoute(
        path: RoutePaths.endangered,
        name: RouteNames.endangered,
        builder: (context, state) => const EndangeredScreen(),
      ),
      GoRoute(
        path: RoutePaths.heatmap,
        name: RouteNames.heatmap,
        builder: (context, state) => const HeatmapScreen(),
      ),
      GoRoute(
        path: RoutePaths.languageDetail,
        name: RouteNames.languageDetail,
        builder: (context, state) {
          final language = state.extra as Language;
          return LanguageDetailScreen(language: language);
        },
      ),
      GoRoute(
        path: RoutePaths.about,
        name: RouteNames.about,
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: RoutePaths.documentation,
        name: RouteNames.documentation,
        builder: (context, state) => const DocumentationScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                name: RouteNames.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Branch 1: Map
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.map,
                name: RouteNames.map,
                builder: (context, state) => const MapScreen(),
              ),
            ],
          ),
          // Branch 2: Families
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.families,
                name: RouteNames.families,
                builder: (context, state) => const FamiliesScreen(),
              ),
            ],
          ),
          // Branch 3: Tours
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.tours,
                name: RouteNames.tours,
                builder: (context, state) => const ToursScreen(),
              ),
            ],
          ),
          // Branch 4: Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.settings,
                name: RouteNames.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

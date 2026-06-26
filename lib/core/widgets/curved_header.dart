import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_language_distribution_map/app/theme.dart';

/// Reusable dark-green curved header used across Home, Families, Tours, Settings.
///
/// Renders a dark green background with a curved bottom edge, title, subtitle,
/// and optional action widgets.
class CurvedHeader extends StatelessWidget {
  final String? overline;
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? child;
  final double height;

  const CurvedHeader({
    super.key,
    this.overline,
    required this.title,
    this.subtitle,
    this.actions,
    this.child,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _CurvedBottomClipper(),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: height),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryGreenDark,
              AppTheme.primaryGreen,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row: overline + actions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (overline != null) ...[
                            Text(
                              overline!,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            title,
                            style: GoogleFonts.inter(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitle!,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (actions != null) ...[
                      const SizedBox(width: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: actions!,
                      ),
                    ],
                  ],
                ),
                if (child != null) ...[
                  const SizedBox(height: 16),
                  child!,
                ],
              ],
            ),
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

/// A rounded icon button styled for the header (white background).
class HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color? iconColor;

  const HeaderIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Tooltip(
          message: tooltip ?? '',
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Icon(
              icon,
              size: 22,
              color: iconColor ?? Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

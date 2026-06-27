import 'package:flutter/material.dart';
import 'package:global_language_distribution_map/app/router.dart';
import 'package:global_language_distribution_map/app/theme.dart';
import 'package:global_language_distribution_map/core/widgets/curved_header.dart';
import 'package:global_language_distribution_map/features/settings/presentation/view_models/settings_view_model.dart';
import 'package:global_language_distribution_map/data/services/liquid_galaxy_service.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Redesigned Settings Screen.
///
/// Features a dark-green curved header, Liquid Galaxy connection config
/// with status badge, display switches, marker size slider, and an "About" link.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _hostController;
  late final TextEditingController _portController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<SettingsViewModel>();
    _hostController = TextEditingController(text: viewModel.host);
    _portController = TextEditingController(text: viewModel.port);
    _usernameController = TextEditingController(text: viewModel.username);
    _passwordController = TextEditingController(text: viewModel.password);
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Color _getStatusColor(LgConnectionStatus status) {
    switch (status) {
      case LgConnectionStatus.connected:
        return AppTheme.primaryGreen;
      case LgConnectionStatus.connecting:
        return Colors.orange;
      case LgConnectionStatus.error:
        return Colors.red;
      case LgConnectionStatus.disconnected:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final viewModel = context.watch<SettingsViewModel>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Curved Header
            CurvedHeader(
              overline: 'System Configuration',
              title: 'Settings',
              height: 140,
              actions: [
                HeaderIconButton(
                  icon: viewModel.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  onPressed: () => viewModel.toggleTheme(),
                  tooltip: 'Toggle Theme',
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Liquid Galaxy Connection ────────────────────────
                  _buildSectionTitle(context, 'Liquid Galaxy Connection'),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    color: colorScheme.surfaceContainerLow,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status Row
                          Row(
                            children: [
                              Text(
                                'LG Connection Status',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(viewModel.connectionStatus).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getStatusColor(viewModel.connectionStatus).withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  viewModel.connectionStatusText.toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: _getStatusColor(viewModel.connectionStatus),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // IP Address Field
                          TextField(
                            controller: _hostController,
                            onChanged: viewModel.setHost,
                            style: GoogleFonts.inter(fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'IP/Host Address',
                              labelStyle: GoogleFonts.inter(fontSize: 13),
                              hintText: 'e.g. 192.168.1.100',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.computer_rounded, size: 20),
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Port Field
                          TextField(
                            controller: _portController,
                            onChanged: viewModel.setPort,
                            style: GoogleFonts.inter(fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'SSH Port',
                              labelStyle: GoogleFonts.inter(fontSize: 13),
                              hintText: 'e.g. 22',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.input_rounded, size: 20),
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 12),

                          // Username Field
                          TextField(
                            controller: _usernameController,
                            onChanged: viewModel.setUsername,
                            style: GoogleFonts.inter(fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'SSH Username',
                              labelStyle: GoogleFonts.inter(fontSize: 13),
                              hintText: 'e.g. lg',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.person_rounded, size: 20),
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Password Field
                          TextField(
                            controller: _passwordController,
                            onChanged: viewModel.setPassword,
                            obscureText: true,
                            style: GoogleFonts.inter(fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'SSH Password',
                              labelStyle: GoogleFonts.inter(fontSize: 13),
                              hintText: 'Required',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.lock_rounded, size: 20),
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Connection Buttons Row
                          Row(
                            children: [
                              if (viewModel.isConnected)
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: viewModel.disconnect,
                                    icon: const Icon(Icons.power_off_rounded, size: 18),
                                    label: Text(
                                      'Disconnect',
                                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                )
                              else
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: viewModel.isConnecting
                                        ? null
                                        : () => viewModel.testConnection(),
                                    icon: viewModel.isConnecting
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(Icons.network_check_rounded, size: 18),
                                    label: Text(
                                      viewModel.isConnecting ? 'Connecting...' : 'Connect to LG',
                                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryGreen,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          if (viewModel.connectionError != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              viewModel.connectionError!,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ─── Liquid Galaxy Actions ───────────────────────────
                  if (viewModel.isConnected) ...[
                    _buildSectionTitle(context, 'Liquid Galaxy Actions'),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      color: colorScheme.surfaceContainerLow,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      final success = await viewModel.clearKml();
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              success
                                                  ? 'KML cleared on Liquid Galaxy'
                                                  : 'Failed to clear KML',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.clear_all_rounded, size: 18),
                                    label: Text(
                                      'Clear KML',
                                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      // Get a list of map languages to send as demo KML
                                      // Wait, we can get them from context or send a simple message
                                      final success = await viewModel.sendKml('');
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              success
                                                  ? 'KML sent to Liquid Galaxy'
                                                  : 'Failed to send KML',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.send_rounded, size: 18),
                                    label: Text(
                                      'Send Demo KML',
                                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      final success = await viewModel.relaunchGoogleEarth();
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              success
                                                  ? 'Relaunching Google Earth...'
                                                  : 'Failed to relaunch Google Earth',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.restart_alt_rounded, size: 18),
                                    label: Text(
                                      'Relaunch GE',
                                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Reboot Liquid Galaxy?'),
                                          content: const Text('Are you sure you want to reboot all LG screens?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, true),
                                              child: const Text('Reboot', style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        final success = await viewModel.reboot();
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                success
                                                    ? 'Rebooting Liquid Galaxy...'
                                                    : 'Failed to send reboot command',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    icon: const Icon(Icons.power_settings_new_rounded, size: 18),
                                    label: Text(
                                      'Reboot LG',
                                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ─── Display Settings ────────────────────────────────
                  _buildSectionTitle(context, 'Display Settings'),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    color: colorScheme.surfaceContainerLow,
                    child: Column(
                      children: [
                        SwitchListTile(
                          value: viewModel.darkMapTheme,
                          onChanged: (_) => viewModel.toggleDarkMapTheme(),
                          title: Text(
                            'Dark Map Theme',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Apply dark mode tiles to map screens',
                            style: GoogleFonts.inter(fontSize: 12),
                          ),
                          activeColor: AppTheme.primaryGreen,
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          value: viewModel.showLanguageMarkers,
                          onChanged: (_) => viewModel.toggleShowLanguageMarkers(),
                          title: Text(
                            'Show Language Markers',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Toggle clustering dots on the map',
                            style: GoogleFonts.inter(fontSize: 12),
                          ),
                          activeColor: AppTheme.primaryGreen,
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          value: viewModel.autoFlyOnSelect,
                          onChanged: (_) => viewModel.toggleAutoFlyOnSelect(),
                          title: Text(
                            'Auto-Fly on Select',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Automatically fly LG to language coordinates',
                            style: GoogleFonts.inter(fontSize: 12),
                          ),
                          activeColor: AppTheme.primaryGreen,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ─── Marker Size ───────────────────────────────────
                  _buildSectionTitle(context, 'Marker Size'),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    color: colorScheme.surfaceContainerLow,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Adjust the size of language markers on the map.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                'Scale Multiplier',
                                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              const Spacer(),
                              Text(
                                '${viewModel.markerSize.toStringAsFixed(1)}x',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                          Slider.adaptive(
                            value: viewModel.markerSize,
                            min: 0.5,
                            max: 2.5,
                            divisions: 20,
                            activeColor: AppTheme.primaryGreen,
                            onChanged: viewModel.setMarkerSize,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // About Section Link
                  InkWell(
                    onTap: () => context.push(RoutePaths.about),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: colorScheme.primary),
                          const SizedBox(width: 12),
                          Text(
                            'About App',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: colorScheme.onSurfaceVariant),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: colorScheme.onSurfaceVariant,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:global_language_distribution_map/app/router.dart';
import 'package:global_language_distribution_map/app/theme.dart';
import 'package:global_language_distribution_map/core/widgets/curved_header.dart';
import 'package:global_language_distribution_map/features/settings/presentation/view_models/settings_view_model.dart';
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
  late final TextEditingController _ipController;
  late final TextEditingController _portController;

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<SettingsViewModel>();
    _ipController = TextEditingController(text: viewModel.ipAddress);
    _portController = TextEditingController(text: viewModel.port);
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
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
                            controller: _ipController,
                            onChanged: viewModel.setIpAddress,
                            style: GoogleFonts.inter(fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'IP Address',
                              labelStyle: GoogleFonts.inter(fontSize: 13),
                              hintText: 'e.g. 192.168.1.100',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.computer_rounded, size: 20),
                              isDense: true,
                            ),
                            keyboardType: TextInputType.values[0], // text input type fallback
                          ),
                          const SizedBox(height: 12),

                          // Port Field
                          TextField(
                            controller: _portController,
                            onChanged: viewModel.setPort,
                            style: GoogleFonts.inter(fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Port',
                              labelStyle: GoogleFonts.inter(fontSize: 13),
                              hintText: 'e.g. 2222',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.input_rounded, size: 20),
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
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
                                      viewModel.isConnecting ? 'Connecting...' : 'Test Connection',
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

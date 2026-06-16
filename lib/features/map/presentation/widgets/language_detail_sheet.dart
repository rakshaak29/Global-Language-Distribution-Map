import 'package:flutter/material.dart';
import 'package:global_language_distribution_map/app/theme.dart';
import 'package:global_language_distribution_map/data/models/language.dart';
import 'package:global_language_distribution_map/data/services/tts_service.dart';
import 'package:google_fonts/google_fonts.dart';

/// A compact flashcard that displays language info in the bottom-right corner.
///
/// Includes TTS (text-to-speech) that automatically reads out the language
/// details when displayed, with a button to replay or stop the audio.
class LanguageDetailSheet extends StatefulWidget {
  final Language language;
  final VoidCallback? onClose;
  final VoidCallback? onFlyTo;

  const LanguageDetailSheet({
    super.key,
    required this.language,
    this.onClose,
    this.onFlyTo,
  });

  @override
  State<LanguageDetailSheet> createState() => _LanguageDetailSheetState();
}

class _LanguageDetailSheetState extends State<LanguageDetailSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  final TtsService _tts = TtsService();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  Future<void> _speakLanguageInfo() async {
    final text = TtsService.buildLanguageDescription(
      name: widget.language.name,
      family: widget.language.languageFamily,
      endangeredStatus: widget.language.endangeredStatus,
      countryRegion: widget.language.countryRegion,
      latitude: widget.language.latitude,
      longitude: widget.language.longitude,
    );

    try {
      setState(() => _isSpeaking = true);
      await _tts.speak(text);

      // Poll briefly for completion since TTS callbacks may be async
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _isSpeaking = _tts.isSpeaking);
        }
      });
    } catch (_) {
      // Browser may block speech if no prior user gesture
      if (mounted) setState(() => _isSpeaking = false);
    }
  }

  Future<void> _toggleSpeech() async {
    if (_isSpeaking) {
      await _tts.stop();
      if (mounted) setState(() => _isSpeaking = false);
    } else {
      await _speakLanguageInfo();
    }
  }

  @override
  void dispose() {
    _tts.stop();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final endangermentColor =
        AppTheme.getEndangermentColor(widget.language.endangeredStatus);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: 290,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer.withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: name, family, close & TTS buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 6, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.language.name,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.language.languageFamily,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // TTS button
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: IconButton(
                        onPressed: _toggleSpeech,
                        padding: EdgeInsets.zero,
                        iconSize: 16,
                        icon: Icon(
                          _isSpeaking
                              ? Icons.volume_off_rounded
                              : Icons.volume_up_rounded,
                          color: _isSpeaking
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                        tooltip: _isSpeaking ? 'Stop reading' : 'Read aloud',
                        style: IconButton.styleFrom(
                          backgroundColor: _isSpeaking
                              ? colorScheme.primary.withValues(alpha: 0.1)
                              : colorScheme.surfaceContainerHigh,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Close button
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: IconButton(
                        onPressed: () {
                          _tts.stop();
                          widget.onClose?.call();
                        },
                        padding: EdgeInsets.zero,
                        iconSize: 16,
                        icon: Icon(
                          Icons.close_rounded,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.surfaceContainerHigh,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Status badge
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: endangermentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: endangermentColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: endangermentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.language.endangeredStatus.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: endangermentColor,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Compact info: Country & Coordinates
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Icon(Icons.public_rounded,
                        size: 14,
                        color: colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.5)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.language.countryRegion,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        size: 14,
                        color: colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.5)),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.language.latitude.toStringAsFixed(2)}, ${widget.language.longitude.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Action buttons row
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: ElevatedButton.icon(
                    onPressed: widget.onFlyTo,
                    icon: const Icon(Icons.flight_takeoff_rounded, size: 14),
                    label: Text(
                      'Fly To',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

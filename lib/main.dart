import 'package:flutter/material.dart';
import 'package:global_language_distribution_map/app/app.dart';
import 'package:global_language_distribution_map/core/di/locator.dart';
import 'package:global_language_distribution_map/data/repositories/language_repository.dart';
import 'package:global_language_distribution_map/data/services/liquid_galaxy_service.dart';
import 'package:global_language_distribution_map/data/services/gemini_service.dart';
import 'package:global_language_distribution_map/presentation/endangered/view_models/endangered_view_model.dart';
import 'package:global_language_distribution_map/presentation/families/view_models/families_view_model.dart';
import 'package:global_language_distribution_map/presentation/home/view_models/home_view_model.dart';
import 'package:global_language_distribution_map/presentation/kml_export/view_models/kml_export_view_model.dart';
import 'package:global_language_distribution_map/presentation/map/view_models/map_view_model.dart';
import 'package:global_language_distribution_map/presentation/settings/view_models/settings_view_model.dart';
import 'package:global_language_distribution_map/presentation/tours/view_models/tours_view_model.dart';
import 'package:global_language_distribution_map/presentation/heatmap/view_models/heatmap_view_model.dart';
import 'package:global_language_distribution_map/presentation/chat/view_models/chat_view_model.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  setupLocator();

  final languageRepository = locator<LanguageRepository>();

  // Load data eagerly so it's available regardless of which route
  // the browser lands on (e.g., after a page refresh on /home or /map).
  await languageRepository.loadData();

  runApp(
    MultiProvider(
      providers: [
        Provider<LanguageRepository>.value(
          value: languageRepository,
        ),
        ChangeNotifierProvider<SettingsViewModel>(
          create: (_) => SettingsViewModel(
            lgService: locator<LiquidGalaxyService>(),
          ),
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create: (_) => HomeViewModel(
            repository: locator<LanguageRepository>(),
          ),
        ),
        ChangeNotifierProvider<MapViewModel>(
          create: (_) => MapViewModel(
            repository: locator<LanguageRepository>(),
            lgService: locator<LiquidGalaxyService>(),
          ),
        ),
        ChangeNotifierProvider<KmlExportViewModel>(
          create: (_) => KmlExportViewModel(
            repository: locator<LanguageRepository>(),
          ),
        ),
        ChangeNotifierProvider<FamiliesViewModel>(
          create: (_) => FamiliesViewModel(
            repository: locator<LanguageRepository>(),
          ),
        ),
        ChangeNotifierProvider<ToursViewModel>(
          create: (_) => ToursViewModel(
            repository: locator<LanguageRepository>(),
            lgService: locator<LiquidGalaxyService>(),
          ),
        ),
        ChangeNotifierProvider<EndangeredViewModel>(
          create: (_) => EndangeredViewModel(
            repository: locator<LanguageRepository>(),
          ),
        ),
        ChangeNotifierProvider<HeatmapViewModel>(
          create: (_) => HeatmapViewModel(
            repository: locator<LanguageRepository>(),
          ),
        ),
        ChangeNotifierProvider<ChatViewModel>(
          create: (_) => ChatViewModel(
            repository: locator<LanguageRepository>(),
            geminiService: locator<GeminiService>(),
          ),
        ),
      ],
      child: const App(),
    ),
  );
}

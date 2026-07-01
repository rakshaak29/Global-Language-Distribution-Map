import 'package:get_it/get_it.dart';
import 'package:global_language_distribution_map/data/repositories/language_repository.dart';
import 'package:global_language_distribution_map/data/services/local_data_service.dart';
import 'package:global_language_distribution_map/data/services/liquid_galaxy_service.dart';
import 'package:global_language_distribution_map/data/services/gemini_service.dart';
import 'package:global_language_distribution_map/data/services/tts_service.dart';

final GetIt locator = GetIt.instance;

/// Set up dependency injection using GetIt.
void setupLocator() {
  // Services
  locator.registerLazySingleton<LocalDataService>(() => LocalDataService());
  locator.registerLazySingleton<LiquidGalaxyService>(() => LiquidGalaxyService());
  locator.registerLazySingleton<GeminiService>(() => GeminiService());
  locator.registerLazySingleton<TtsService>(() => TtsService());

  // Repositories (depends on LocalDataService)
  locator.registerLazySingleton<LanguageRepository>(() => LanguageRepository(
    dataService: locator<LocalDataService>(),
  ));
}


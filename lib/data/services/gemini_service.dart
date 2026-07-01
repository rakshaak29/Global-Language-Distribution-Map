import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:global_language_distribution_map/data/repositories/language_repository.dart';

/// Service for interfacing with the Gemini Pro API.
class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  /// Query the Gemini model with a user query, history context, and dataset statistics.
  Future<String> askQuestion({
    required String apiKey,
    required String userQuery,
    required List<Content> chatHistory,
    required LanguageRepository repo,
  }) async {
    if (apiKey.isEmpty) {
      return 'Please configure your Gemini API Key in the Settings tab to activate the AI Assistant.';
    }

    try {
      final systemPrompt = _buildSystemPrompt(repo);
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        systemInstruction: Content.system(systemPrompt),
      );

      // Create a chat session with the provided history
      final chat = model.startChat(history: chatHistory);
      final response = await chat.sendMessage(Content.text(userQuery));
      return response.text ?? 'No response received.';
    } catch (e) {
      return 'Error querying Gemini API: $e\n\nPlease check your API key and connection settings.';
    }
  }

  static String _buildSystemPrompt(LanguageRepository repo) {
    final all = repo.getAllLanguages();
    final mappableCount = repo.languagesWithCoordinates;

    // Group by family
    final familyCounts = <String, int>{};
    final endangermentCounts = <String, int>{};
    for (final lang in all) {
      familyCounts[lang.languageFamily] = (familyCounts[lang.languageFamily] ?? 0) + 1;
      endangermentCounts[lang.endangeredStatus] = (endangermentCounts[lang.endangeredStatus] ?? 0) + 1;
    }

    final sortedFamilies = familyCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topFamilies = sortedFamilies.take(6).map((e) => '${e.key} (${e.value} languages)').join(', ');
    final statusStats = endangermentCounts.entries.map((e) => '${e.key}: ${e.value}').join(', ');

    return '''
You are the Gemini AI Assistant for the Global Language Distribution Map application.
Your goal is to help users learn about global linguistic diversity, language families, endangered languages, and geographic hotspots.

Here is the current dataset profile:
- Total languages in dataset: ${all.length}
- Mappable languages (with coordinates): $mappableCount
- Language families: ${familyCounts.length} families. Top families: $topFamilies
- Endangerment statuses: $statusStats

Guidelines:
1. Answer queries about language facts, speaker counts, regions, families, and status.
2. Rely on the profile numbers above for broad dataset statistics.
3. Keep responses engaging, educational, and format them nicely with Markdown.
4. Keep answers relatively concise and easy to read.
5. If the user asks about app capabilities (like KML export, guided tours, or SSH connection), guide them to the appropriate screens (Map, Families, Tours, Settings).
''';
  }
}

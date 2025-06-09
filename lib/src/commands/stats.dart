import 'dart:convert';
import 'package:colorize/colorize.dart';
import 'package:http/http.dart' as http;

import '../accent_cli_base.dart';

/// Command to display statistics from Accent
class StatsCommand extends BaseCommand {
  @override
  final String name = 'stats';
  
  @override
  final String description = 'Fetch stats from the API and display it beautifully';

  @override
  Future<void> execute() async {
    print('');
    final statsText = Colorize('PROJECT STATISTICS').bold();
    print(statsText);
    print('');

    if (project == null) {
      throw Exception('Project not found');
    }

    final projectId = project!.id;
    final apiUrl = projectConfig.config.apiUrl;
    final apiKey = projectConfig.config.apiKey;

    try {
      final url = '$apiUrl/projects/$projectId/statistics';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch stats: ${response.statusCode}');
      }

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final stats = jsonResponse['data'] as Map<String, dynamic>? ?? {};
      
      _displayStats(stats);
    } catch (e) {
      throw Exception('Error fetching stats: $e');
    }
  }

  /// Displays the statistics in a formatted way
  void _displayStats(Map<String, dynamic> stats) {
    final projectName = Colorize('Project: ${project!.name}').green().bold();
    print(projectName);
    print('');

    // Display translation progress
    final translationProgress = stats['translation_progress'] as Map<String, dynamic>? ?? {};
    final totalStrings = translationProgress['total_strings'] ?? 0;
    final translatedStrings = translationProgress['translated_strings'] ?? 0;
    final reviewedStrings = translationProgress['reviewed_strings'] ?? 0;
    
    final progressPercent = totalStrings > 0 
        ? (translatedStrings / totalStrings * 100).toStringAsFixed(2) 
        : '0.00';
    
    print('Translation Progress: $progressPercent%');
    print('Total Strings: $totalStrings');
    print('Translated Strings: $translatedStrings');
    print('Reviewed Strings: $reviewedStrings');
    print('');

    // Display language statistics
    final languageStats = stats['languages'] as List<dynamic>? ?? [];
    
    if (languageStats.isNotEmpty) {
      final languagesHeader = Colorize('Languages:').bold();
      print(languagesHeader);
      
      for (final langStat in languageStats) {
        final lang = langStat as Map<String, dynamic>;
        final langName = lang['name'] ?? 'Unknown';
        final langCode = lang['code'] ?? '';
        final langProgress = lang['progress'] ?? 0.0;
        final langProgressPercent = (langProgress * 100).toStringAsFixed(2);
        
        print('• $langName ($langCode): $langProgressPercent%');
      }
    }
  }
}

import 'dart:convert';
import 'dart:io';

import '../types/config.dart';

/// Service to fetch and parse the accent.json configuration file
class ConfigFetcher {
  /// The parsed configuration
  late Config config;

  /// The path to the configuration file
  final String configPath;

  /// Creates a new ConfigFetcher
  ConfigFetcher({this.configPath = 'accent.json'}) {
    _parseConfig();
  }

  /// Parse the configuration file
  void _parseConfig() {
    try {
      final file = File(configPath);
      if (!file.existsSync()) {
        throw Exception('Config file not found: $configPath');
      }

      final content = file.readAsStringSync();
      final json = jsonDecode(content) as Map<String, dynamic>;
      
      config = Config.fromJson(json);
    } catch (e) {
      throw Exception('Failed to parse config file: $e');
    }
  }

  /// Get the list of file configurations
  List<FileConfig> files() {
    return config.files;
  }
}

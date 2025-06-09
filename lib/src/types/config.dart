import 'name_pattern.dart';

/// Configuration for the accent-cli
class Config {
  /// The URL of the Accent API
  final String apiUrl;
  
  /// The API key for authentication
  final String apiKey;
  
  /// The project ID
  final String projectId;
  
  /// The list of file configurations
  final List<FileConfig> files;

  const Config({
    required this.apiUrl,
    required this.apiKey,
    required this.projectId,
    required this.files,
  });

  /// Creates a Config from a JSON object
  factory Config.fromJson(Map<String, dynamic> json) {
    final filesList = (json['files'] as List?)
        ?.map((fileJson) => FileConfig.fromJson(fileJson))
        .toList() ?? [];

    return Config(
      apiUrl: json['apiUrl'] as String? ?? '',
      apiKey: json['apiKey'] as String? ?? '',
      projectId: json['project'] as String? ?? '',
      files: filesList,
    );
  }
}

/// Configuration for a file in the accent-cli
class FileConfig {
  /// The language of the file
  final String language;
  
  /// The format of the file
  final String format;
  
  /// The source path pattern for the file
  final String source;
  
  /// The target path pattern for the file
  final String target;
  
  /// The name pattern for document naming strategy
  final NamePattern namePattern;
  
  /// Hooks to run at specific points in the process
  final HooksConfig? hooks;

  const FileConfig({
    required this.language,
    required this.format,
    required this.source,
    required this.target,
    this.namePattern = NamePattern.fileName,
    this.hooks,
  });

  /// Creates a FileConfig from a JSON object
  factory FileConfig.fromJson(Map<String, dynamic> json) {
    return FileConfig(
      language: json['language'] as String? ?? '',
      format: json['format'] as String? ?? '',
      source: json['source'] as String? ?? '',
      target: json['target'] as String? ?? '',
      namePattern: NamePatternExtension.fromString(json['namePattern'] as String?),
      hooks: json.containsKey('hooks') ? HooksConfig.fromJson(json['hooks']) : null,
    );
  }
}

/// Configuration for hooks in the accent-cli
class HooksConfig {
  /// Command to run before sync
  final String? beforeSync;
  
  /// Command to run after sync
  final String? afterSync;
  
  /// Command to run before export
  final String? beforeExport;
  
  /// Command to run after export
  final String? afterExport;
  
  /// Command to run before add translations
  final String? beforeAddTranslations;
  
  /// Command to run after add translations
  final String? afterAddTranslations;

  const HooksConfig({
    this.beforeSync,
    this.afterSync,
    this.beforeExport,
    this.afterExport,
    this.beforeAddTranslations,
    this.afterAddTranslations,
  });

  /// Creates a HooksConfig from a JSON object
  factory HooksConfig.fromJson(Map<String, dynamic> json) {
    return HooksConfig(
      beforeSync: json['beforeSync'] as String?,
      afterSync: json['afterSync'] as String?,
      beforeExport: json['beforeExport'] as String?,
      afterExport: json['afterExport'] as String?,
      beforeAddTranslations: json['beforeAddTranslations'] as String?,
      afterAddTranslations: json['afterAddTranslations'] as String?,
    );
  }
}

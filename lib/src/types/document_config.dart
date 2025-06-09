/// Enum representing available hook types
enum Hook {
  beforeSync,
  afterSync,
  beforeExport, 
  afterExport,
  beforeAddTranslations,
  afterAddTranslations,
}

/// Extension on Hook enum to provide string conversion
extension HookExtension on Hook {
  String get name {
    switch (this) {
      case Hook.beforeSync:
        return 'beforeSync';
      case Hook.afterSync:
        return 'afterSync';
      case Hook.beforeExport:
        return 'beforeExport';
      case Hook.afterExport:
        return 'afterExport';
      case Hook.beforeAddTranslations:
        return 'beforeAddTranslations';
      case Hook.afterAddTranslations:
        return 'afterAddTranslations';
    }
  }
}

/// Class representing a document path target
class DocumentPathTarget {
  /// The file path
  final String path;
  
  /// The language of the document
  final String language;
  
  /// The path in the Accent document structure
  final String documentPath;

  const DocumentPathTarget({
    required this.path,
    required this.language,
    required this.documentPath,
  });
}

/// Class representing operations that can be performed on documents
class DocumentOperations {
  /// Sync operation result
  final dynamic sync;
  
  /// Peek operation result
  final dynamic peek;
  
  /// Add translations operation result
  final dynamic addTranslations;

  const DocumentOperations({
    this.sync,
    this.peek,
    this.addTranslations,
  });
}

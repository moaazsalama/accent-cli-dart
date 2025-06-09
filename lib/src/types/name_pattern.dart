/// Enum representing different name pattern options for document naming
enum NamePattern {
  /// Use the parent directory name
  parentDirectory,
  
  /// Use the file name with parent directory
  fileWithParentDirectory,
  
  /// Use the file name with slug suffix
  fileWithSlugSuffix,
  
  /// Use the file name only
  fileName
}

/// Extension on NamePattern enum to provide string conversion
extension NamePatternExtension on NamePattern {
  /// Get the string representation of the NamePattern
  String get value {
    switch (this) {
      case NamePattern.parentDirectory:
        return 'parentDirectory';
      case NamePattern.fileWithParentDirectory:
        return 'fileWithParentDirectory';
      case NamePattern.fileWithSlugSuffix:
        return 'fileWithSlugSuffix';
      case NamePattern.fileName:
        return 'fileName';
    }
  }
  
  /// Create NamePattern from string
  static NamePattern fromString(String? value) {
    if (value == null) {
      return NamePattern.fileName; // Default value
    }
    
    switch (value) {
      case 'parentDirectory':
        return NamePattern.parentDirectory;
      case 'fileWithParentDirectory':
        return NamePattern.fileWithParentDirectory;
      case 'fileWithSlugSuffix':
        return NamePattern.fileWithSlugSuffix;
      default:
        return NamePattern.fileName;
    }
  }
}

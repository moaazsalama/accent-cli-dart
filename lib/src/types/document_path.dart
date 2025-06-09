/// Represents a document path with language and target path information
class DocumentPath {
  /// The original document path
  final String documentPath;
  
  /// The target path where the document will be exported
  final String path;
  
  /// The language slug
  final String language;

  /// Creates a new DocumentPath
  const DocumentPath({
    required this.documentPath,
    required this.path,
    required this.language,
  });
}

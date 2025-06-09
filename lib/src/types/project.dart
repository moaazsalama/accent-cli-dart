/// Represents a language in Accent
class Language {
  /// The unique identifier of the language
  final String id;
  
  /// The name of the language
  final String name;
  
  /// The slug of the language
  final String slug;

  const Language({
    required this.id,
    required this.name,
    required this.slug,
  });

  /// Creates a Language from a JSON object
  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );
  }
}

/// Represents a revision in Accent
class Revision {
  /// The unique identifier of the revision
  final String id;
  
  /// The name of the revision
  final String name;
  
  /// The slug of the revision
  final String slug;
  
  /// The language of the revision
  final Language language;

  const Revision({
    required this.id,
    required this.name,
    required this.slug,
    required this.language,
  });

  /// Creates a Revision from a JSON object
  factory Revision.fromJson(Map<String, dynamic> json) {
    return Revision(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      language: Language.fromJson(json['language'] as Map<String, dynamic>),
    );
  }
}

/// Represents a version in Accent
class Version {
  /// The unique identifier of the version
  final String id;
  
  /// The tag of the version
  final String tag;

  const Version({
    required this.id,
    required this.tag,
  });

  /// Creates a Version from a JSON object
  factory Version.fromJson(Map<String, dynamic> json) {
    return Version(
      id: json['id'] as String? ?? '',
      tag: json['tag'] as String? ?? '',
    );
  }
}

/// Represents a project in Accent
class Project {
  /// The unique identifier of the project
  final String id;
  
  /// The name of the project
  final String name;
  
  /// The list of documents in the project
  final List<DocumentEntity> documents;

  /// The list of revisions in the project
  final List<Revision>? revisions;

  /// The list of versions in the project
  final List<Version>? versions;

  const Project({
    required this.id,
    required this.name,
    required this.documents,
    this.revisions,
    this.versions,
  });

  /// Creates a Project from a JSON object
  factory Project.fromJson(Map<String, dynamic> json) {
    final documentsList = (json['documents']['entries'] as List?)
        ?.map((doc) => DocumentEntity.fromJson(doc))
        .toList() ?? [];
    
    final revisionsList = (json['revisions'] as List?)
        ?.map((rev) => Revision.fromJson(rev as Map<String, dynamic>))
        .toList();
    
    final versionsList = (json['versions']?['entries'] as List?)
        ?.map((ver) => Version.fromJson(ver as Map<String, dynamic>))
        .toList();

    return Project(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      documents: documentsList,
      revisions: revisionsList,
      versions: versionsList,
    );
  }
}

/// Represents a document in an Accent project
class DocumentEntity {
  /// The unique identifier of the document
  final String id;
  
  /// The path of the document
  final String path;
  
  /// The format of the document
  final String format;
  
  /// The language of the document
  final String language;
  
  /// The name of the document
  final String name;

  const DocumentEntity({
    required this.id,
    required this.path,
    required this.format,
    required this.language,
    required this.name,
  });

  /// Creates a Document from a JSON object
  factory DocumentEntity.fromJson(Map<String, dynamic> json) {
    // Extract language from path if language field is not present
    // In many Accent implementations, the path often represents the language code
    String language = '';
    
    // Try to get language directly if it exists
    if (json['language'] != null && json['language'] is String) {
      language = json['language'] as String;
    }
    // Otherwise, use the path as a fallback since it often contains the language code
    else if (json['path'] != null && json['path'] is String) {
      language = json['path'] as String;
    }
    
    print('Parsed document: id=${json['id']}, path=${json['path']}, language=$language');
    
    return DocumentEntity(
      id: json['id'] as String? ?? '',
      path: json['path'] as String? ?? '',
      format: json['format'] as String? ?? '',
      language: language,
      name: json['name'] as String? ?? '',
    );
  }
}

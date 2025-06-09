import '../types/project.dart';

/// Fetches language slugs from revisions
List<String> fetchFromRevisions(List<Revision>? revisions) {
  if (revisions == null || revisions.isEmpty) {
    return [];
  }
  
  // Extract the language slugs from revisions
  return revisions.map((revision) => revision.language.slug).toList();
}

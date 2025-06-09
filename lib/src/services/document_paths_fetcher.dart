import 'dart:io';
import 'package:path/path.dart' as path;
import 'dart:core';

import '../types/document_path.dart';
import '../types/config.dart';
import '../types/project.dart';
import '../types/name_pattern.dart';
import 'revision_slug_fetcher.dart';

/// Service to fetch document paths for a project
class DocumentPathsFetcher {
  /// Fetches document paths for a project
  List<DocumentPath> fetch(Project project, FileConfig fileConfig) {
    // Get language slugs from project revisions
    final languageSlugs = fetchFromRevisions(project.revisions);
    // Create a set to store the document paths
    final documentPaths = <String>{};
    
    print('Fetching document paths using revisions');
    
    // Parse document names from paths and add them to the set
    for (final doc in project.documents) {
      final name = _parseDocumentName(doc.path, fileConfig);
      documentPaths.add(name);
      print('Added document path: $name');
    }
    
    // Process each language slug and document path
    final result = <DocumentPath>[];
    
    for (final slug in languageSlugs) {
      for (final documentPath in documentPaths) {
        // Replace placeholders in the target pattern
        final parsedTarget = fileConfig.target
          .replaceAll('%slug%', slug)
          .replaceAll('%original_file_name%', documentPath)
          .replaceAll('%document_path%', documentPath);
        
        // Check if this target path is already in the result
        bool alreadyExists = false;
        for (final item in result) {
          if (item.path == parsedTarget) {
            alreadyExists = true;
            break;
          }
        }
        
        // If not already in the result, add it
        if (!alreadyExists) {
          print('Creating document path: document=$documentPath, target=$parsedTarget, language=$slug');
          
          // Ensure directory exists
          final directory = Directory(path.dirname(parsedTarget));
          if (!directory.existsSync()) {
            directory.createSync(recursive: true);
            print('Created directory: ${directory.path}');
          }
          
          result.add(DocumentPath(
            documentPath: documentPath,
            path: parsedTarget,
            language: slug,
          ));
        }
      }
    }
    
    return result;
  }
  
  /// Extracts the document name from its path based on the configuration
  String _parseDocumentName(String file, FileConfig config) {
    if (config.namePattern == NamePattern.parentDirectory) {
      // Match a pattern like 'word/' or 'word/word/' at the beginning of target
      final RegExp targetPrefixPattern = RegExp(r'(\w+\/)+');
      final targetPrefixMatch = targetPrefixPattern.firstMatch(config.target);

      if (targetPrefixMatch != null) {
        return path.dirname(file).replaceFirst(targetPrefixMatch.group(0)!, '');
      } else {
        return path.dirname(file);
      }
    }

    final basename = path.basenameWithoutExtension(file);

    if (config.namePattern == NamePattern.fileWithParentDirectory) {
      // Find the index of %slug% in the target path parts and add 1
      final languageIndex = config.target.split(path.separator).indexOf('%slug%') + 1;
      final pathParts = file.split(path.separator);
      
      // Extract the relevant path parts
      final resultPath = pathParts.sublist(
        languageIndex,
        pathParts.length - 1 // Exclude the filename at the end
      );
      
      return resultPath.isNotEmpty
          ? '${resultPath.join(path.separator)}${path.separator}$basename'
          : basename;
    }

    if (config.namePattern == NamePattern.fileWithSlugSuffix) {
      return basename.split('.')[0];
    }

    return basename;
  }
}

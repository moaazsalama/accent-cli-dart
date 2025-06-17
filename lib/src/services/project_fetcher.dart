import 'dart:convert';
// import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:colorize/colorize.dart';

import '../types/config.dart';
import '../types/project.dart';

/// Service to fetch project data from the Accent API using GraphQL
class ProjectFetcher {
  /// Fetches the project data from the Accent API
  Future<Project> fetch(Config config) async {
    final response = await _graphql(config);

    try {
      final data = jsonDecode(response.data.toString());

      if (data['data'] == null) {
        final errorMessage =
            'Can not find the project for the key: ${config.apiKey}';
        final coloredMessage = Colorize(errorMessage)..red();
        throw Exception(coloredMessage.toString());
      }
      // Extract the project data from the GraphQL response
      final projectData = data['data']['viewer']['project'];
      print(projectData);
      return Project.fromJson(projectData);
    } catch (e) {
      print(e);
      final errorMessage = 'Can not fetch the project on ${config.apiUrl}';
      throw Exception(errorMessage);
    }
  }

  /// Make a GraphQL request to the Accent API
  Future<Response> _graphql(Config config) async {
    final query = '''
      query ProjectDetails(\$project_id: ID!) {
        viewer {
          project(id: \$project_id) {
            id
            name
            lastSyncedAt

            masterRevision: revision {
              id
              name
              slug

              language {
                id
                name
                slug
              }
            }

            documents(pageSize: 1000) {
              meta {
                totalEntries
              }
              entries {
                id
                path
                format
              }
            }

            revisions {
              id
              isMaster
              translationsCount
              conflictsCount
              reviewedCount
              name
              slug
              language {
                id
                name
                slug
              }
            }
          }
        }
      }
    ''';

    // Extract project ID from the API key or config
    // For Accent, we need the project ID to query the data
    String projectId = '1'; // Default project ID

    // Try to extract project ID from API key or URL parameters if available
    projectId = config.projectId;

    // Log what we're using
    print('Using project ID: $projectId');

    final Map<String, dynamic> variables = {'project_id': projectId};
    var dio = Dio();
    final response = await dio.post(
      ' ${config.apiUrl}/graphql',options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${config.apiKey}',
        },
      ),
     
      data: jsonEncode({
        'query': query,
        'variables': variables,
      }),
    );

    return response;
  }
}

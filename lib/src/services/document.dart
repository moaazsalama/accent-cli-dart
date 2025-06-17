import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import '../types/config.dart';
import '../types/document_config.dart';

/// Service to manage document operations
class Document {
  /// The file configuration for this document
  final FileConfig config;

  /// The API URL
  final String apiUrl;

  /// The API key
  final String apiKey;

  /// The list of file paths matching the source pattern
  List<String> paths = [];

  /// Creates a new Document instance
  Document({
    required this.config,
    required this.apiUrl,
    required this.apiKey,
  }) {
    _findSourcePaths();
  }

  /// Finds all file paths matching the source pattern
  void _findSourcePaths() {
    try {
      final glob = Glob(config.source);
      paths = glob.listSync().map((entity) => entity.path).toList();
    } catch (e) {
      throw Exception('Error finding source paths: $e');
    }
  }

  /// Syncs the document with the Accent API
  Future<DocumentOperations> sync(
      String filePath, Map<String, dynamic> flags) async {
    try {
      print('Starting sync for file: $filePath');
      final file = File(filePath);
      if (!file.existsSync()) {
        throw Exception('File not found: $filePath');
      }

      final fileContent = file.readAsStringSync();
      print('File content length: ${fileContent.length} bytes');
      final syncType = flags['sync-type'] ?? 'smart';
      print('Using sync_type: $syncType');

      final url = '$apiUrl/sync';
      print('Sending request to: $url');

      final request = http.MultipartRequest('POST', Uri.parse(url))
        ..headers.addAll({
          'Authorization': 'Bearer $apiKey',
          'Accept': 'application/json',
        })
        ..fields['sync_type'] = syncType
        ..fields['document_format'] = config.format
        ..fields['language'] = config.language;

      print('Request fields: ${request.fields}');

      // Add the file
      request.files.add(
        http.MultipartFile.fromString(
          'file', // File field name
          fileContent,
          filename: path.basename(filePath),
        ),
      );

      print('Sending request with ${request.files.length} files');
      final response = await request.send();
      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');

      final responseData = await response.stream.bytesToString();
      print('Response data: $responseData');

      // Try to parse the response data if it's not empty
      Map<String, dynamic> jsonResponse;
      try {
        jsonResponse = responseData.isEmpty
            ? {}
            : jsonDecode(responseData) as Map<String, dynamic>;
      } catch (parseError) {
        throw Exception(
            'Failed to parse response: $parseError\nResponse was: $responseData');
      }

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to sync: ${response.statusCode} - ${jsonResponse['error'] ?? 'Unknown error'}');
      }

      return DocumentOperations(
        sync: jsonResponse['data'],
        peek: jsonResponse['meta']?['peek'],
      );
    } catch (e) {
      print('Sync error: $e');
      throw Exception('Error syncing document: $e');
    }
  }

  /// Adds translations to the document in Accent
  Future<DocumentOperations> addTranslations(
    String filePath,
    String language,
    String documentPath,
    Map<String, dynamic> flags,
  ) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        throw Exception('File not found: $filePath');
      }

      final fileContent = file.readAsStringSync();
      final mergeType = flags['merge-type'] ?? 'smart';

      final url = '$apiUrl/add-translations';
      final request = http.MultipartRequest('POST', Uri.parse(url))
        ..headers.addAll({
          'Authorization': 'Bearer $apiKey',
        })
        ..fields['merge_type'] = mergeType
        ..fields['document_path'] = documentPath
        ..fields['document_format'] = config.format
        ..fields['language'] = language
        ..files.add(
          http.MultipartFile.fromString(
            'file', // Changed from 'document' to 'file'
            fileContent,
            filename: path.basename(filePath),
          ),
        );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseData) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        throw Exception('Failed to add translations: ${response.statusCode}');
      }

      return DocumentOperations(
        addTranslations: jsonResponse['data'],
        peek: jsonResponse['meta']?['peek'],
      );
    } catch (e) {
      throw Exception('Error adding translations: $e');
    }
  }

  /// Exports the document from Accent
  Future<void> export(
    String targetPath,
    String language,
    String documentPath,
    Map<String, dynamic> flags,
    String projectId,
  ) async {
    try {
      print('\nExporting document:');
      print('- Target path: $targetPath');
      print('- Language: $language');
      print('- Document path: $documentPath');
      print('- Format: ${config.format}');

      final orderBy = flags['order-by'] ?? 'index';
      print('- Order by: $orderBy');

      // Make sure target path has a valid filename
      if (path.basename(targetPath).isEmpty ||
          path.basename(targetPath) == '.json') {
        targetPath = path.join(path.dirname(targetPath), '$language.json');
        print('Fixed target path to: $targetPath');
      }

      final url = '$apiUrl/export';
      print('Sending request to: $url');

      final queryParams = {
        'project_id': projectId,
        'inline_render': "true",
        if (documentPath.isNotEmpty) 'document_path': documentPath,
        if (language.isNotEmpty) 'language': language,
        if (orderBy.isNotEmpty) 'order_by': orderBy,
        if (config.format.isNotEmpty) 'document_format': config.format,
      };
      print('Query parameters: $queryParams');
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      print('Final URL: $uri');

      var dio = Dio();
      final response = await dio.get(url, queryParameters: queryParams,
      options: Options(
              headers: {
                'Authorization': 'Bearer $apiKey',
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
      )
         
          );
      //print cURL
      // print(response.request?.headers);
      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      // print(
          // 'Response body preview: ${response.body.length > 100 ? response.body.substring(0, 100) + '...' : response.body}');

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to export: ${response.statusCode}\nResponse: ${response.data}');
      }

      // Ensure the directory exists
      final directory = Directory(path.dirname(targetPath));
      if (!directory.existsSync()) {
        print('Creating directory: ${directory.path}');
        directory.createSync(recursive: true);
      }

      // Write the content to the target file
      print('Writing content to file: $targetPath');
      final file = File(targetPath);
      await file.writeAsString(response.data.toString());
      print('Successfully exported to: $targetPath');
    } catch (e) {
      print('Export error: $e');
      throw Exception('Error exporting document: $e');
    }
  }
}

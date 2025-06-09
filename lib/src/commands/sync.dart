import 'dart:io';
import 'package:colorize/colorize.dart';

import '../accent_cli_base.dart';
import '../services/document.dart';
import '../services/document_paths_fetcher.dart';
import '../services/hook_runner.dart';
import '../types/document_config.dart';

/// Command to sync files with Accent
class SyncCommand extends BaseCommand {
  @override
  final String name = 'sync';
  
  @override
  final String description = 'Sync files in Accent and write them to your local filesystem';

  bool _addTranslations = false;
  String _mergeType = 'smart';
  String _orderBy = 'index';
  String _syncType = 'smart';
  bool _write = false;

  SyncCommand() {
    argParser.addFlag(
      'add-translations',
      help: 'Add translations in Accent to help translators if you already have translated strings',
      negatable: false,
    );
    
    argParser.addOption(
      'merge-type',
      help: 'Will be used in the add translations call as the "merge_type" param',
      allowed: ['smart', 'passive', 'force'],
      defaultsTo: 'smart',
    );
    
    argParser.addOption(
      'order-by',
      help: 'Will be used in the export call as the order of the keys',
      allowed: ['index', 'key-asc'],
      defaultsTo: 'index',
    );
    
    argParser.addOption(
      'sync-type',
      help: 'Will be used in the sync call as the "sync_type" param',
      allowed: ['smart', 'passive'],
      defaultsTo: 'smart',
    );
    
    argParser.addFlag(
      'write',
      help: 'Write the file from the export _after_ the operation',
      negatable: false,
    );
  }

  @override
  Future<void> execute() async {
    _addTranslations = argResults?['add-translations'] ?? false;
    _mergeType = argResults?['merge-type'] ?? 'smart';
    _orderBy = argResults?['order-by'] ?? 'index';
    _syncType = argResults?['sync-type'] ?? 'smart';
    _write = argResults?['write'] ?? false;

    final documents = projectConfig.files().map((fileConfig) {
      return Document(
        config: fileConfig,
        apiUrl: projectConfig.config.apiUrl,
        apiKey: projectConfig.config.apiKey,
      );
    }).toList();

    // Sync files
    print('');
    final syncText = Colorize('SYNC FILES').bold();
    print(syncText);
    print('');

    for (final document in documents) {
      await new HookRunner(document.config).run(Hook.beforeSync);
      
      await Future.wait(
        _syncDocumentConfig(document),
      );
      
      await new HookRunner(document.config).run(Hook.afterSync);
    }

    // Add translations if requested
    if (_addTranslations) {
      print('');
      final addTranslationsText = Colorize('ADD TRANSLATIONS').bold();
      print(addTranslationsText);
      print('');

      for (final document in documents) {
        await new HookRunner(document.config).run(Hook.beforeAddTranslations);
        
        await Future.wait(
          _addTranslationsDocumentConfig(document),
        );
        
        await new HookRunner(document.config).run(Hook.afterAddTranslations);
      }
    }

    // Export files if write flag is set
    if (!_write) return;
    
    // Refresh project data before export
    await refreshProject();
    
    print('');
    final exportText = Colorize('EXPORT FILES').bold();
    print(exportText);
    print('');

    for (final document in documents) {
      await new HookRunner(document.config).run(Hook.beforeExport);
      
      final targets = new DocumentPathsFetcher().fetch(project!, document.config);
      
      await Future.wait(
        targets.map((target) async {
          final pathText = Colorize('• ${target.path}').white();
          print(pathText);
          
          await document.export(
            target.path,
            target.language,
            target.documentPath,
            {'order-by': _orderBy},
            project!.id,
          );
        }),
      );
      
      await new HookRunner(document.config).run(Hook.afterExport);
    }
  }

  /// Sync document configuration
  List<Future<DocumentOperations>> _syncDocumentConfig(Document document) {
    final flags = {
      'sync-type': _syncType,
    };

    return document.paths.map((path) async {
      final operations = await document.sync(path, flags);
      
      if (operations.sync != null && operations.peek == null) {
        final syncText = Colorize('• $path').green();
        print(syncText);
      }
      
      if (operations.peek != null) {
        final peekText = Colorize('• $path').yellow();
        print(peekText);
        print('  ${operations.peek} conflicts detected');
      }
      
      return operations;
    }).toList();
  }

  /// Add translations to document configuration
  List<Future<DocumentOperations>> _addTranslationsDocumentConfig(Document document) {
    final flags = {
      'merge-type': _mergeType,
    };

    final targets = new DocumentPathsFetcher()
        .fetch(project!, document.config)
        .where((target) => target.language != document.config.language)
        .where((target) => File(target.path).existsSync())
        .toList();

    return targets.map((target) async {
      final operations = await document.addTranslations(
        target.path,
        target.language,
        target.documentPath,
        flags,
      );
      
      if (operations.addTranslations != null && operations.peek == null) {
        final addText = Colorize('• ${target.path}').green();
        print(addText);
      }
      
      if (operations.peek != null) {
        final peekText = Colorize('• ${target.path}').yellow();
        print(peekText);
        print('  ${operations.peek} conflicts detected');
      }
      
      return operations;
    }).toList();
  }
}

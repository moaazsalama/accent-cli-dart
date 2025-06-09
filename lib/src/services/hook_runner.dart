import 'dart:io';

import '../types/config.dart';
import '../types/document_config.dart';

/// Service to run hooks defined in the configuration
class HookRunner {
  /// The file configuration containing the hooks
  final FileConfig fileConfig;

  /// Creates a new HookRunner
  HookRunner(this.fileConfig);

  /// Runs a hook if it exists in the configuration
  Future<void> run(Hook hook) async {
    final hookCommand = _getHookCommand(hook);
    
    if (hookCommand != null && hookCommand.isNotEmpty) {
      try {
        print('Running hook: ${hook.name}');
        
        final process = await Process.start(
          'sh',
          ['-c', hookCommand],
          runInShell: true,
          mode: ProcessStartMode.inheritStdio,
        );
        
        final exitCode = await process.exitCode;
        
        if (exitCode != 0) {
          print('Hook ${hook.name} failed with exit code $exitCode');
        }
      } catch (e) {
        print('Error running hook ${hook.name}: $e');
      }
    }
  }

  /// Gets the command for a specific hook
  String? _getHookCommand(Hook hook) {
    if (fileConfig.hooks == null) return null;
    
    switch (hook) {
      case Hook.beforeSync:
        return fileConfig.hooks!.beforeSync;
      case Hook.afterSync:
        return fileConfig.hooks!.afterSync;
      case Hook.beforeExport:
        return fileConfig.hooks!.beforeExport;
      case Hook.afterExport:
        return fileConfig.hooks!.afterExport;
      case Hook.beforeAddTranslations:
        return fileConfig.hooks!.beforeAddTranslations;
      case Hook.afterAddTranslations:
        return fileConfig.hooks!.afterAddTranslations;
    }
  }
}

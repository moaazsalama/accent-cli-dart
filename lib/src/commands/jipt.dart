import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:colorize/colorize.dart';

import '../accent_cli_base.dart';
import '../services/document.dart';
import '../services/document_paths_fetcher.dart';
import '../services/hook_runner.dart';
import '../types/document_config.dart';

/// Command to export JIPT (Just-in-place-translation) files from Accent
class JiptCommand extends BaseCommand {
  @override
  final String name = 'jipt';
  
  @override
  final String description = 'Export jipt files from Accent and write them to your local filesystem';

  JiptCommand() {
    argParser.addArgument(
      'pseudoLanguageName',
      help: 'The pseudo language for in-place-translation-editing',
    );
  }

  @override
  Future<void> execute() async {
    final pseudoLanguageName = argResults?.rest.isNotEmpty == true 
        ? argResults!.rest[0] 
        : null;
        
    if (pseudoLanguageName == null || pseudoLanguageName.isEmpty) {
      throw UsageException(
        'Missing required argument: pseudoLanguageName',
        usage,
      );
    }

    print('');
    final jiptText = Colorize('EXPORT JIPT FILES').bold();
    print(jiptText);
    print('');

    final documents = projectConfig.files().map((fileConfig) {
      return Document(
        config: fileConfig,
        apiUrl: projectConfig.config.apiUrl,
        apiKey: projectConfig.config.apiKey,
      );
    }).toList();

    for (final document in documents) {
      await new HookRunner(document.config).run(Hook.beforeExport);

      final targets = new DocumentPathsFetcher().fetch(project!, document.config)
          .where((target) => target.language == pseudoLanguageName)
          .toList();

      if (targets.isEmpty) {
        print('No targets found for pseudo language: $pseudoLanguageName');
        continue;
      }

      await Future.wait(
        targets.map((target) async {
          final pathText = Colorize('• ${target.path}').white();
          print(pathText);
          
          await document.export(
            target.path,
            target.language,
            target.documentPath,
            {'jipt': true},
            project!.id,
          );
        }),
      );

      await new HookRunner(document.config).run(Hook.afterExport);
    }
  }
}

/// Class representing command line arguments
class CommandArgument {
  final String name;
  final String help;
  final bool required;

  const CommandArgument(this.name, {this.help = '', this.required = false});
}

/// Extension on ArgParser to add argument support
extension ArgParserExtension on ArgParser {
  void addArgument(String name, {String help = '', bool required = false}) {
    // This is a placeholder since args package doesn't directly support positional arguments
    // They are accessed through rest in the CommandRunner
  }
}

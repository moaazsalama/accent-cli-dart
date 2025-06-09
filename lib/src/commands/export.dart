import 'package:accent_cli_dart/accent_cli_dart.dart';
import 'package:colorize/colorize.dart';

import '../accent_cli_base.dart';
import '../services/document.dart';
import '../services/document_paths_fetcher.dart';
import '../services/hook_runner.dart';
import '../types/document_config.dart';

/// Command to export files from Accent
class ExportCommand extends BaseCommand {
  @override
  final String name = 'export';
  Project? project;
  @override
  final String description =
      'Export files from Accent and write them to your local filesystem';

  String? _orderBy;

  ExportCommand({required this.project}) {
    argParser.addOption(
      'order-by',
      help: 'Will be used in the export call as the order of the keys',
      allowed: ['index', 'key-asc'],
      defaultsTo: 'index',
    );
  }

  @override
  Future<void> execute() async {
    _orderBy = argResults?['order-by'];

    print('');
    final exportText = Colorize('EXPORT FILES').bold();
    print(exportText);
    print('');

    final documents = projectConfig.files().map((fileConfig) {
      return Document(
        config: fileConfig,
        apiUrl: projectConfig.config.apiUrl,
        apiKey: projectConfig.config.apiKey,
      
        // projectId: project!.id,
      );
    }).toList();

    for (final document in documents) {
      await new HookRunner(document.config).run(Hook.beforeExport);

      final targets =
          new DocumentPathsFetcher().fetch(project!, document.config);

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
}

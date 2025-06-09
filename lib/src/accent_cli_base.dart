import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:colorize/colorize.dart';

import 'services/config.dart';
import 'services/project_fetcher.dart';
import 'types/project.dart';
import 'commands/export.dart';
import 'commands/jipt.dart';
import 'commands/stats.dart';
import 'commands/sync.dart';

/// Main class for the Accent CLI application
class AccentCli {
  late ConfigFetcher projectConfig;
  Project? project;
  
  AccentCli() {
    projectConfig = ConfigFetcher();
  }

  /// Runs the CLI with provided arguments
  Future<void> run(List<String> args) async {
    final runner = CommandRunner<void>(
      'accent',
      'Accent CLI for managing translations',
    )
      ..addCommand(ExportCommand(project: project))
      ..addCommand(JiptCommand())
      ..addCommand(StatsCommand())
      ..addCommand(SyncCommand());

    try {
      await runner.run(args);
    } catch (e) {
      print(e);
      exit(1);
    }
  }

  /// Initializes the CLI by loading the config and fetching the project
  Future<void> init() async {
    final config = projectConfig.config;
    if (config.apiUrl.isEmpty) {
      throw Exception('You must set an API url in your config');
    }
    if (config.apiKey.isEmpty) {
      throw Exception('You must set an API key in your config');
    }

    // Fetch project from the API
    final fetchText = Colorize('Fetch config').white();
    stdout.write('$fetchText... ');
    await Future.delayed(Duration(milliseconds: 1000));
    
    final fetcher = ProjectFetcher();
    project = await fetcher.fetch(config);
    
    final success = Colorize('✓').green();
    print(success);
    print('');
  }

  /// Refreshes the project data from the API
  Future<void> refreshProject() async {
    final config = projectConfig.config;
    final fetcher = ProjectFetcher();
    project = await fetcher.fetch(config);
  }
}

/// Base class for all Accent CLI commands
abstract class BaseCommand extends Command<void> {
  final ConfigFetcher projectConfig = ConfigFetcher();
  Project? project;

  @override
  Future<void> run() async {
    await init();
    await execute();
  }

  /// Initializes the command by loading config and fetching the project
  Future<void> init() async {
    final config = projectConfig.config;
    if (config.apiUrl.isEmpty) {
      throw Exception('You must set an API url in your config');
    }
    if (config.apiKey.isEmpty) {
      throw Exception('You must set an API key in your config');
    }

    // Fetch project from the API
    final fetchText = Colorize('Fetch config').white();
    stdout.write('$fetchText... ');
    await Future.delayed(Duration(milliseconds: 1000));
    
    final fetcher = ProjectFetcher();
    project = await fetcher.fetch(config);
    
    final success = Colorize('✓').green();
    print(success);
    print('');
  }

  /// Refreshes the project data from the API
  Future<void> refreshProject() async {
    final config = projectConfig.config;
    final fetcher = ProjectFetcher();
    project = await fetcher.fetch(config);
  }

  /// Executes the command logic (to be implemented by subclasses)
  Future<void> execute();
}

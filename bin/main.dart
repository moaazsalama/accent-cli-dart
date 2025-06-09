import 'dart:io';
import 'package:accent_cli_dart/accent_cli_dart.dart';

void main(List<String> arguments) async {
  final cli = AccentCli();
  print('Arguments: $arguments');
  
  // Use command-line arguments if provided, otherwise use stats command for testing
  
  
  try {
    print('Running command: $arguments');
    await cli.run([ ...arguments]);
  } catch (e) {
    print('Error running command: $e');
    exit(1);
  }
}

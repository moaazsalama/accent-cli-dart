# Accent CLI Dart

A Dart implementation of [accent-cli](https://github.com/mirego/accent-cli) for managing translations with Accent.

## Installation

### From Source

```bash
git clone https://github.com/moaazsalama/accent-cli-dart.git
cd accent-cli-dart
dart pub get
dart compile exe bin/main.dart -o accent
```

Move the compiled `accent` executable to a directory in your PATH to use it globally.

### From Pub.dev

```bash
dart pub global activate accent_cli_dart
```

## Usage

Create an `accent.json` file in your project root with your Accent API configuration:

```json
{
  "apiUrl": "http://your.accent.instance",
  "apiKey": "your-api-key",
  "files": [
    {
      "language": "en",
      "format": "json",
      "source": "localization/en/*.json",
      "target": "localization/%slug%/%original_file_name%.json",
      "hooks": {
        "afterSync": "echo 'Sync completed!'"
      }
    }
  ]
}
```

### Commands

#### Export

Export files from Accent and write them to your local filesystem:

```bash
accent export [--order-by=index|key-asc]
```

#### JIPT

Export JIPT (Just-in-place-translation) files from Accent:

```bash
accent jipt PSEUDOLANGUAGENAME
```

#### Stats

Fetch statistics from Accent and display them:

```bash
accent stats
```

#### Sync

Sync files with Accent and optionally write them to your local filesystem:

```bash
accent sync [options]
```

Options:
- `--add-translations`: Add translations in Accent to help translators
- `--merge-type=smart|passive|force`: Merge type for add translations (default: smart)
- `--order-by=index|key-asc`: Order of keys in export (default: index)
- `--sync-type=smart|passive`: Sync type (default: smart)
- `--write`: Write exported files after operation

## Configuration

### Document Configuration

Each operation section can contain the following:

- `language`: The identifier of the document's language
- `format`: The format of the document
- `source`: The path of the document (supports glob patterns)
- `target`: Path of the target languages
- `hooks`: List of hooks to be run

### Hooks

Available hooks:

- `beforeSync`
- `afterSync`
- `beforeExport`
- `afterExport`
- `beforeAddTranslations`
- `afterAddTranslations`

## License

MIT

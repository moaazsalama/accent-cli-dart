# Changelog

## 0.1.3

- Enhanced document path fetcher to match TypeScript implementation
- Added support for name patterns when processing document paths
- Added revisions and versions support in Project model
- Improved language slug extraction from revisions
- Updated Config model to include projectId
- Fixed export command to use proper API parameters

## 0.1.2

- Updated ProjectFetcher to use GraphQL instead of REST API
- Fixed Project model to properly handle GraphQL response structure
- Added comprehensive test suite for all CLI commands
- Improved error handling in API communication

## 0.1.1

- Updated README with correct GitHub repository URL

## 0.1.0

- Initial version of the Dart implementation of accent-cli
- Support for basic commands: export, jipt, stats, sync
- Support for configuration via accent.json
- Support for hooks

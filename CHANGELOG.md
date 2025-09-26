# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2025-09-26

### Added
- 🎯 **Interactive mode** (`-i` or `--interactive`) - User-friendly prompts for repository URL and token
- ✅ **URL validation** - Validates GitHub repository URLs with helpful error messages
- 🔍 **Smart development branch detection** - Auto-detects `development`, `develop`, or `dev` branches
- 🎨 **Colorized output** - Enhanced visual feedback with colored final summary
- 📝 **Input validation** - Validates Personal Access Token format and length
- 🛡️ **Enhanced error handling** - Better error messages and user guidance

### Changed
- Improved user experience with clear prompts and validation
- Enhanced final summary with colors and additional information
- More robust JSON parsing to prevent duplicate output lines
- Better handling of different GitHub repository URL formats

### Fixed
- Fixed issue with duplicate lines in final summary output
- Improved prompt visibility and user input handling
- Better error messages for invalid URLs and tokens

## [1.1.0] - 2025-09-26

### Changed
- 🌟 **Repository migrated from `master` to `main` branch** for inclusive language
- Updated documentation to prioritize `main` over `master` in all references
- Enhanced branch detection to prioritize `main` branch when both exist
- Updated code comments and examples to reflect modern git practices

### Added
- New `main` branch as the primary development branch
- Enhanced documentation with inclusive terminology

## [1.0.0] - 2025-09-26

### Added
- Initial release of Git Branch Synchronization Script
- Automatic branch detection for `master` and `main` branches
- Support for GitHub.com and GitHub Enterprise Server
- Automatic conflict resolution with configurable strategies
- Pull Request creation via GitHub API v3
- Comprehensive error handling and logging
- Support for protected branch workflows
- Cross-platform compatibility (Windows, macOS, Linux)
- Automatic cleanup of temporary working directories

### Features
- **Branch Detection**: Automatically detects whether repository uses `master` or `main`
- **Enterprise Support**: Full compatibility with GitHub Enterprise Server 3.14+
- **Conflict Resolution**: Automatic resolution prioritizing main branch changes
- **API Integration**: Creates Pull Requests using official GitHub API
- **Error Handling**: Comprehensive error messages and troubleshooting guidance
- **Security**: Secure token handling with no token exposure in logs

### Documentation
- Complete README with usage examples
- Troubleshooting guide
- Prerequisites and setup instructions
- Cross-platform compatibility notes

## [Unreleased]

### Planned
- Support for custom conflict resolution strategies
- Integration with GitHub Actions
- Support for multiple target branches
- Enhanced logging with different verbosity levels